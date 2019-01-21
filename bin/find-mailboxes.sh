#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

# source guard
[[ $FIND_MAILBOXES_SOURCED -eq 1 ]] && return
declare -r FIND_MAILBOXES_SOURCED=1
declare -r FIND_MAILBOXES_ABS_SRC="$(realpath "${BASH_SOURCE[0]}")"
declare -r FIND_MAILBOXES_ABS_DIR="$(dirname "$FIND_MAILBOXES_ABS_SRC")"

find_mailboxes() {
    local PRONAME=find-mailboxes
    local VERSION="v0.0.1"
    local HELP=$(cat <<EOF
$PRONAME $VERSION
$PRONAME <mail-dir>

This program is released under the terms of MIT License.
EOF
)
    [[ -d $1 ]] || return 1
    local mail_dir="$1"
    local -a boxes
    boxes=($(find $mail_dir -maxdepth 1 -type d -not -regex '.*/\.[^/]*$' -printf '"%p"\n' | sort))
    echo "${boxes[@]}"
}

[[ ${FUNCNAME[0]} == "main" || ${FUNCNAME[0]} == '' ]] \
    && find_mailboxes "$@"

# vim:set ft=sh ts=4 sw=4:
