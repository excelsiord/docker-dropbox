1. Install Docker.
2. Paste below script somewhere on the backend.
  *  (```optional```): Update DBOX_UID, DBOX_GID and paths for APP, CONFIG and FILES.
3. Execute below script.

Bash script used to launch container, for first time setup check log after starting container:

    #!/bin/sh
    NAME="Dropbox"
    DBOX_UID=1024 # Synology admin account.
    DBOX_GID=100 # Synology users group.
    APP="/volume1/docker/Dropbox/APP"
    CONFIG="/volume1/docker/Dropbox/CONFIG"
    FILES="/volume1/docker/Dropbox/FILES"
    IMAGE="registry.hub.docker.com/excelsior/dropbox"

    mkdir -p $APP > /dev/null 2>&1
    mkdir -p $CONFIG > /dev/null 2>&1
    mkdir -p $FILES > /dev/null 2>&1

    docker run -d \
    --name=$NAME \
    --net=\"host\" \
    -e DBOX_UID=$DBOX_UID \
    -e DBOX_GID=$DBOX_GID \
    -v $APP:/dbox/.dropbox-dist \
    -v $CONFIG:/dbox/.dropbox \
    -v $FILES:/dbox/Dropbox \
    -v /etc/localtime:/etc/localtime:ro \
    $IMAGE

For Synology users, exclude @eadir after dropbox is running and linked:

    docker exec -t Dropbox sudo -u dropbox /dbox/dropbox.py exclude add /dbox/Dropbox/\@eadir/
