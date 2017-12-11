# UI that shows the list of sent messages
function sent {
	user_mail_dir_exists $USER || create_user_mail_dir $USER
	messages=()
	options=()
	files=()
	i=0
	for msg in $(ls "$MAIL_USER_DIR/Sent/" | sort -r ); do
		files+=("$MAIL_USER_DIR/Sent/$msg")
		compressed=0
		if [[ $msg == *.gz ]]; then
			gzip -d "$MAIL_USER_DIR/Sent/$msg"
			compressed=1	
			# remove the .gz from $msg
			msg=${msg::-3}
		fi
		msg_date=$(head -n1 "$MAIL_USER_DIR/Sent/$msg")
		to=$(head -n3 "$MAIL_USER_DIR/Sent/$msg"| tail -n1 )
		title=$(head -n4 "$MAIL_USER_DIR/Sent/$msg"| tail -n1 )
		message="$title - to $to on $msg_date"
		options+=($i "$message")
		text_body="$(tail -n +5 $MAIL_USER_DIR/Sent/$msg)"
		let i=i+1
		if [[ $compressed == 1 ]]; then
			gzip "$MAIL_USER_DIR/Sent/$msg"
		fi
	done
	if [[ ${#options} -lt 1 ]]; then
		dialog 	--ok-label "Ok" \
			--backtitle "Messages App" \
			--msgbox "Your sent box is empty"  \
			10 40
		menu
	fi
	dialog 	--cancel-label "Back" \
			--ok-label "Choose" \
			--backtitle "Messages App" \
			--menu "Choose a message" \
			15 80 10 \
			"${options[@]}"  2> $TMP_FILE
	ret=$(cat $TMP_FILE)
	if [[ -z $ret  ]]; then
		menu
	else
		f="${files[$ret]}"
		dialog --no-label "Delete"	\
			--ok-label "Back" \
			--backtitle "Messages App" \
			--yesno "$text_body" \
			10 40 
		ret=$?
		if [[ $ret -eq 1 ]]; then
			rm $f
		fi
		sent
	fi
}
