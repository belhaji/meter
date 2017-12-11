#!/bin/bash

# Override the USER variable using the user that executes the script
if [[ ! -z $SUDO_USER ]]; then
	USER=$SUDO_USER
fi

# the main directory which contains all users mails 
MAIL_DIR="/var/emailsdb"

# directory contains all shared users pub keys
KEYS_DIR="/var/keys"

# personal user mail directory that contains Inbox, Sent and Attachments
MAIL_USER_DIR="$MAIL_DIR/$USER"

# a temporary file used as a pipe to pass results of the dialog command
# $$ is the PID program
TMP_FILE=$(tempfile 2>/dev/null) || TMP_FILE=/tmp/test$$

# a list contains all recipients usernames
RECIPIENTS=()

# a variable contains the message subject
SUBJECT=""

# a variable contains the message body
MSG_BODY=""

source utils.sh
source setup.sh
source menu.sh
source subject_ui.sh
source text_body_ui.sh
source inbox_ui.sh
source sent_ui.sh

# app startup
setup
menu











