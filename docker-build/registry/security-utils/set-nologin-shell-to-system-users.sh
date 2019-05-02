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

. $(dirname "$0")/utils.sh

is_nologin_shell () {
    shell=$1

    set -- "/sbin/nologin" "/bin/sync" "/sbin/halt" "/sbin/shutdown"
    for no_login_shell
    do
        if [ "$no_login_shell" = "$shell" ]
        then
            return 1;
        fi
    done
    return 0;
}

set_nologin_shell () {
    account=$1

    name=$(echo "$account" | cut -d: -f1)
    uid=$(echo "$account" | cut -d: -f3)
    gid=$(echo "$account" | cut -d: -f4)
    gecos=$(echo "$account" | cut -d: -f5)
    home_dir=$(echo "$account" | cut -d: -f6)

    del_user "$name" > /dev/null 2&>1
    group_name=$(get_group_name "$gid")
    if [ -z $group_name ]
    then
        group_command=""
    else
        group_command="-G $group_name"
    fi
    adduser -D -h "$home_dir" -g "$gecos" -s /sbin/nologin $group_command -u "$uid" "$name"

}

main () {
    while read -r account
    do
        name=$(echo "$account" | cut -d: -f1)
        if [ "$name" = "root" ]
        then
            continue;
        fi

        shell=$(echo "$account" | cut -d: -f7)
        if is_nologin_shell "$shell"
        then
            set_nologin_shell "$account"
        fi
    done < /etc/passwd

    if [[ `ls -ld /root | awk '{print $3"\n"$4}' | grep -v root` ]]
    then
        chown root:root /root
    fi

}

main
