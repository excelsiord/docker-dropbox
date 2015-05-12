Bash script used to launch container:

    #!/bin/sh
    NAME="Dropbox"
    DBOX_UID=1024 # Synology admin account.
    DBOX_GID=100 # Synology users group.
    CONFIG="/volume1/docker/Dropbox/CONFIG"
    UPDATE="/volume1/docker/Dropbox/UPDATE"
    FILES="/volume1/docker/Dropbox/FILES"
    IMAGE="registry.hub.docker.com/excelsior/dropbox"

    mkdir -p $CONFIG > /dev/null 2>&1
    mkdir -p $UPDATE > /dev/null 2>&1
    mkdir -p $FILES > /dev/null 2>&1

    docker run -d \
    --name=$NAME \
    --net=\"host\" \
    -e DBOX_UID=$DBOX_UID \
    -e DBOX_GID=$DBOX_GID \
    -v $CONFIG:/dbox/.dropbox \
    -v $UPDATE:/dbox/.dropbox-dist \
    -v $FILES:/dbox/Dropbox \
    -v /etc/localtime:/etc/localtime:ro \
    $IMAGE
