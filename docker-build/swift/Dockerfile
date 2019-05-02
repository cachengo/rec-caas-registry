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

FROM centos:7.6.1810
MAINTAINER Balint Varga <balint.varga@nokia.com>

ARG SWIFT
ENV SWIFT_VERSION=$SWIFT
ENV GOPATH /build
ENV PATH /usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

COPY get-package build-pip common_scripts/wait-for-files /usr/bin/
COPY nginx.repo /etc/yum.repos.d/

RUN yum remove -y subscription-manager \
    && yum -y install \
      tar \
      bzip2 \
      python27-python-pip \
    && yum clean all \
    && mkdir -p ${GOPATH} \
    && chmod 755 /usr/bin/build-pip /usr/bin/get-package /usr/bin/wait-for-files \
    && echo "console" > /etc/securetty \
    && chmod 400 /etc/shadow \
    && chmod 700 /root

COPY supervisord.conf /etc/supervisord.conf
COPY mainstart.sh /usr/bin/mainstart.sh
COPY healthchecker.sh /usr/bin/healthchecker.sh
COPY source-list.txt ${GOPATH}/

RUN useradd -u 146 -s /sbin/nologin swift \
&&  mkdir -p /var/run/rsyncd \
&&  chown -R swift:swift /var/run/rsyncd \
&&  mkdir -p /var/lock/swift_locks \
&&  chown -R swift:swift /var/lock/swift_locks \
&&  mkdir -p /var/log/swift \
&&  chown -R swift:swift /var/log/swift \
&&  chmod 644 ${GOPATH}/source-list.txt \
&&  yum install -y --setopt=skip_missing_names_on_install=False \
      gcc \
      make \
      autoconf \
      memcached \
      rsync \
      automake \
      libtool \
      libffi \
      libffi-devel \
      python-devel \
      openssl-devel \
      libxml2-devel \
      libxslt-devel \
      nginx \

# prepare nginx service
&&  touch /run/nginx.pid \
&&  chown -R swift:swift /var/lib/nginx /var/log/nginx /run/nginx.pid \

# liberasurecode
&&  mkdir ${GOPATH}/liberasurecode \
&&  cd ${GOPATH}/liberasurecode \
&&  get-package liberasurecode \
&&  ./autogen.sh \
&&  ./configure \
&&  make -j$(nproc) \
&&  make install \

# gf-complete
&&  mkdir ${GOPATH}/gf-complete \
&&  cd ${GOPATH}/gf-complete \
&&  get-package gf-complete \
&&  autoreconf --force --install \
&&  ./configure \
&&  make -j$(nproc) \
&&  make install \

# jerasure
&&  mkdir ${GOPATH}/Jerasure \
&&  cd ${GOPATH}/Jerasure \
&&  get-package Jerasure \
&&  autoreconf --force --install \
&&  ./configure LDFLAGS=-L${GOPATH}/other/gf-complete/src/.libs/ CPPFLAGS=-I${GOPATH}/other/gf-complete/include ax_cv_gcc_x86_cpuid_0x00000001=0 \
&&  make -j$(nproc) \
&&  make install \

# nasm
&&  mkdir ${GOPATH}/nasm \
&&  cd ${GOPATH}/nasm \
&&  get-package nasm \
&&  ./configure \
&&  make -j$(nproc) \
&&  make install \

# isa-l
&&  mkdir ${GOPATH}/isa-l \
&&  cd ${GOPATH}/isa-l \
&&  get-package isa-l \
&&  ./autogen.sh \
&&  ./configure \
&&  make -j$(nproc) \
&&  make install \

# setuptools
&&  mkdir ${GOPATH}/setuptools \
&&  get-package python-setuptools \
&&  python bootstrap.py \
&&  python setup.py install \
&&  cd ${GOPATH} \

# workaround, because the new chardet python package can't override the old one correctly
&&  curl -fsSL -k https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
&&  python get-pip.py \
&&  pip uninstall -y chardet \

# python dependencies
&&  build-pip python-enum-compat python-eventlet python-dnspython python-greenlet python-netifaces python-pastedeploy python-six \
python-pycparser python-cffi python-xattr \
python-idna python-enum34 python-ipaddress python-cryptography \
python-PyECLib python-supervisor python-supervisor-stdout \
python-lxml python-chardet python-requests \

# swift
&&  mkdir -p ${GOPATH}/pip \
&&  cd ${GOPATH}/pip \
&&  curl -fsSL -k https://tarballs.openstack.org/swift/swift-${SWIFT_VERSION}.tar.gz | tar zx --strip-components=1 -C ${GOPATH}/pip/ \
&&  python setup.py install \
&&  rm -rf ${GOPATH}/pip/* \

# register the library path
&&  echo '/usr/local/lib' > /etc/ld.so.conf \
&&  ldconfig \

# rights
&&  chmod +x /usr/bin/mainstart.sh \
&&  mkdir -p /var/swift/recon \
&&  mkdir -p /var/cache/swift \
&&  mkdir /var/run/supervisor \
&&  chown -R swift /var/swift/recon \
&&  chown -R swift /var/cache/swift \
&&  chown -R swift /var/run/supervisor \

# cleaning
&&  yum --setopt=tsflags=noscripts remove -y gcc libffi-devel autoconf automake libtool python-devel openssl-devel \
&&  yum clean all \
&&  rm -rf /etc/yum.repos.d/luxembourg.repo \
&&  rm -rf ${GOPATH} \
&&  setcap 'cap_net_bind_service=+ep' /usr/bin/rsync

ENTRYPOINT ["/usr/bin/mainstart.sh"]
