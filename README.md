
What is Mopidy?
===============

[**Mopidy**](https://www.mopidy.com/) is a music server with support for [MPD clients](https://docs.mopidy.com/en/latest/clients/#mpd-clients) and [Web clients](https://docs.mopidy.com/en/latest/clients/#web-clients).

Features of this image
----------------------

  * Follows [official installation](https://docs.mopidy.com/en/latest/installation/debian/) on top of [Debian](https://registry.hub.docker.com/_/debian/).
  * With [Mopidy-MusicBox-Webclient](https://mopidy.com/ext/musicbox-webclient/) web extension.
  * With [upmpdcli](https://www.lesbonscomptes.com/upmpdcli/) to support DLNA.

You may install additional [backend extensions](https://docs.mopidy.com/en/latest/ext/backends/).


Usage
-----

### Setup pulseaudio on host machine

Since I run mopidy on my home server. No multi-user feature is used. So I run pulseaudio in [system-wide mode](https://www.freedesktop.org/wiki/Software/PulseAudio/Documentation/User/SystemWide/). 

#### Install pulseaudio

On Centos:

```
sudo yum install pulseaudio
```

#### Setup pulseaudio

Add following settings to `/etc/pulse/system.pa` to enable tcp service. So palseaudio client in docker can connect to the daemon over the network.

```
.ifexists module-esound-protocol-tcp.so
load-module module-esound-protocol-tcp auth-anonymous=1
.endif
load-module module-native-protocol-tcp auth-anonymous=1
```

#### Start pulseaudio

```
/usr/bin/pulseaudio --daemonize=no --realtime --system --disallow-exit
```

### Run mopidy in docker

    $ docker run -d \
        -v "$PWD/media:/var/lib/mopidy/media" \
        -v "$PWD/playlists:/var/lib/mopidy/playlists" \
        -v "$PWD/local:/var/lib/mopidy/local" \
        -v "$PWD/etc/mopidy.conf:/config/mopidy.conf" \
        -v "$PWD/etc/upmpdcli.conf:/etc/upmpdcli.conf" \
        -e "PULSE_SERVER=127.0.0.1" \
        --net host \
        --user root \
        traceflight/mopidy

Most arguments are optional (see some examples below):

  * Docker arguments:
      * `-v ...:/var/lib/mopidy/media` - (optional) Path to directory with local media files.
      * `-v ...:/var/lib/mopidy/local` - (optional) Path to directory to store local metadata such as libraries and playlists in.
      * `-v ...:/var/lib/mopidy/playlists` - (optional) Path to directory to store local playlists.
      * `-v ...:/config/mopidy.conf` - (optional) Path to mopidy configuration.
      * `-v ...:/upmpdcli.conf` - (optional) Path to upmpdcli configuration.
      * `-e "PULSE_SERVER=127.0.0.1"` - (required) Setting of pulse server.
      * `--user root` - (required).
      * `--net host` - (required).

### Test

Run this comman in docker:

```
gst-launch-1.0 audiotestsrc ! autoaudiosink
```

Make sure you can hear sound.
