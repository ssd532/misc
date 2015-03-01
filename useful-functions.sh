#!/bin/bash

# Useful Bash functions
# Developed by Sachin Divekar

# Logging related
ME=${0##*/}
LOGGER="/usr/bin/logger -p"
LOGFAC="user"
LOGPRI="debug"
LOGTAG="$ME[$$]"
log_msg() {
        $LOGGER $LOGFAC.$LOGPRI -t $LOGTAG "$1"
}

#
# For displaying usages if checks are failed
#

# display usage function definition and examples START
display_usage() { 
    echo "This script must be run with super-user privileges." 
    echo -e "\nUsage:\n$0 [arguments] \n" 
} 

# if less than two arguments supplied, display usage 
if [  $# -le 1 ]; then 
    display_usage
    exit 1
fi 
 
# check whether user had supplied -h or --help . If yes display usage 
if [[ ( $# == "--help") ||  $# == "-h" ]]; then 
    display_usage
    exit 0
fi 
 
# display usage if the script is not run as root user 
if [[ $USER != "root" ]]; then 
    echo "This script must be run as root!" 
    exit 1
fi 

# display usage function definition and examples END
