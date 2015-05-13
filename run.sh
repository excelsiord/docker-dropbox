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
chown -R $DBOX_UID:$DBOX_GID /dbox

# Replace hostname in /etc/hosts
echo "$(grep -E '(localhost|::)' /etc/hosts)" > /etc/hosts
echo 127.0.0.1 $(hostname) >> /etc/hosts

# If dropbox is already extracted, run it. If not, extract then run.
if [ -f "/dbox/.dropbox-dist/dropboxd" ]; then
	echo "dropboxd($(cat /dbox/.dropbox-dist/VERSION)) started..."
	exec sudo -u dropbox /dbox/.dropbox-dist/dropboxd &
else
	tar -xzf /dbox/base/dropbox.tar.gz -C /dbox/
	chown -R $DBOX_UID:$DBOX_GID /dbox/.dropbox-dist
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
