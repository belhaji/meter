# check if the user mail directory exists
function user_mail_dir_exists {
	if [[ -d "$MAIL_DIR/$1" ]]; then
		return 0
	fi
	return 1
}

# creates user mail sub-directories (Inbox, Sent and Attachments)
function create_user_mail_dir {
	mkdir -p "$MAIL_DIR/$1/Inbox"
	mkdir -p "$MAIL_DIR/$1/Sent"
	mkdir -p "$MAIL_DIR/$1/Attachments"
}

function compress_msgs_for_user {
	# find a all files that not modified more than 1440min (24h)
	# in our case the modification time = creation time because 
	# we don't modify messages after the send operation
	find $MAIL_USER_DIR ! -name "*.gz" -mmin +1440 -type f -exec gzip {} \; 
}

# get all users that have a home directory in /home and there uid greater than
# or equal to 1000 (regular users only not system ones)
function get_user_list {
	awk -F: '/\/home/ && ($3 >= 1000) {printf "%s ",$1}' /etc/passwd
}