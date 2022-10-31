#!/usr/bin/env bash
# =======================================================
#
# NAME: Centreon-Alert-PasswordAge.sh
# AUTHOR: GAMBART Louis
# DATE: 31/10/2022
# VERSION 1.5.1
#
# =======================================================
#
# CHANGELOG
#
# 1.0: Initial version
# 1.1: Use another bin to secure the script
# 1.2: Add language control for french based system
# 1.3: Remove language control and force chage command execution in english
# 1.4: Add critical exit code for password older than one year
# 1.5: Change test order to avoid warning when password is older than one year
# 1.5.1: Add color in echo
#
# =======================================================


No_Color='\033[0m'
Red='\033[0;31m'
Yellow='\033[0;33m'
Green='\033[0;32m'


# if username is not set, set it to root by default
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
out=$(LANG='' chage -l "$username" | grep "Last password change" | awk '{print $5, $6, $7}' | xargs -I {} date -d "{}" +%Y-%m-%d)
now=$(date +%Y-%m-%d)
delta=$(( ($(date -d "$now" +%s) - $(date -d "$out" +%s) )/(60*60*24) ))


# if the delta is greater than 180 days, send a warning alert
if [ "$delta" -gt 365 ]; then
    echo -e "${Red}CRITICAL${No_Color}: User $username has a password that is older than 365 days"
    echo "Last password change: $out"
    exit 2
elif [ "$delta" -gt 180 ]; then
    echo -e "${Yellow}WARNING${No_Color}: User $username has a password that is older than 180 days"
    echo "Last password change: $out"
    exit 1
else
    echo -e "${Green}OK${No_Color}: User $username has a password that is not older than 180 days"
    exit 0
fi


# Path: Centreon-Alert-PasswordAge.sh

# 0 = OK
# 1 = WARNING
# 2 = CRITICAL