#!/usr/bin/env bash
# This script will check the password age of the user and, if it is older than 180 days, it will send exit code to Centre
# Accepts one argument: the username
# Usage: ./main.sh username


if ! id "$1" >/dev/null 2>&1; then
    echo "User $1 does not exist"
    exit
fi


if ! passwd -S "$1" | grep -qP 'P'; then
    echo "User $1 does not have a password"
    exit 2
fi


out=$(passwd -S "$1" | awk '{print $3}')
now=$(date +%Y-%m-%d)
delta=$(( ($(date -d "$now" +%s) - $(date -d "$out" +%s) )/(60*60*24) ))


if [ "$delta" -gt 180 ]; then
    echo "User $1 has a password that is older than 180 days"
        exit 1
else
    echo "User $1 has a password that is not older than 180 days"
    exit 0
fi


# Path: main.sh

# 0 = OK
# 1 = WARNING
# 2 = CRITICAL