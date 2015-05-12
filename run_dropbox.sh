#!/bin/sh

# Set UID/GID if not provided with enviromental variable(s).
if [ -z "$DBOX_UID" ]; then
	DBOX_UID=$(cat /etc/passwd | grep dropbox | cut -d: -f3)
	echo "DBOX_UID (user id) variable not specified, defaulting to $DBOX_UID.."
fi

if [ -z "$DBOX_GID" ]; then
	DBOX_GID=$(cat /etc/group | grep dropbox | cut -d: -f3)
	echo "DBOX_GID (group id) variable not specified, defaulting to $DBOX_GID.."
fi

# Look for existing group, if not found create dropbox with specified GID.
FIND_GROUP=$(grep ":$DBOX_GID:" /etc/group)

if [ -z "$FIND_GROUP" ]; then
	usermod -g users dropbox
	groupdel dropbox
	groupadd -g $DBOX_GID dropbox
fi

# Set dropbox account's UID.
usermod -u $DBOX_UID -g $DBOX_GID dropbox > /dev/null 2>&1

# Change ownership to dropbox account on all working folders.
chown -R $DBOX_UID:$DBOX_GID /opt/dropbox /dbox

# Replace hostname in /etc/hosts
echo "$(grep -E '(localhost|::)' /etc/hosts)" > /etc/hosts
echo 127.0.0.1 $(hostname) >> /etc/hosts

# If updated dropboxd exists, run it, if not run default.
if [ ! -f "/dbox/.dropbox-dist/dropboxd" ]; then
	echo "dropboxd($(cat /opt/dropbox/VERSION)) started..."
	sudo -u dropbox /opt/dropbox/dropboxd &
else
	echo "dropboxd($(cat /dbox/.dropbox-dist/VERSION)) started..."
	exec sudo -u dropbox /dbox/.dropbox-dist/dropboxd &
fi

# Pass SIGTERM to daemon when container gets stopped.
trap "kill -TERM $!" TERM
wait 

# Print error if encountered.
FIND_ERROR=$(find /tmp -type f -name dropbox_error* | grep -o dropbox_error)
if [ ! -z "$FIND_ERROR" ]; then
	echo "dropboxd stopped, with errors:"
	cat /tmp/dropbox_error*
        rm -rf /tmp/dropbox_error*
else
	echo "dropboxd stopped, no errors."
fi
