#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

# source guard
[[ $SET_SIGNATURE_SOURCED -eq 1 ]] && return
declare -r SET_SIGNATURE_SOURCED=1
declare -r SET_SIGNATURE_ABS_SRC="$(realpath "${BASH_SOURCE[0]}")"
declare -r SET_SIGNATURE_ABS_DIR="$(dirname "$SET_SIGNATURE_ABS_SRC")"

set_signature() {
    local PRONAME=set-signature
    local VERSION="v0.0.1"
    local HELP=$(cat <<EOF
$PRONAME $VERSION
$PRONAME <from> <realname>

This program is released under the terms of MIT License.
EOF
)
    local from="$1"; shift
    local realname="$*"
    [[ -n $from && -n $realname ]] || return 1
    
    echo "------------------------------------------"
    echo "$realname"
    echo "$from"
    echo "------------------------------------------"
}

[[ ${FUNCNAME[0]} == "main" || ${FUNCNAME[0]} == '' ]] \
    && set_signature "$@"

# vim:set ft=sh ts=4 sw=4:
