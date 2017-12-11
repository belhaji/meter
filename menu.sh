# the main UI
function menu {
	dialog 	--cancel-label "Quit" \
			--ok-label "Choose" \
			--backtitle "Messages App" \
			--menu "Choose an option" \
			10 40 10 \
			1 "Send Message" 2 "Inbox" 3 "Sent"  2> $TMP_FILE
	ret=$(cat $TMP_FILE)
	if [[ -z $ret ]]; then
		exit 0
	fi
	case $ret in
		1)
			select_recipient
			;;
		2)
			inbox
			;;
		3)
			sent
			;;
		*)
			exit 0;
	esac
}

# UI thet help users to choose recipients
function select_recipient {
	users_list=()
	options=()
	i=0
	for user in $(get_user_list); do
		users_list+=($user)
		options+="$i $user  off "
		let i=i+1
	done
	users_list+=("root")
	options+="$i root  off "
	dialog 	--ok-label "Ok" \
			--cancel-label "Back" \
			--backtitle "Messages App" \
			--no-tags \
			--checklist "Select reciepients" \
			15 40 4 \
			${options[@]}  2> $TMP_FILE
	ret=$(cat $TMP_FILE)
	if [[ -z $ret ]]; then
		menu
	else
		for i in $(cat $TMP_FILE); do
			RECIPIENTS+=(${users_list[$i]})
		done
		subject_message
	fi
}
