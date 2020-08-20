[![](https://images.microbadger.com/badges/image/traceflight/mopidy.svg)](http://microbadger.com/images/traceflight/mopidy "Get your own image badge on microbadger.com")

What is Mopidy?
===============

[**Mopidy**](https://www.mopidy.com/) is a music server with support for [MPD clients](https://docs.mopidy.com/en/latest/clients/#mpd-clients) and [Web clients](https://docs.mopidy.com/en/latest/clients/#web-clients).

Features of this image
----------------------

  * Follows [official installation](https://docs.mopidy.com/en/latest/installation/debian/) on top of [Debian](https://registry.hub.docker.com/_/debian/).
  * With [Mopidy-MusicBox-Webclient](https://mopidy.com/ext/musicbox-webclient/) web extension.
  * Can run as any user and runs as UID/GID `84044` user inside the container by default (for security reasons).

You may install additional [backend extensions](https://docs.mopidy.com/en/latest/ext/backends/).


Usage
-----

### Playing sound from the container

There are various ways to have the audio from Mopidy running in your container
to play on your system's audio output. Here are various ways, try them and find
which one works for you.

#### /dev/snd

Simplest is by adding docker argument: `--device /dev/snd`. Try via:

    $ docker run --rm \
        --user root --device /dev/snd \
        traceflight/mopidy

### General usage

    $ docker run -d \
        $PUT_HERE_EXRA_DOCKER_ARGUMENTS_FOR_AUDIO_TO_WORK \
        -v "$PWD/media:/var/lib/mopidy/media:ro" \
        -v "$PWD/local:/var/lib/mopidy/local" \
        -p 6600:6600 -p 6680:6680 \
        --user $UID:$GID \
        traceflight/mopidy

Most arguments are optional (see some examples below):

  * Docker arguments:
      * `$PUT_HERE_EXRA_DOCKER_ARGUMENTS_FOR_AUDIO_TO_WORK` should be replaced
        with some arguments that work to play audio from within the docker
        container as tested above.
      * `-v ...:/var/lib/mopidy/media:ro` - (optional) Path to directory with local media files.
      * `-v ...:/var/lib/mopidy/local` - (optional) Path to directory to store local metadata such as libraries and playlists in.
      * `-p 6600:6600` - (optional) Exposes MPD server (if you use for example ncmpcpp client).
      * `-p 6680:6680` - (optional) Exposes HTTP server (if you use your browser as client).
      * `-p 5555:5555/udp` - (optional) Exposes [UDP streaming for FIFE sink](https://github.com/mopidy/mopidy/issues/775) (e.g. for visualizers).
      * `--user $UID:$GID` - (optional) You may run as any UID/GID, and by default it'll run as UID/GID `84044` (`mopidy:audio` from within the container).
        The main restriction is if you want to read local media files: That the user (UID) you run as should have read access to these files.
        Similar for other mounts. If you have issues, try first as `--user root`.


##### Example using HTTP client to stream local files

 1. Give read access to your audio files to user **84044**, group **84044**, or all users (e.g., `$ chgrp -R 84044 $PWD/media && chmod -R g+rX $PWD/media`).
 2. Index local files:

        $ docker run --rm \
            --device /dev/snd \
            -v "$PWD/media:/var/lib/mopidy/media:ro" \
            -v "$PWD/local:/var/lib/mopidy/local" \
            -p 6680:6680 \
            traceflight/mopidy mopidy local scan

 3. Start the server:

        $ docker run -d \
            --device /dev/snd \
            -v "$PWD/media:/var/lib/mopidy/media:ro" \
            -v "$PWD/local:/var/lib/mopidy/local" \
            -p 6680:6680 \
            traceflight/mopidy

 4. Browse to http://localhost:6680/



