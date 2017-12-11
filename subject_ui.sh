# UI that shows an input box ang set the message subject into SUBJECT variable
function subject_message {
	dialog 	--cancel-label "Back" \
			--ok-label "Next" \
			--backtitle "Messages App" \
			--inputbox "Subject"  \
			10 40 2> $TMP_FILE
	ret=$(cat $TMP_FILE)
	if [[ -z $ret ]]; then
		select_recipient
	else
		SUBJECT=$(cat $TMP_FILE)
		text_message
	fi
	

}