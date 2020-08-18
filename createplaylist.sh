#!/bin/bash -
#===============================================================================
#
#          FILE: createplaylist.sh
#
#         USAGE: ./createplaylist.sh
#
#   DESCRIPTION: Created a playlist and ezstream config file for streaming to an icecast server.
#
#       OPTIONS: ---
#  REQUIREMENTS: ezstream, lame and icecast server.
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Erwin van Londen
#  ORGANIZATION:
#       CREATED: 11/08/20 14:55
#      REVISION:  ---
#===============================================================================

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

set -o nounset                              # Treat unset variables as an error
set -o noglob
umask 0127

_rootdir=/home/erwin/Music
_searchstring=""
_searchdir=${PWD}
_url="http://evlonden.no-ip.biz"
_port=8000
_base=stream
_infoname="MyMusic"
_infogenre=General
_infodesc="Music"
_infobitrate=96
_infopublic=1


# The username / password combination should be read from a file called "ezstream_unamepwd" in the _rootdir.
# Content of the file is just <username>:<password> format. If it doesn't exists it will be read during execution.
#

if [[ -f ${_rootdir}/ezstream_unamepwd ]]; then
    _uname=$(awk -F: '{print $1}' "${_rootdir}"/ezstream_unamepwd)
    _pwd=$(awk -F: '{print $2}' "${_rootdir}"/ezstream_unamepwd)
else
    read -i -e -p "Icecast server source username :" _uname
    read -i -e -p "Icecast server source password :" _pwd
fi

trap '
rm "${_rootdir}/${_playlist}"
rm "${_ezxml}"
' INT QUIT TERM PIPE HUP

xml() {
# Generate the new xml file to be used by ezstream
cat <<- EOF > ${_ezxml}
<ezstream>
    <url>${_url}:${_port}/${_base}/${_stream}</url>
    <sourceuser>${_uname}</sourceuser>
    <sourcepassword>${_pwd}</sourcepassword>
    <format>MP3</format>
    <filename>${_rootdir}/${_playlist}</filename>
    <metadata_format>@a@ - @t@</metadata_format>
    <svrinfoname>${_infoname}</svrinfoname>
    <svrinfogenre>${_infogenre}</svrinfogenre>
    <svrinfodescription>${_infodesc}</svrinfodescription>
    <svrinfobitrate>${_infobitrate}</svrinfobitrate>
    <svrinfopublic>${_infopublic}</svrinfopublic>
    <shuffle>1</shuffle>
    <stream_once>0</stream_once>

    <reencode>
        <enable>1</enable>
        <encdec>
            <format>MP3</format>
            <match>.mp3</match>
            <decode>lame --quiet --mp3input --decode @T@ "-"</decode>
            <encode>lame --quiet -m s -b 48 -B 128 --abr ${_infobitrate} --tt @t@ --ta @a@ "-"</encode>
        </encdec>
    </reencode>
</ezstream>
EOF
chmod 644 "${_ezxml}"
}

function playlist( ) {
find "${_searchdir}" -iname "${_searchstring}*.mp3" | sort -u -R | head -100 > "${_rootdir}/${_playlist}"
}

usage() {
cat <<- EOF
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
EOF
exit
}

if [[ $1 == "" ]]; then
    usage
fi

while getopts r:l:s:d:g:b:p:x:n: opt
do
    case ${opt} in
        r)
            if [[ "${OPTARG}" == "" ]]; then
                echo "Enter existing playlist"
                exit 1
                else
                _playlist="${OPTARG}".m3u
            fi
            playlist
            $(kill -HUP $(pgrep ezstream))
            exit 2
            ;;

        l)
            if [[ "${OPTARG}" -ne "${PWD}" ]]; then
                _searchdir="${OPTARG}"
            else
                _searchdir="${PWD}"
            fi
            ;;
        s) _searchstring="${OPTARG}" ;;
        d) _infodesc="${OPTARG}" ;;
        g) _infogenre="${OPTARG}" ;;
        n) _infoname="${OPTARG}" ;;
        b) _infobitrate="${OPTARG}" ;;
        p) _playlist="${OPTARG}".m3u ; _xmlfile="${OPTARG}".xml ; _stream="${OPTARG}";;
        ?) usage ;;
        *) usage ;;
    esac
done

if [[ -z ${_infodesc} || -z ${_infogenre} || -z ${_infoname} || -z ${_infobitrate} || -z ${_playlist} || -z ${_xmlfile} || -z ${_stream} ]]; then
    usage
fi


# Generate the xml file.
_ezxml=${_rootdir}/${_xmlfile}
xml

if [[ -n $(pgrep ezstream) ]]; then
    playlist
    sleep 2
    kill -HUP $(pgrep ezstream)
else
    playlist 
    echo -e "\n Put your browser to url : ${_url}:${_port}/${_base}/${_stream}"
    $(which ezstream) -c "${_ezxml}"
fi




