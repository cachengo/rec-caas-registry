#!/bin/bash
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

SWIFT_AUTH_KEY=$(curl --cacert /etc/swift/tls-proxy/ca.pem -Ss -XGET -i -H"X-Auth-User:${SWIFT_TENANT}:${SWIFT_USER}" -H"X-Auth-Key:${SWIFT_PASS}" https://swift.kube-system.svc.nokia.net:8084/auth/v1.0 | grep X-Auth-Token: | awk "{ print \$2 }")

curl --fail --cacert /etc/swift/tls-proxy/ca.pem -Ss -XGET -H"X-Auth-Token: ${SWIFT_AUTH_KEY}" https://swift.kube-system.svc.nokia.net:8084/v1.0/AUTH_admin
