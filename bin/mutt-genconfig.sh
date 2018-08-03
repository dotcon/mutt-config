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
mutt_filter_config() {
    local -n __configs="$1"; shift
    for cfg in "$@"; do
        if [[ -d $cfg ]]; then
            for f in $cfg/* ; do
                [[ -f $f && $f =~ \.ac$ ]] && __configs+=($f)
            done
        fi
        [[ -f $cfg && $cfg =~ \.ac$ ]] && __configs+=($cfg)
    done
}
mutt_backup_config() {
    local date="$1"; shift
    for cfg in "$@"; do
        [[ -f $HOME/.$cfg ]] && mv $HOME/.$cfg $HOME/.$cfg-$date 
    done
}
mutt_install_config() {
    for cfg in "$@"; do
        local cfg_var="${cfg//-/_}"
        if declare -p "$cfg_var" &>/dev/null; then
            mutt_warn "Install $HOME/.$cfg"
            eval "echo -e \"\$$cfg_var\" >$HOME/.$cfg"
        fi
    done
}

mutt_genconfig() {
    local PRONAME=mutt-genconfig
    local VERSION="v0.0.1"
    local HELP=$(cat <<EOF
$PRONAME $VERSION
$PRONAME <configs>

This program is released under the terms of MIT License.
EOF
)
    local msmtp_accounts=""
    local offlineimap_accounts=""
    local mutt_accounts=""
    local -A notmuch_accounts
    local -A procmail_accounts
    local -a accounts
    local -a config_files

    mutt_filter_config config_files "$@"
    [[ ${#config_files[@]} -gt 0 ]] || mutt_die "No config file found."

    for cfg in "${config_files[@]}"; do
        # reset necessary options
        local config="$(basename $cfg .ac)"
        local realname=
        local account=
        local recv_host=
        local send_host=
        local password=

        # reset alternative options
        local cache=~/.cache/mutt
        local set_signature='set signature= "$HOME/.mutt/bin/set-signature.sh $from $realname |"'
        local signature=
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

        [[ -n $signature ]] && set_signature="set signature = \"$signature\""
        mutt_accounts+="mailboxes \`$MUTT_GENCONFIG_ABS_DIR/find-mailboxes.sh $cache/mail/$config\`\n"
        mutt_accounts+="$(eval "echo \"$(cat $MUTT_GENCONFIG_ABS_DIR/../templates/mutt-account)\"")\n\n"
        notmuch_accounts[$config]="$(eval "echo \"$(cat $MUTT_GENCONFIG_ABS_DIR/../templates/notmuch-account)\"")"
        procmail_accounts[$config]="$(eval "echo \"$(cat $MUTT_GENCONFIG_ABS_DIR/../templates/procmail-account)\"")"
    done

    local msmtprc="$(cat $MUTT_GENCONFIG_ABS_DIR/../templates/msmtprc)\n"
    msmtprc+="\n$msmtp_accounts"
    local offlineimaprc="$(cat $MUTT_GENCONFIG_ABS_DIR/../templates/offlineimaprc)\n"
    offlineimaprc="${offlineimaprc//\$accounts/$(IFS=, ; echo "${accounts[*]}")}"
    offlineimaprc+="\n$offlineimap_accounts"

    local date=$(date +%Y%m%d)
    local -a configs=(msmtprc offlineimaprc mutt-accounts)
    for ac in "${accounts[@]}"; do
        configs+=("notmuch-config-$ac" "procmailrc-$ac")
        eval "declare -g notmuch_config_$ac='${notmuch_accounts[$ac]}'"
        eval "declare -g procmailrc_$ac='${procmail_accounts[$ac]}'"
    done
    mutt_backup_config "$date" "${configs[@]}"
    mutt_install_config "${configs[@]}"
}

[[ ${FUNCNAME[0]} == "main" ]] \
    && mutt_genconfig "$@"

# vim:set ft=sh ts=4 sw=4:
