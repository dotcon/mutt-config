#!/usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

# source guard
[[ $VIEWHTML_SOURCED -eq 1 ]] && return
declare -r VIEWHTML_SOURCED=1
declare -r VIEWHTML_ABS_SRC="$(realpath "${BASH_SOURCE[0]}")"
declare -r VIEWHTML_ABS_DIR="$(dirname "$VIEWHTML_ABS_SRC")"

viewhtml() {
    local PRONAME=viewhtml
    local VERSION="v0.0.1"
    local HELP=$(cat <<EOF
$PRONAME $VERSION
$PRONAME <char-set> <file>

This program is released under the terms of MIT License.
EOF
)
    local char=$1
    local file=$2

    hash lynx &>/dev/null && hash w3m &>/dev/null \
        || { echo "You must install 'lynx' and 'w3m' if you want to read HTML emails."; return 1; }

    if [[ $char =~ [gG][bB]* ]]; then
        w3m -I $char -T text/html $file
    else
        lynx -assume_charset=$char -display_charset=utf-8 -dump $file
    fi
}

[[ ${FUNCNAME[0]} == "main" || ${FUNCNAME[0]} == '' ]] \
    && viewhtml "$@"

# vim:set ft=sh ts=4 sw=4:
