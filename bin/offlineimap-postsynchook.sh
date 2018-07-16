#!/usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

# source guard
[[ $OFFLINEIMAP_POSTSYNCHOOK_SOURCED -eq 1 ]] && return
declare -r OFFLINEIMAP_POSTSYNCHOOK_SOURCED=1
declare -r OFFLINEIMAP_POSTSYNCHOOK_ABS_SRC="$(realpath "${BASH_SOURCE[0]}")"
declare -r OFFLINEIMAP_POSTSYNCHOOK_ABS_DIR="$(dirname "$OFFLINEIMAP_POSTSYNCHOOK_ABS_SRC")"

offlineimap_postsynchook() {
    [[ -n $1 ]] || return 1
    hash notmuch &>/dev/null && notmuch --config="$HOME/.notmuch-config-$1" new
    # hash procmail &>/dev/null && procmail
}

[[ ${FUNCNAME[0]} == "main" ]] \
    && offlineimap_postsynchook "$@"

# vim:set ft=sh ts=4 sw=4:
