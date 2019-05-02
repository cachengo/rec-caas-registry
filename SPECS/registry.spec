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

%define COMPONENT registry
%define RPM_NAME caas-%{COMPONENT}
%define RPM_MAJOR_VERSION 2.7.1
%define RPM_MINOR_VERSION 1
%define IMAGE_TAG %{RPM_MAJOR_VERSION}-%{RPM_MINOR_VERSION}
Name:           %{RPM_NAME}
Version:        %{RPM_MAJOR_VERSION}
Release:        %{RPM_MINOR_VERSION}%{?dist}
Summary:        Containers as a Service Registry component
License:        %{_platform_license} and Apache License and GNU Lesser General Public License v3.0 only and BSD 3-clause New or Revised License and MIT License and Common Development and Distribution License and BSD and GNU General Public License v2.0 only
URL:            https://github.com/docker/distribution
BuildArch:      x86_64
Vendor:         %{_platform_vendor} and docker/distribution unmodified
Source0:        %{name}-%{version}.tar.gz

Requires: docker-ce >= 18.09.2
BuildRequires: docker-ce >= 18.09.2

%description
This rpm contains the docker registry container and ansible for caas subsystem.
This container contains the registry service.

%prep
%autosetup

%build
# Building the container
docker build \
  --network=host \
  --no-cache \
  --force-rm \
  --build-arg HTTP_PROXY="${http_proxy}" \
  --build-arg HTTPS_PROXY="${https_proxy}" \
  --build-arg NO_PROXY="${no_proxy}" \
  --build-arg http_proxy="${http_proxy}" \
  --build-arg https_proxy="${https_proxy}" \
  --build-arg no_proxy="${no_proxy}" \
  --build-arg REGISTRY="%{version}" \
  --tag %{COMPONENT}:%{IMAGE_TAG} \
  %{_builddir}/%{RPM_NAME}-%{RPM_MAJOR_VERSION}/docker-build/%{COMPONENT}/

# Creating a new folder for the container tar file
mkdir -p %{_builddir}/%{RPM_NAME}-%{RPM_MAJOR_VERSION}/docker-save/

# Save the container
docker save %{COMPONENT}:%{IMAGE_TAG} | gzip -c > %{_builddir}/%{RPM_NAME}-%{RPM_MAJOR_VERSION}/docker-save/%{COMPONENT}:%{IMAGE_TAG}.tar

# Remove container
docker rmi -f %{COMPONENT}:%{IMAGE_TAG}

%install
# at this point the version variable changes e.g.: from 2.7.1 to 2.7.1-100.el7.centos.akrainolite.x86_64
mkdir -p %{buildroot}/%{_caas_container_tar_path}
rsync -av %{_builddir}/%{RPM_NAME}-%{RPM_MAJOR_VERSION}/docker-save/%{COMPONENT}:%{IMAGE_TAG}.tar %{buildroot}/%{_caas_container_tar_path}/

mkdir -p %{buildroot}/%{_playbooks_path}/
rsync -av ansible/playbooks/registry_pre_config.yaml %{buildroot}/%{_playbooks_path}/
rsync -av ansible/playbooks/registry.yaml %{buildroot}/%{_playbooks_path}/

mkdir -p %{buildroot}/%{_roles_path}/
rsync -av ansible/roles/registry_pre_config %{buildroot}/%{_roles_path}/
rsync -av ansible/roles/registry %{buildroot}/%{_roles_path}/

%files
%{_caas_container_tar_path}/%{COMPONENT}:%{IMAGE_TAG}.tar
%{_playbooks_path}/*
%{_roles_path}/*


%preun

%post
mkdir -p %{_postconfig_path}/
ln -sf %{_playbooks_path}/registry_pre_config.yaml %{_postconfig_path}/
ln -sf %{_playbooks_path}/registry.yaml %{_postconfig_path}/

%postun
if [ $1 -eq 0 ]; then
    rm -f %{_postconfig_path}/registry_pre_config.yaml
    rm -f %{_postconfig_path}/registry.yaml
fi

%clean
rm -rf ${buildroot}

