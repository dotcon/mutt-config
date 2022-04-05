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
    local mailbox="$1"
    local account="$(basename $mailbox)"

    if hash notmuch &>/dev/null && [[ -f $HOME/.notmuch-config-$account ]]; then
        notmuch --config="$HOME/.notmuch-config-$account" new
    fi

    if hash procmail &>/dev/null && [[ -f $HOME/.procmailrc-$account ]]; then
        local -a news=($(find $mailbox -type f -regex '.*new/.*'))
        for mail in "${news[@]}"; do
            procmail -m THIS_MAIL="$mail" $HOME/.procmailrc-$account <"$mail"
        done
    fi
}

[[ ${FUNCNAME[0]} == "main" || ${FUNCNAME[0]} == '' ]] \
    && offlineimap_postsynchook "$@"

# vim:set ft=sh ts=4 sw=4:
