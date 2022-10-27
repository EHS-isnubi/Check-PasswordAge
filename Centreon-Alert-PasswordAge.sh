#!/usr/bin/env bash
# =======================================================
#
# NAME: Centreon-Alert-PasswordAge.sh
# AUTHOR: GAMBART Louis
# DATE: 27/10/2022
# VERSION 1.2
#
# =======================================================
#
# CHANGELOG
#
# 1.0: Initial version
# 1.1: Use another bin to secure the script
# 1.2: Add language control for french based system
#
# =======================================================


# if username is not set, set it to root (default)
if [ -z "$1" ]; then
    username="root"
else
    username="$1"
fi


# if the username don't exist, exit
if ! id "$username" >/dev/null 2>&1; then
    echo "User $username does not exist"
    exit
fi


# get the password age and calculate the delta with the current date
language=$(locale | grep LANG= | cut -d= -f2 | cut -d_ -f1)
if [ "$language" = "fr" ]; then
  out=$(chage -l "$username" | grep "Dernier changement de mot de passe" | awk '{print $5, $6, $7}' | xargs -I {} date -d "{}" +%Y-%m-%d)
else
  out=$(chage -l "$username" | grep "Last password change" | awk '{print $5, $6, $7}' | xargs -I {} date -d "{}" +%Y-%m-%d)
fi
now=$(date +%Y-%m-%d)
delta=$(( ($(date -d "$now" +%s) - $(date -d "$out" +%s) )/(60*60*24) ))


# if the delta is greater than 180 days, send a warning alert
if [ "$delta" -gt 180 ]; then
    echo "User $username has a password that is older than 180 days"
        exit 1
else
    echo "User $username has a password that is not older than 180 days"
    exit 0
fi


# Path: main.sh

# 0 = OK
# 1 = WARNING
# 2 = CRITICAL