#!/usr/bin/env bash
Char=$1
File=$2

[[ $Char =~ [gG][bB]* ]] && w3m -I $Char -T text/html $File \
    || lynx -assume_charset=$Char -display_charset=utf-8 -dump $File
