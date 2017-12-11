# initial setup of the script
# - create mail dirs, keys dir
# - import new keys
# - compress old messages ( > 24h )
function setup {
	# create the initial mail dir
	if [[ ! -d $MAIL_DIR ]]; then
		mkdir -p $MAIL_DIR
		chmod 700 $MAIL_DIR
	fi

	# create the user dir
	if [[ ! -d $MAIL_USER_DIR ]]; then
		create_user_mail_dir $USER
	fi
	# create keys dir and set the sticky bit
	if [[ ! -d $KEYS_DIR ]]; then
		mkdir -p $KEYS_DIR
		chgrp email $KEYS_DIR
		chmod 1770 $KEYS_DIR
	fi
	#import new keys
	gpg --homedir "/root/.gnupg" --import /var/keys/*.key > /dev/null

	# compress old messages
	encrypt_msgs_for_user
}
