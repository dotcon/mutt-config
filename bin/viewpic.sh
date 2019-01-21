#!/usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

# source guard
[[ $VIEWPIC_SOURCED -eq 1 ]] && return
declare -r VIEWPIC_SOURCED=1
declare -r VIEWPIC_ABS_SRC="$(realpath "${BASH_SOURCE[0]}")"
declare -r VIEWPIC_ABS_DIR="$(dirname "$VIEWPIC_ABS_SRC")"

viewpic() {
    local PRONAME=viewpic
    local VERSION="v0.0.1"
    local HELP=$(cat <<EOF
$PRONAME $VERSION
$PRONAME <file>

This program is released under the terms of MIT License.
EOF
)
    local file="$1"
    hash convert &>/dev/null && hash aview &>/dev/null \
        || { echo "You must install 'aview' if you want to view pics in ascii."; return 1; }

    convert -colorspace gray $file $$.pgm
    echo q | aview -driver stdout -kbddriver stdin -contrast 32 $$.pgm | sed -n '27,+24p'
    rm $$.pgm
}

[[ ${FUNCNAME[0]} == "main" || ${FUNCNAME[0]} == '' ]] \
    && viewpic "$@"

# vim:set ft=sh ts=4 sw=4:
