# UI that shows the list of received messages
function inbox {
	user_mail_dir_exists $USER || create_user_mail_dir $USER
	messages=()
	options=()
	files=()
	bodies=()
	i=0
	for msg in $(ls "$MAIL_USER_DIR/Inbox/" | sort -r ); do
		files+=("$MAIL_USER_DIR/Inbox/$msg")
		compressed=0
		if [[ $msg == *.gz ]]; then
			gzip -d "$MAIL_USER_DIR/Inbox/$msg"
			compressed=1		
			# remove the .gz from $msg
			msg=${msg::-3}
		fi
		if [[ $msg == *.gpg ]]; then
			file_dec=$(su -c "tempfile 2> /dev/null" $USER) 
			if [[ $USER == 'root' ]]; then
				gpg --homedir "/$USER/.gnupg" -d "$MAIL_USER_DIR/Inbox/$msg" > $file_dec
			else
				# création d'un fichier temporaire dans le home de l'utilisateur courant
				# pour résoudre les problèmes de permission
				cp $MAIL_USER_DIR/Inbox/$msg /home/$USER/$msg
				su -c "gpg --homedir \"/home/$USER/.gnupg\" -d ~/$msg > $file_dec" $USER
				# suppression de ce fichier temporaire (évite faille de sécurité)
				rm -rf /home/$USER/$msg
			fi
			msg_date=$(head -n1 "$file_dec" | tail -n1 )
			from=$(head -n2 "$file_dec" | tail -n1 )
			title=$(head -n4 "$file_dec" | tail -n1 )
			message="$title - from $from on $msg_date"
		else
			file_dec="$MAIL_USER_DIR/Inbox/$msg"
			msg_date=$(head -n1 "$MAIL_USER_DIR/Inbox/$msg")
			from=$(head -n2 "$MAIL_USER_DIR/Inbox/$msg"| tail -n1 )
			title=$(head -n4 "$MAIL_USER_DIR/Inbox/$msg"| tail -n1 )
			message="$title - from $from on $msg_date"	
		fi
		bodies+=("$(tail -n +5 $file_dec)")
		options+=($i "$message")
		let i=i+1
		if [[ $compressed == 1 ]]; then
			gzip "$MAIL_USER_DIR/Inbox/$msg"
		fi
	done
	if [[ ${#options} -lt 1 ]]; then
		dialog 	--ok-label "Ok" \
			--backtitle "Messages App" \
			--msgbox "Your Inbox is empty"  \
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
		text_body="${bodies[$ret]}"
		dialog --no-label "Delete"	\
			--ok-label "Back" \
			--backtitle "Messages App" \
			--yesno "$text_body" \
			10 40 
		rett=$?
		if [[ $rett -eq 1 ]]; then
			rm "${files[$ret]}"
		fi
		inbox
	fi
	if [[ -f $file_dec ]]; then
		rm -f $file_dec
	fi
}
