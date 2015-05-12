FROM debian:jessie
ENV DEBIAN_FRONTEND noninteractive

# Download & install required applications: curl, sudo.
RUN apt-get -qqy update
RUN apt-get -qqy install curl sudo

# Download & install current version of dropbox.
RUN mkdir -p /opt/dropbox
RUN curl --silent -L "https://www.dropbox.com/download?plat=lnx.x86_64" | tar -xzf - --strip-components=1 -C /opt/dropbox

# Perform image clean up.
RUN apt-get -qqy purge curl
RUN apt-get -qqy autoremove
RUN dpkg -l | grep ^rc | awk '{print $2}' | xargs dpkg -P
RUN apt-get -qqy autoclean

# Create service account and set permissions.
RUN useradd -d /dbox -c "Dropbox Daemon Account" -s /usr/sbin/nologin dropbox
RUN chown -R dropbox /opt/dropbox
RUN mkdir -p /dbox/.dropbox /dbox/.dropbox-dist /dbox/Dropbox
RUN chown -R dropbox /dbox

# Install script for managing dropbox init.
COPY run_dropbox.sh /opt/dropbox/
RUN chmod +x /opt/dropbox/run_dropbox.sh

VOLUME ["/dbox/.dropbox", "/dbox/.dropbox-dist", "/dbox/Dropbox"]

# Dropbox Lan-sync
EXPOSE 17500

CMD ["/opt/dropbox/run_dropbox.sh"]
