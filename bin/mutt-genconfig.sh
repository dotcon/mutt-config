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
$PRONAME <configs>

This program is released under the terms of MIT License.
EOF
)
    local cfg_dir="${1%%/}"
    local msmtp_accounts=""
    local offlineimap_accounts=""
    local mutt_accounts=""
    local -A notmuch_accounts
    local -A procmail_accounts
    local -a accounts
    local -a cfg_files

    for cfg in "$@"; do
        if [[ -d $cfg ]]; then
            for f in $cfg/* ; do
                [[ -f $f && $f =~ \.ac$ ]] && cfg_files+=($f)
            done
        fi
        [[ -f $cfg && $cfg =~ \.ac$ ]] && cfg_files+=($cfg)
    done
    [[ ${#cfg_files[@]} -gt 0 ]] || mutt_die "No config file found."

    for cfg in "${cfg_files[@]}"; do
        # reset necessary options
        local config="$(basename $cfg .ac)"
        local realname=
        local account=
        local recv_host=
        local send_host=
        local password=

        # reset alternative options
        local cache=~/.cache/mutt
        local send_port=
        local send_tls=
        local send_tls_starttls=
        local send_tls_certcheck=
        local send_tls_trust_file=
        local recv_port=
        local recv_hook=
        local recv_ssl=
        local recv_ssl_trust_file=
        local recv_ssl_fingerprint=

        accounts+=($config)

        source "$cfg"
        
        msmtp_accounts+="$(eval "echo \"$(cat $MUTT_GENCONFIG_ABS_DIR/../templates/msmtp-account)\"")\n"
        [[ -n $send_port ]] && msmtp_accounts+="port $send_port\n"
        [[ $send_tls == off ]] && msmtp_accounts+="tls off\ntls_trust_file\n"
        [[ $send_tls_starttls == off ]] \
            && msmtp_accounts+="tls_starttls off\n"
        [[ $send_tls_certcheck == off ]] \
            && msmtp_accounts+="tls_certcheck off\ntls_trust_file\n"
        [[ -n $send_tls_trust_file ]] && msmtp_accounts+="tls_trust_file $send_tls_trust_file\n"
        msmtp_accounts+="\n"

        local ssl=yes
        local sslcacertfile=/etc/ssl/certs/ca-certificates.crt
        local postsynchook="${recv_hook:-$MUTT_GENCONFIG_ABS_DIR/offlineimap-postsynchook.sh}"
        [[ $recv_ssl == no ]] && ssl=no
        offlineimap_accounts+="$(eval "echo \"$(cat $MUTT_GENCONFIG_ABS_DIR/../templates/offlineimap-account)\"")\n"
        if [[ -n $recv_ssl_fingerprint ]]; then
            offlineimap_accounts+="cert_fingerprint = $recv_ssl_fingerprint\n"
        elif [[ -n $recv_ssl_trust_file ]]; then
            offlineimap_accounts+="sslcacertfile = $recv_ssl_trust_file\n"
        else
            offlineimap_accounts+="sslcacertfile = $sslcacertfile\n"
        fi
        [[ -n $recv_port ]] && offlineimap_accounts+="remoteport = $recv_port\n"
        offlineimap_accounts+="\n"

        mutt_accounts+="mailboxes \`$MUTT_GENCONFIG_ABS_DIR/find-mailboxes.sh $cache/mail/$config\`\n"
        mutt_accounts+="$(eval "echo \"$(cat $MUTT_GENCONFIG_ABS_DIR/../templates/mutt-account)\"")\n\n"
        notmuch_accounts[$config]="$(eval "echo \"$(cat $MUTT_GENCONFIG_ABS_DIR/../templates/notmuch-account)\"")"
        procmail_accounts[$config]="$(eval "echo \"$(cat $MUTT_GENCONFIG_ABS_DIR/../templates/procmail-account)\"")"
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
    echo -en "$msmtprc\n$msmtp_accounts" >$HOME/.msmtprc && chmod 600 $HOME/.msmtprc
    mutt_warn "Install $HOME/.offlineimaprc"
    echo -en "$offlineimaprc\n$offlineimap_accounts" >$HOME/.offlineimaprc && chmod 600 $HOME/.offlineimaprc
    mutt_warn "Install $HOME/.mutt-accounts"
    echo -en "$mutt_accounts" >$HOME/.mutt-accounts

    for ac in "${accounts[@]}"; do
        [[ -f $HOME/.notmuch-config-$ac ]] && mv $HOME/.notmuch-config-$ac $HOME/.notmuch-config-$ac-$date
        mutt_warn "Install $HOME/.notmuch-config-$ac"
        echo -e "${notmuch_accounts[$ac]}" >$HOME/.notmuch-config-$ac
        [[ -f $HOME/.procmailrc-$ac ]] && mv $HOME/.procmailrc-$ac $HOME/.procmailrc-$ac-$date
        mutt_warn "Install $HOME/.procmailrc-$ac"
        echo -e "${procmail_accounts[$ac]}" >$HOME/.procmailrc-$ac
    done
}

[[ ${FUNCNAME[0]} == "main" ]] \
    && mutt_genconfig "$@"

# vim:set ft=sh ts=4 sw=4:
