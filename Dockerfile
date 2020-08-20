FROM debian:buster

ADD ./etc/sources.list /etc/apt/sources.list

RUN set -ex \
    # Official Mopidy install for Debian/Ubuntu along with some extensions
    # (see https://docs.mopidy.com/en/latest/installation/debian/ )
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
       wget \
       dumb-init \
       gnupg \
       python3-pip \
    # Clean-up
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache

ADD ./etc/upmpdcli.list /etc/apt/sources.list.d/upmpdcli.list

RUN set -ex \
 && wget -q -O - https://apt.mopidy.com/mopidy.gpg | apt-key add - \
 && wget -q -O /etc/apt/sources.list.d/mopidy.list https://apt.mopidy.com/buster.list \
 && wget -q -O - https://www.lesbonscomptes.com/pages/jf-at-dockes.org.pgp | apt-key add - \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        mopidy \
        mopidy-mpd \
        upmpdcli \
 && python3 -m pip install Mopidy-MusicBox-Webclient Mopidy-Local\
 # Clean-up
 && apt-get purge --auto-remove -y \
        gcc \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache

ADD ./etc/upmpdcli.conf /etc/upmpdcli.conf

RUN set -ex \
 && mkdir -p /var/lib/mopidy/.config \
 && ln -s /config /var/lib/mopidy/.config/mopidy

# Start helper script.
COPY entrypoint.sh /entrypoint.sh

# Default configuration.
COPY ./etc/mopidy.conf /config/mopidy.conf

# Allows any user to run mopidy, but runs by default as a randomly generated UID/GID.
ENV HOME=/var/lib/mopidy
RUN set -ex \
 && usermod -G audio,sudo mopidy \
 && chown mopidy:audio -R $HOME /entrypoint.sh \
 && chmod go+rwx -R $HOME /entrypoint.sh

# Runs as mopidy user by default.
USER mopidy

# Basic check,
RUN /usr/bin/dumb-init /entrypoint.sh /usr/bin/mopidy --version

VOLUME ["/var/lib/mopidy/local", "/var/lib/mopidy/media", "/var/lib/mopidy/playlists"]

# 6600 mpd, 6680 http, 5555 audio ouput, 7777 dlna
EXPOSE 6600 6680 5555/udp 7777

ENTRYPOINT ["/usr/bin/dumb-init", "/entrypoint.sh"]
CMD ["/usr/bin/mopidy"]

HEALTHCHECK --interval=5s --timeout=2s --retries=20 \
    CMD curl --connect-timeout 5 --silent --show-error --fail http://localhost:6680/ || exit 1
