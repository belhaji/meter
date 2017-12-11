# Install the app using the **install.sh** script

	# chmod +x install.sh && ./install.sh

# How to install the app manualy

1. create a group called email
	
	# groupadd email

2. add all the users that can use the app in this group **email**

	# useradd -G email <myuser>

3. modify the file /etc/sudoers and add the following line

	%email	ALL=(ALL:ALL) NOPASSWD:SETENV:   /opt/msger/email.sh

4. copy the app folder into /opt

	# cp -rf msger /opt/

5. copy the lancher **email** into /bin and make it executable

	# cp /opt/msger/email /bin && chmod +x /bin/email \
	&& chmod +x /opt/msger/email.sh

6. now everything is done you can run your app

	$ email

