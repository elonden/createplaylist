# EzStream Playlist

So now and then you just want to be able to randomly run through your MP3 collection and stream it to your icecast server so you can listen to it all day on all your devices that can pull it via a http stream

This script does just that. I know, I know. many more options but i just wanted something simple

## Prereq

* A working icecast server. If your router runs OpenWRT it's fairly easy as a simple "opkg install icecast" does the work. Adjust a few parameters in the icecast.conf (usernames and passwords being the first one !!!!)
* ezstream installed. Most distros provide a yum/dnf/apt option to pull this out of a repo
* lame (mpeg decoder/encoder) If you have mp3 that are encoded on a very high bitrate you sometimes run into bandwidth issues either streaming to or from the icecast server. The ezstream client provides an option to decode and encode in a single go on a lower bitstream with some parameters that get set dynamically.

## Command usage

Use the following parameters to adjust files and a few options (# = optional)
    -l = search location (#)
    -s = search string (#)
    -d = description for the stream
    -g = genre
    -b = bitrate (Average stream bitrate between 48 and 128 in 16bit increments. Default 96)
    -p = playlist name (Do not provide an extention)
    -n = Server name
    -r = Create a new playlist and reread without exiting the server
    -o = stream after the url base "Use artist or a short indicator like 'mymusic'"

## Assumptions

* All music sits in the "_rootdir". That is where the playlist and ezstream xml config get stored. Adjust to your liking
* icecast server and password are stored on a single line in the "_rootdir/ezstream_unamepwd" file in the format of \<username\>:\<password\>
* If the file does not exists it'll prompt for the username and password.
* Be aware these are the icecast source credentials and not the admin ones.

## Public / Private

By default the stream does get published if your icecast server is configured to do so. An example is "http://dir.xiph.org/". The "_infopublic=1" variable instruct the icecast server to publish the stream. If that vaiable is set to "0" it will not publish the stream.

