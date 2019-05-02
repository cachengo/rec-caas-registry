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

del_user () {
    if command -v userdel
    then
        userdel "$1"
    else
        deluser "$1"
    fi
}

del_group () {
    if command -v groupdel
    then
        groupdel "$1"
    else
        delgroup "$1"
    fi
}

get_group_name () {
    while read -r group_info
    do
        gid=$(echo $group_info | cut -d: -f3)
        if [ "$gid" = "$1" ]
        then
            echo $(echo "$group_info" | cut -d: -f1);
        fi
    done < /etc/group
}
