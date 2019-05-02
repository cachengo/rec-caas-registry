#!/bin/sh
# Copyright 2019 Nokia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#Before start:
#Part power, replica and hour as env

if [ $1 == "BACKEND_BUILDER" ]; then
  echo "Remove unnecessary pid file"
  rm -rf /var/run/rsyncd/rsyncd.pid
fi

file_names="/etc/swift/account-server.conf /etc/swift/container-server.conf /etc/swift/object-server.conf /etc/swift/proxy-server.conf /etc/swift/rsyncd.conf /etc/swift/swift.conf /etc/swift/memcached"
/usr/bin/wait-for-files "${file_names}"
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

if [ ! -e /etc/swift/account.ring.gz ]; then
  cd /etc/swift
  echo "Ring files not found. Create them..."
  # get ports from the config files
  SWIFT_ACCOUNT_PORT=`grep "bind_port" /etc/swift/account-server.conf | awk '{print $3}'`
  SWIFT_CONTAINER_PORT=`grep "bind_port" /etc/swift/container-server.conf | awk '{print $3}'`
  SWIFT_OBJECT_PORT=`grep "bind_port" /etc/swift/object-server.conf | awk '{print $3}'`

  swift-ring-builder account.builder create ${SWIFT_PART_POWER} ${SWIFT_REPLICAS} ${SWIFT_PART_HOUR}
  swift-ring-builder container.builder create ${SWIFT_PART_POWER} ${SWIFT_REPLICAS} ${SWIFT_PART_HOUR}
  swift-ring-builder object.builder create ${SWIFT_PART_POWER} ${SWIFT_REPLICAS} ${SWIFT_PART_HOUR}

  for IP in ${SWIFT_OAM1_IP} ${SWIFT_OAM2_IP} ${SWIFT_OAM3_IP}; do
    swift-ring-builder account.builder add r1z2-$IP:${SWIFT_ACCOUNT_PORT}/${SWIFT_DISK} 10
    swift-ring-builder container.builder add r1z2-$IP:${SWIFT_CONTAINER_PORT}/${SWIFT_DISK} 10
    swift-ring-builder object.builder add r1z2-$IP:${SWIFT_OBJECT_PORT}/${SWIFT_DISK} 10
    echo "swift-ring-builder object.builder add r1z2-$IP:6000/${SWIFT_DISK} 10"
  done

  swift-ring-builder account.builder
  swift-ring-builder container.builder
  swift-ring-builder object.builder

  swift-ring-builder account.builder rebalance
  swift-ring-builder container.builder rebalance
  swift-ring-builder object.builder rebalance
fi

exec /usr/bin/supervisord -c /etc/supervisord.conf
