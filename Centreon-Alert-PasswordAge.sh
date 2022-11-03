#!/usr/bin/env bash
#==========================================================================================
#
# SCRIPT NAME        :     Centreon-Alert-PasswordAge.sh
#
# AUTHOR             :     Louis GAMBART
# CREATION DATE      :     2022.10.27
# RELEASE            :     v1.5.1
# USAGE SYNTAX       :     .\Centreon-Alert-PasswordAge.sh <username>
#
# SCRIPT DESCRIPTION :     This script is used to check the password age of a user and return a status code to Centreon.
#
#==========================================================================================
#
#                 - RELEASE NOTES -
# v1.0.0  2022.10.27 - Louis GAMBART - Initial version
# v1.1.0  2022.10.27 - Louis GAMBART - Use another bin to secure the script
# v1.2.0  2022.10.27 - Louis GAMBART - Add language control for french based system
# v1.3.0  2022.10.27 - Louis GAMBART - Remove language control and force chage command execution in english
# v1.4.0  2022.10.28 - Louis GAMBART - Add critical exit code for password older than one year
# v1.5.0  2022.10.31 - Louis GAMBART - Change test order to avoid warning when password is older than one year
# v1.5.1  2022.10.31 - Louis GAMBART - Add color in echo
#
#==========================================================================================


#####################
#                   #
#  I - COLOR CODES  #
#                   #
#####################

No_Color='\033[0m'      # No Color
Red='\033[0;31m'        # Red
Yellow='\033[0;33m'     # Yellow
Green='\033[0;32m '     # Green


#####################
#                   #
#  II - ROOT CHECK  #
#                   #
#####################

if [ "$EUID" -ne 0 ]
  then echo -e "${Red}Please run as root${No_Color}"
  exit
fi

######################
#                    #
#  III - CHECK USER  #
#                    #
######################

# If any user is specified in the command line, set it as root user
if [ -z "$1" ]; then
    username="root"
else
    username="$1"
fi

# If the user provided don't exist, exit the script
if ! id "$username" >/dev/null 2>&1; then
    echo "User $username does not exist"
    exit
fi


####################
#                  #
#  IV - GET DELTA  #
#                  #
####################

# Get the delta, in days, between the current date and the last password change date
out=$(LANG='' chage -l "$username" | grep "Last password change" | awk '{print $5, $6, $7}' | xargs -I {} date -d "{}" +%Y-%m-%d)
now=$(date +%Y-%m-%d)
delta=$(( ($(date -d "$now" +%s) - $(date -d "$out" +%s) )/(60*60*24) ))


######################
#                    #
#  V - MAIN SCRIPT   #
#                    #
######################

# If the delta is greater than 365, exit the script with critical code
if [ "$delta" -gt 365 ]; then
    echo -e "${Red}CRITICAL${No_Color}: User $username has a password that is older than 365 days"
    echo "Last password change: $out ($delta days ago)"
    exit 2
# If the delta is greater than 180 days, exit the script with warning code
elif [ "$delta" -gt 180 ]; then
    echo -e "${Yellow}WARNING${No_Color}: User $username has a password that is older than 180 days"
    echo "Last password change: $out ($delta days ago)"
    exit 1
# Else, exit the script with ok code
else
    echo -e "${Green}OK${No_Color}: User $username has a password that is not older than 180 days"
    echo "Last password change: $out ($delta days ago)"
    exit 0
fi


###################
#                 #
#  VI - CENTREON  #
#                 #
###################

# 0 = OK
# 1 = WARNING
# 2 = CRITICAL