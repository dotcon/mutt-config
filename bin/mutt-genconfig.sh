#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

# source guard
[[ $MUTT_GENCONFIG_SOURCED -eq 1 ]] && return
declare -r MUTT_GENCONFIG_SOURCED=1
declare -r MUTT_GENCONFIG_ABS_SRC="$(realpath "${BASH_SOURCE[0]}")"
declare -r MUTT_GENCONFIG_ABS_DIR="$(dirname "$MUTT_GENCONFIG_ABS_SRC")"

mutt_die() { echo "$@" >&2; exit 1; }
mutt_warn() { echo "$@" >&2; return 1;  }

mutt_genconfig() {
    local PRONAME=mutt-genconfig
    local VERSION="v0.0.1"
    local HELP=$(cat <<EOF
$PRONAME $VERSION
$PRONAME <config-dir>

This program is released under the terms of MIT License.
EOF
)
    local cfg_dir="${1%%/}"
    local msmtp_accounts=""
    local offlineimap_accounts=""
    local mutt_accounts=""
    local -a accounts
    [[ -n $cfg_dir && -d $cfg_dir ]] || mutt_die "No such directory: '$cfg_dir'"
    for cfg in "$cfg_dir"/*; do
        [[ -f $cfg ]] || continue
        local config="$(basename $cfg)"
        accounts+=($config)

        source "$cfg"
        postsynchook="${postsynchook:-$MUTT_GENCONFIG_ABS_DIR/offlineimap-postsynchook.sh}"
        
        msmtp_accounts+="$(eval "echo \"$(cat $MUTT_GENCONFIG_ABS_DIR/../templates/msmtp-account)\"")\n\n"
        offlineimap_accounts+="$(eval "echo \"$(cat $MUTT_GENCONFIG_ABS_DIR/../templates/offlineimap-account)\"")\n\n"

        [[ -d $cache/mail/$config ]] || continue
        mutt_accounts+="mailboxes \`$MUTT_GENCONFIG_ABS_DIR/find-mailboxes.sh $cache/mail/$config\`\n"
        mutt_accounts+="$(eval "echo \"$(cat $MUTT_GENCONFIG_ABS_DIR/../templates/mutt-account)\"")\n\n"
    done

    local msmtprc="$(cat $MUTT_GENCONFIG_ABS_DIR/../templates/msmtprc)\n"
    local offlineimaprc="$(cat $MUTT_GENCONFIG_ABS_DIR/../templates/offlineimaprc)\n"
    offlineimaprc="${offlineimaprc//\$accounts/$(IFS=, ; echo "${accounts[*]}")}"

    # backup original config first
    local date=$(date +%Y%m%d)
    for cfg in msmtprc offlineimaprc mutt-accounts; do
        [[ -f $HOME/.$cfg ]] && mv $HOME/.$cfg $HOME/.$cfg-$date
    done

    mutt_warn "Install $HOME/.msmtprc"
    echo -en "$msmtprc\n$msmtp_accounts" >$HOME/.msmtprc
    mutt_warn "Install $HOME/.offlineimaprc"
    echo -en "$offlineimaprc\n$offlineimap_accounts" >$HOME/.offlineimaprc
    mutt_warn "Install $HOME/.mutt-accounts"
    echo -en "$mutt_accounts" >$HOME/.mutt-accounts
}

[[ ${FUNCNAME[0]} == "main" ]] \
    && mutt_genconfig "$@"

# vim:set ft=sh ts=4 sw=4:
