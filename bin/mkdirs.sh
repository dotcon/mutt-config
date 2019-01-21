#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

# source guard
[[ $MKDIRS_SOURCED -eq 1 ]] && return
declare -r MKDIRS_SOURCED=1
declare -r MKDIRS_ABS_SRC="$(realpath "${BASH_SOURCE[0]}")"
declare -r MKDIRS_ABS_DIR="$(dirname "$MKDIRS_ABS_SRC")"

mkdirs() {
    local cache="$1"; shift
    [[ -n $cache ]] || return 1
    for dir in "$@"; do
        [[ -d $cache/$dir ]] || mkdir -p $cache/$dir
    done
}

[[ ${FUNCNAME[0]} == "main" || ${FUNCNAME[0]} == '' ]] \
    && mkdirs "$@"

# vim:set ft=sh ts=4 sw=4:
