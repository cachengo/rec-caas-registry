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

FROM alpine:3.9
MAINTAINER Balint Varga <balint.varga@nokia.com>

ARG REGISTRY
ENV REGISTRY_VERSION=$REGISTRY
ENV GOPATH /build
ENV PATH /usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ENV DOCKER_BUILDTAGS include_oss include_gcs

WORKDIR ${GOPATH}/src/github.com/docker/distribution
COPY common_scripts/wait-for-files /usr/bin/
COPY mainstart.sh /

RUN adduser -u 149 -D -H -s /sbin/nologin dockerreg \
&&  chmod +x /mainstart.sh /usr/bin/wait-for-files \
\
&&  apk add --no-cache --virtual .build-deps build-base go godep git curl tar \
&&  curl -fsSL -k https://github.com/docker/distribution/archive/v${REGISTRY_VERSION}.tar.gz | tar zx --strip-components=1 \
&&  go get -d -v \
&&  make PREFIX=/build clean binaries \
&&  mv ${GOPATH}/src/github.com/docker/distribution/bin/registry /usr/bin/ \
\
&&  apk del .build-deps \
&&  rm -rf /build

WORKDIR /
ENTRYPOINT ["/mainstart.sh"]
