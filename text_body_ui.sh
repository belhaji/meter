
# UI that gets the message text and send the hole message to RECIPIENTS
function text_message {
	if [[ -z $EDITOR ]]; then
		EDITOR=nano
	fi
	echo $MSG_BODY > $TMP_FILE
	$EDITOR $TMP_FILE
	MSG_BODY="$(cat $TMP_FILE)"
	dialog 	--no-label "Edit" \
			--ok-label "Ok" \
			--backtitle "Messages App" \
			--title "You typed this Message"\
			--yesno "$MSG_BODY"  \
			10 40 2> $TMP_FILE
	ret=$?
	if [[ $ret -eq 1 ]]; then
		text_message
	fi
	dialog 	--no-label "No" \
			--ok-label "Ok" \
			--backtitle "Messages App" \
			--title "Do you want to encrypt this Message"\
			--yesno "$MSG_BODY"  \
			10 40 2> $TMP_FILE
	encrypt=$?
	i=0
	lengh=${#RECIPIENTS}
	for user in ${RECIPIENTS[@]}; do
		user_mail_dir_exists $user || create_user_mail_dir $user
		msg="$(date)\n$USER\n$user\n$SUBJECT\n$MSG_BODY"
		timestamp=$(date +%s)
		MSG_FILE=$(tempfile 2> /dev/null)
		echo -e $msg > $MSG_FILE
		subject=$(echo $SUBJECT | tr ' ' '-')
		if [[ $encrypt -eq 1 ]]; then
			msg_file="$MAIL_DIR/$user/Inbox/$timestamp-$subject.msg"
			cp -f $MSG_FILE "$msg_file"
		else
			msg_file_enc="$MAIL_DIR/$user/Inbox/$timestamp-$subject.msg.gpg"
			dialog 	--cancel-label "Cancel" \
					--ok-label "Next" \
					--backtitle "Messages App" \
					--inputbox "Email Adress of the destination"  \
					10 40 2> $TMP_FILE
			ret=$(cat $TMP_FILE)
			if [[ -z $ret ]]; then
				menu
			else
				gpg -k --homedir "/root/.gnupg" $ret > /dev/null
				if [[ $? -eq 0 ]]; then
					gpg -r $ret --homedir "/root/.gnupg"  -o "$msg_file_enc" --encrypt $MSG_FILE
				else
					dialog 	--ok-label "Ok" \
							--backtitle "Messages App" \
							--msgbox "The destination don't have a keys, to generate on type 'gpg --key-gen ; gpg --export <email> > /var/keys/<user>.key'"  \
							10 40
					menu
				fi
			fi
		fi
		cp -f "$MSG_FILE" "$MAIL_USER_DIR/Sent/$timestamp-$subject.msg"
		let i=i+$((100/$lengh))
		echo $i | dialog --title "Sending" --gauge "Sending messages" 10 70 0
		sleep 1
	done 
	dialog 	--ok-label "Ok" \
			--backtitle "Messages App" \
			--msgbox "Your Message has been sent successfully"  \
			10 40
	SUBJECT=""
	MSG_BODY=""
	menu
}
