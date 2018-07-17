#!/usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

# source guard
[[ $RUN_SOURCED -eq 1 ]] && return
declare -r RUN_SOURCED=1
declare -r RUN_ABS_SRC="$(realpath "${BASH_SOURCE[0]}")"
declare -r RUN_ABS_DIR="$(dirname "$RUN_ABS_SRC")"

run() {
    local PRONAME=run
    local VERSION="v0.0.1"
    local HELP=$(cat <<EOF
$PRONAME $VERSION
$PRONAME subcmd [args...]

This program is released under the terms of MIT License.
EOF
)
    local cmd="$1"; shift
    [[ -n $cmd ]] && hash $cmd &>/dev/null || return 1

    "$cmd" "$@"
}

notmuch-mutt() {
    local dir="$2"
    [[ -d $dir ]] || mkdir -p "$dir"
    local notmuch_mutt="$(which notmuch-mutt 2>/dev/null)"
    [[ -n $notmuch_mutt ]] || return 1

    "$notmuch_mutt" "$@"
}

[[ ${FUNCNAME[0]} == "main" ]] \
    && run "$@"

# vim:set ft=sh ts=4 sw=4:
