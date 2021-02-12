#!/bin/bash
	#############################################################################{{{
	###########################################################################
	###                          bashttpd v 1.12
	###
	### Original author: Avleen Vig,       2012
	### Reworked by:     Josh Cartwright,  2012
	### Modified by:     A.M.Danischewski, 2015
	### Issues: If you find any issues leave me a comment at
	### http://scriptsandoneliners.blogspot.com/2015/04/bashttpd-self-contained-bash-webserver.html
	###
	### This is a simple Bash based webserver. By default it will browse files and allows for
	### retrieving binary files.
	###
	### It has been tested successfully to view and stream files including images, mp3s,
	### mp4s and downloading files of any type including binary and compressed files via
	### any web browser.
	###
	### Successfully tested on various browsers on Windows, Linux and Android devices (including the
	### Android Smartwatch ZGPAX S8).
	###
	### It handles favicon requests by hardcoded favicon image -- by default a marathon
	### runner; change it to whatever you want! By base64 encoding your favorit favicon
	### and changing the global variable below this header.
	###
	### Make sure if you have a firewall it allows connections to the port you plan to
	### listen on (8080 by default).
	###
	### By default this program will allow for the browsing of files from the
	### computer where it is run.
	###
	### Make sure you are allowed connections to the port you plan to listen on
	### (8080 by default). Then just drop it on a host machine (that has bash)
	### and start it up like this:
	###
	### $192.168.1.101> bashttpd -s
	###
	### On the remote machine you should be able to browse and download files from the host
	### server via any web browser by visiting:
	###
	### http://192.168.1.101:8080
	###
	#### This program requires (to work to full capacity) by default:
	### socat or netcat (w/ '-e' option - on Ubuntu netcat-traditional)
	### tree - useful for pretty directory listings
	### If you are using socat, you can type: bashttpd -s
	###
	### to start listening on the LISTEN_PORT (default is 8080), you can change
	### the port below.
	###  E.g.    nc -lp 8080 -e ./bashttpd ## <-- If your nc has the -e option.
	###  E.g.    nc.traditional -lp 8080 -e ./bashttpd
	###  E.g.    bashttpd -s  -or- socat TCP4-LISTEN:8080,fork EXEC:bashttpd
	###
	### Copyright (C) 2012, Avleen Vig <avleen@gmail.com>
	###
	### Permission is hereby granted, free of charge, to any person obtaining a copy of
	### this software and associated documentation files (the "Software"), to deal in
	### the Software without restriction, including without limitation the rights to
	### use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
	### the Software, and to permit persons to whom the Software is furnished to do so,
	### subject to the following conditions:
	###
	### The above copyright notice and this permission notice shall be included in all
	### copies or substantial portions of the Software.
	###
	### THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	### IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
	### FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
	### COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
	### IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
	### CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
	###
	###########################################################################
	#############################################################################}}}
# 	. /home/Progs/bashruntime.sh
. CGIBa.sh

 ## If you are on AIX, IRIX, Solaris, or a hardened system redirecting to /dev/random will probably break, you can change it to /dev/null.
 declare -ag DUMP_DEV="/dev/random" \
  RESPONSE_HEADERS=( #{{{
 "Date: $DATE"
 "Expires: $DATE"
 "Server: Slash Bin Slash Bash"
 ) REQUEST_HEADERS
#}}}

 declare -Ag HTTP_RESPONSE=(
 [200]="OK" #{{{
 [400]="Bad Request"
 [403]="Forbidden"
 [404]="Not Found"
 [405]="Method Not Allowed"
 [500]="Internal Server Error"
	) _REQUEST_HEADERS _GET _POST #}}}
 declare REQUEST_URI="" \
  DATE=$(date +"%a, %d %b %Y %H:%M:%S %Z")\
  QUERY_STRING POST_DATA REQUEST_METHOD

	## Just base64 encode your favorite favicon and change this to whatever you want.{{{
	declare -r FAVICON="AAABAAEAEBAAAAEAIABoBAAAFgAAACgAAAAQAAAAIAAAAAEAIAAAAAAAAAQAAMIOAADCDgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAxLXMAKCI9Aj88li05OK6UPDu35x0cp+YMC6GRGxmWK2RcWgI1MYQAAAAAAAAAAAAAAAAAAAAAACIdfQAFAEwBPTqVIzo5rXwsK7/XFBTO/B4dxf8JCav/AACp/AQEptUPDaB5HBiWIUA8hQEnI5IAAAAAAAAAXAE7OJMeOTirdSwrvtQWFc38BATU/wAA1f8YGMT/CQmr/yQkr/8nJ7H/AQOo+wcJpdEOC6FyHhyUHVFJdgFCQKRdMjG8zBkZzPsFBdT/AADU/wAA1P8AANX/GRjF/xERrP96esH/iYjK/xInpP8OQpD/Bxih+ggGpsoVE5xZMjG96goK0/8AANT/AADU/wAA1P8AANT/AADV/xkYxf8NDav/VFS5/7Oy1v8+QbL/BiKb/wcenP8AAKv/Bgam6Cgoxf8AANX/AADU/wAA1P8AANT/AADU/wAA1f8YF8T/FhWt/5+ez/+Fhcv/GBit/wAAqv8AAKr/AACq/wEBqP8mJsP/AADU/wAA1P8AANT/AADU/wAA1P8AANX/GRjE/wgIqv9YWLr/k5PL/w8OrP8AAKr/AACq/wAAqv8BAaf/JSTD/wAA1P8AANT/AADU/wAA1P8AANT/AADU/xsbyf8TE63/ERCq/ywssf8CAqr/AACq/wAAqv8AAKr/AQGn/yUkwv8AANT/AADU/wAA1P8AANT/AADU/wAA1P8HB9P/IyPE/xwcsv8GBqr/AACq/wAAqv8AAKr/AACq/wEBp/8mJsP/AADU/wAA1P8AANT/AADU/wAA1P8AANT/AADU/wMD1P8VFM//JCPA/xgXsP8FBar/AACq/wAAqv8BAaj/KinE/wAA1P8AANT/AADU/wAA1P8AANT/AADU/wAA1P8AANT/AADU/wQE1P8WFs3/IyO9/xUUrv8DA6r/AQGo/zIyvvIHB9T/AADU/wAA1P8AANT/AADU/wAA1P8AANT/AADU/wAA1P8AANT/AADU/wcH1P8aGsz/Jia8/ycnq/BEQqp3Ly7C4BMTz/4DA9T/AADU/wAA1P8AANT/AADU/wAA1P8AANT/AADU/wAA1P8CAtT/ExPP/jQzwN5IR6ZxJCFkBEE/nDE+PbKTLCzE5RIS0P8CAtT/AADU/wAA1P8AANT/AADU/wMD1P8TEtD+KSjD4zo5sY8/PZsvHBpeAwAAAAA+O4YANDJ2BkE/nzc6ObOZKinF6BER0f8CAtT/AgLU/xIR0P4qKcTmOjmzlUA9nTQ0MXIFPTqDAAAAAAAAAAAAAAAAAAAAAAA8OYsAMi9/CD89oEY6ObW1KyrF+yoqxfo4N7SxPjyfQjMwfQc8OooAAAAAAAAAAAAAAAAA8A8AAMADAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADAAwAA8A8AAA=="
	### CHANGE THIS TO WHERE YOU WANT THE CONFIGURATION FILE TO RESIDE #}}}
	declare -r BASHTTPD_CONF="/home/Progs/bashttpd/bashttpd.conf"\
	FAVICON_LINK="<link href=\"data:image/x-icon;base64,${FAVICON}\" rel=\"icon\" type=\"image/x-icon\"/>"\
	MAX_UPLOAD_SIZE=1024000 UPLOADDIR=/tmp

warn(){ ((${VERBOSE})) && echo "WARNING: $@" >&2; }

chk_conf_file() {
		[ -r "${BASHTTPD_CONF}" ] || { #{{{
			cat >"${BASHTTPD_CONF}" <<'EOF'
#
# bashttpd.conf - configuration for bashttpd
#
# The behavior of bashttpd is dictated by the evaluation
# of rules specified in this configuration file.  Each rule
# is evaluated until one is matched.  If no rule is matched,
# bashttpd will serve a 500 Internal Server Error.
#
# The format of the rules are:
#    on_uri_match REGEX command [args]
#    unconditionally command [args]
#
# on_uri_match:
#   On an incoming request, the URI is checked against the specified
#   (bash-supported extended) regular expression, and if encounters a match the
#   specified command is executed with the specified arguments.
#
#   For additional flexibility, on_uri_match will also pass the results of the
#   regular expression match, ${BASH_REMATCH[@]} as additional arguments to the
#   command.
#
# unconditionally:
#   Always serve via the specified command.  Useful for catchall rules.
#
# The following commands are available for use:
#
#   serve_file FILE
#     Statically serves a single file.
#
#   serve_dir_with_tree DIRECTORY
#     Statically serves the specified directory using 'tree'.  It must be
#     installed and in the PATH.
#
#   serve_dir_with_ls DIRECTORY
#     Statically serves the specified directory using 'ls -al'.
#
#   serve_dir  DIRECTORY
#     Statically serves a single directory listing.  Will use 'tree' if it is
#     installed and in the PATH, otherwise, 'ls -al'
#
#   serve_dir_or_file_from DIRECTORY
#     Serves either a directory listing (using serve_dir) or a file (using
#     serve_file).  Constructs local path by appending the specified root
#     directory, and the URI portion of the client request.
#
#   serve_static_string STRING
#     Serves the specified static string with Content-Type text/plain.
#
# Examples of rules:
#
# on_uri_match '^/issue$' serve_file "/etc/issue"
#
#   When a client's requested URI matches the string '/issue', serve them the
#   contents of /etc/issue
#
# on_uri_match 'root' serve_dir /
#
#   When a client's requested URI has the word 'root' in it, serve up
#   a directory listing of /
#
# DOCROOT=/var/www/html
# on_uri_match '/(.*)' serve_dir_or_file_from "$DOCROOT"
#   When any URI request is made, attempt to serve a directory listing
#   or file content based on the request URI, by mapping URI's to local
#   paths relative to the specified "$DOCROOT"
#
#unconditionally serve_static_string 'Hello, world!  You can configure bashttpd by modifying bashttpd.conf.'
DOCROOT=$(pwd)
on_uri_match '/(.*)' serve_dir_or_file_from
# More about commands:
#
# It is possible to somewhat easily write your own commands.  An example
# may help.  The following example will serve "Hello, $x!" whenever
# a client sends a request with the URI /say_hello_to/$x:
#
serve_hello() {
   add_response_header "Content-Type" "text/plain"
   send_response_ok_exit <<< "Hello, $2!"
}
on_uri_match '^/say_hello_to/(.*)$' serve_hello
#
# Like mentioned before, the contents of ${BASH_REMATCH[@]} are passed
# to your command, so its possible to use regular expression groups
# to pull out info.
#
# With this example, when the requested URI is /say_hello_to/Josh, serve_hello
# is invoked with the arguments '/say_hello_to/Josh' 'Josh',
# (${BASH_REMATCH[0]} is always the full match)
EOF
	warn "Created bashttpd.conf using defaults.  Please review and configure bashttpd.conf before running bashttpd again."
	#  exit 1
	}
} #}}}

recv(){ ((${VERBOSE})) && echo "< $@" >&2; }

send(){ ((${VERBOSE})) && echo "> $@" >&2; echo "$*"; }

add_response_header(){ RESPONSE_HEADERS+=("$1: $2"); }

send_response_binary(){
	local code="$1" #{{{
	local file="${2}"
	local transfer_stats=""
	local tmp_stat_file="/tmp/_send_response_$$_"
	send "HTTP/1.0 $1 ${HTTP_RESPONSE[$1]}"
	debug $FUNCNAME:file=$file:$1:HTTP_RESPONSE=${HTTP_RESPONSE[$1]}:"${RESPONSE_HEADERS[@]}":
	for i in "${RESPONSE_HEADERS[@]}"; do
		send "$i"
	done
	send
	if ((${VERBOSE})); then
		## Use dd since it handles null bytes
		dd 2>"${tmp_stat_file}" < "${file}"
		transfer_stats=$(<"${tmp_stat_file}")
		echo -en ">> Transferred: ${file}\n>> $(awk '/copied/{print}' <<< "${transfer_stats}")\n" >&2
		rm "${tmp_stat_file}"
	else
		## Use dd since it handles null bytes
		dd 2>"${DUMP_DEV}" < "${file}"
	fi
} #}}}send_response_binary

send_redirect(){
	local code="$1" #{{{
	send "HTTP/1.0 $1 ${HTTP_RESPONSE[$1]}"
	for i in "${RESPONSE_HEADERS[@]}"; do
		send "$i"
	done
	send
} #}}}send_redirect

send_response(){
	local code="$1" #{{{
	send "HTTP/1.0 $1 ${HTTP_RESPONSE[$1]}"
	for i in "${RESPONSE_HEADERS[@]}"; do
		send "$i"
	done
	send
	while IFS= read -r line; do
		send "${line}"
	done
} #}}}

send_response_ok_exit(){ send_response 200; exit 0; }

send_response_location_exit(){ add_response_header 'Location' "$1";  send_redirect 301; exit 0; }

send_response_ok_exit_binary(){ send_response_binary 200  "${1}"; exit 0; }

fail_with(){ send_response "$1" <<< "$1 ${HTTP_RESPONSE[$1]}"; exit 1; }

serve_file() {
	#{{{
	local file="$1" funcname\
	 CONTENT_TYPE='' PROC
	case "${file}" in
		*.css)
			CONTENT_TYPE="text/css"
			;;
		*.ico)
			CONTENT_TYPE="image/x-icon"
			;;
		*.txt)
			CONTENT_TYPE="text/plain"
			;;
		*.sh*|*.sh?\?=*|*.cgi*)
			CONTENT_TYPE="text/html"
			PROC=cgi
			file=${file%%\?*}
			funcname=${file%%.*}
			;;
		*.text|*.md)
			CONTENT_TYPE="text/html"
			PROC=markdown
			;;
		*.js)
			CONTENT_TYPE="text/javascript"
			;;
		*)
			CONTENT_TYPE=$(file -b --mime-type "${file}")
# 			debug serve_file :@=$@:file=$file:${BASH_REMATCH[@]}:BR1=${BASH_REMATCH[1]}:ARG1=${1}:ARG2=${2}:
			# CONTENT_TYPE="application/octet-stream"
			;;
	esac
# 	[ "$PROC" != cgi ] &&
		add_response_header 'Content-Type'  "${CONTENT_TYPE}"
# 	CONTENT_LENGTH=$(stat -c'%s' "${file}")
# 	add_response_header "Content-Length" "${CONTENT_LENGTH}"
	case $PROC in
		markdown)
			markdown "${file}" |send_response_ok_exit  ;;
		cgi)
			source "${file}"
			[[ "$(LC_ALL=C type -t ${funcname}main)" == 'function' ]] && {
				[[ -n ${_GET[postdat]} ]] && {
					POST_DATA=${_GET[postdat]}
					parsePOST
				}
				"${funcname}main" |send_response_ok_exit

			} || {
				"${funcname}sendpost"
			}
			;;
		*)
			# add_response_header "Content-Disposition: attachment"
			send_response_ok_exit_binary "${file}" ;;
	esac
:<<'CMNT'
	{{{

serve_cgi_file() {
	#{{{
	local file="$1"\
	CONTENT_TYPE="" PROC=cgi
	case "${file}" in
		*.cgi|*.sh|*\.sh)
			CONTENT_TYPE="text/html"
			PROC=cgi
			;;
		*)
			CONTENT_TYPE=$(file -b --mime-type "${file}")
			# CONTENT_TYPE="application/octet-stream"
			;;
	esac
	add_response_header "Content-Type"  "${CONTENT_TYPE}"
# 	CONTENT_LENGTH=$(stat -c'%s' "${file}")
# 	add_response_header "Content-Length" "${CONTENT_LENGTH}"
	## Use binary safe transfer method since text doesn't break.
	case $PROC in
# 		markdown)
# 			markdown "${file}" |send_response_ok_exit  ;;
		cgi|*)
			"${file}" |send_response_ok_exit  ;;
		*)
			# add_response_header "Content-Disposition: attachment"
			send_response_ok_exit_binary "${file}" ;;
	esac
} #}}}

}}}
CMNT
} #}}}serve_file

serve_dir_with_tree() {
	local dir="$1" tree_vers tree_opts basehref x #{{{
	## HTML 5 compatible way to avoid tree html from generating favicon
	## requests in certain browsers, such as browsers in android smartwatches. =)
	local tree_page="" \
	 base_server_path="${2%*/}"
	[ "$base_server_path" = "/" ] && base_server_path=".."
	local tree_opts="--du -h -a --dirsfirst"
	add_response_header "Content-Type" "text/html"
	# The --du option was added in 1.6.0.   "/${2%/*}"
	read _ tree_vers x < <(tree --version)
	tree_page=$(tree -H "$base_server_path" -L 1 "${tree_opts}" -D "${dir}")
	tree_page=$(sed "5 i ${FAVICON_LINK}" <<< "${tree_page}")
# 	[[ "${tree_vers}" == v1.6* ]]
	send_response_ok_exit <<< "${tree_page}"
} #}}}

serve_dir_with_ls() {
	#{{{
	add_response_header "Content-Type" "text/html"
	 dir="$1"
	send_response_ok_exit < <(cat <<EOF
<!DOCTYPE html>
<html lang="en">
	<head>
	<title>~$USER on bashttpd</title>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	${FAVICON_LINK}
	</head>
<body id="body" class="dark-mode">
<pre>
$(ls -latr "${dir}/")
</pre>
</body>
</html>
EOF
)
return 0
	} #}}}

serve_dir() {
	local dir="$1" #{{{
	# If `tree` is installed, use that for pretty output.
	which tree &>"${DUMP_DEV}" && \
		serve_dir_with_tree "$@"

	 serve_dir_with_ls "$@"
	#fail_with 500
} #}}}

urldecode(){
		[ "${1%/}" = "" ] && echo "/" ||  echo -e "$(sed 's/%\([[:xdigit:]]\{2\}\)/\\\x\1/g' <<< "${1%/}")"; #{{{
} #}}}

serve_dir_or_file_from(){
	local URL_PATH="${1}/${3}" ext='text' #{{{
	shift
	URL_PATH=$(urldecode "${URL_PATH}")
	[[ $URL_PATH == *..* ]] && fail_with 400
	# Serve index file if exists in requested directory
	for ext in 'md' 'text' 'txt' 'html'; do
		[[ -d "${URL_PATH}" && -e "${URL_PATH}/index.$ext" && -r "${URL_PATH}/index.$ext" ]] && \
			URL_PATH="${URL_PATH}/index.$ext"
	done
	if [[ -f "${URL_PATH}" ]]; then
		[[ -r "${URL_PATH}" ]] && \
			serve_file "${URL_PATH}" "$@" || fail_with 403
	elif [ -d "${URL_PATH}" -o -L "${URL_PATH}"  ]; then
		[[ -x "${URL_PATH}" ]] && \
			serve_dir  "${URL_PATH}" "$@" || fail_with 403
	fi
	fail_with 404
} #}}}

serve_static_string(){
	add_response_header "Content-Type" "text/plain" #{{{
	send_response_ok_exit <<< "$1"
} #}}}

unconditionally(){ "$@" "$REQUEST_URI"; }

on_uri_match() {
	local regex="$1" key #{{{
	shift
	if [[ ${REQUEST_URI} =~ $regex ]];then
# 		QUERY_STRING="${BASH_REMATCH[1]}"
		"$@" "${BASH_REMATCH[1]}"

		debug $FUNCNAME POST_DATA=$POST_DATA REQUEST_METHOD=$REQUEST_METHOD QUERY_STRING=$QUERY_STRING:REQUEST_URI=${REQUEST_URI}:Content-Length=${_REQUEST_HEADERS[Content-Length]}:@=$@:BASH_REMATCH=${BASH_REMATCH[@]}:
		for key in "${!_GET[@]}";do
			debug _GET[$key]=${_GET[$key]}
		done

		debug _POST="${_POST[@]}" length=${#_POST[@]}
		for item in ${!_POST[@]}; do
			echo field=$item value=${_POST[$item]}
		done

	else
		:
# 		debug $FUNCNAME NO REQUEST_METHOD=$REQUEST_METHOD QUERY_STRING=$QUERY_STRING:REQUEST_URI=${REQUEST_URI}:@=$@:BASH_REMATCH=${BASH_REMATCH[@]}: #file=$file:${BASH_REMATCH[@]}:BR1=${BASH_REMATCH[1]}:ARG1=${1}:ARG2=${2}:
	fi
} #}}}on_uri_match

uploadPOST(){
#{{{
	local COUNT URI
	[ ! "$REQUEST_METHOD" == 'POST' -o -z "${_REQUEST_HEADERS['Content-Length']}" ] && return
	[[ ${_REQUEST_HEADERS['Content-Length']} -gt $MAX_UPLOAD_SIZE ]] && {
		USER_MSG='Image too large'
		} || {
		POST_DATA=$(date +'%Y%m%d%H%M%S')
		debug $FUNCNAME: REQUEST_METHOD=$REQUEST_METHOD REQUEST_URI=$REQUEST_URI Content-Length=${_REQUEST_HEADERS['Content-Length']} MAX_UPLOAD_SIZE=$MAX_UPLOAD_SIZE POST_DATA=$POST_DATA UPLOADDIR=$UPLOADDIR

#{{{ 			COUNT=$(awk 'BEGIN{printf "%0.0f", ('"${_REQUEST_HEADERS[Content-Length]}"'/512+1) }')
#}}} 			dd count=${COUNT-2} of=$UPLOADDIR/$POST_DATA
		COUNT=${_REQUEST_HEADERS[Content-Length]}
		dd bs=1 count="${COUNT-2}" of=$UPLOADDIR/$POST_DATA
	}

	URI=${REQUEST_URI%%=*}
	send_response_location_exit "${URI}=${POST_DATA}"

} #}}}uploadPOST

parseGET(){
#{{{
# 	IFS='=&'
	IFS='&'
	local parm_get=($QUERY_STRING) key value
	IFS=
	for ((i=0; i<${#parm_get[@]}; i+=1)); do
		key=${parm_get[i]%=*}
		value=${parm_get[i]#*=}
		_GET[$key]=${value}
# 		_GET[${parm_get[i]}]=$(urldecode ${parm_get[i+1]})
	done
} #}}}parseGET

main(){
#{{{
	local line="" headername headervalue
	chk_conf_file
	[[ ${UID} = 0 ]] && warn "It is not recommended to run bashttpd as root."
	# Request-Line HTTP RFC 2616 $5.1
	read -r line || fail_with 400
	line=${line%%$'\r'}
	recv "${line}"
	read -r REQUEST_METHOD REQUEST_URI REQUEST_HTTP_VERSION <<< "${line}"
	[ -n "${REQUEST_METHOD}" ] && [ -n "${REQUEST_URI}" ] && \
		[ -n "${REQUEST_HTTP_VERSION}" ] || fail_with 400
# 	CONTENT_LENGTH=$(stat -c'%s' "${file}")
	QUERY_STRING="${REQUEST_URI#*\?}"
	[ "${REQUEST_METHOD}" == POST -o "${REQUEST_METHOD}" == GET ] || fail_with 405
	debug $FUNCNAME REQUEST_METHOD=$REQUEST_METHOD REQUEST_URI=$REQUEST_URI

	IFS=
	while read -t 0.1 -r line; do
		line=${line%%$'\r'}
		recv "${line}"
		# If we've reached the end of the headers, break.
		[ -z "${line}" ] && break
		REQUEST_HEADERS+=("${line}")
		IFS=$' :'; read -t 0.1 -r headername headervalue <<<$line; IFS=
		_REQUEST_HEADERS[$headername]=$headervalue
# 		debug headername=$headername headervalue=${_REQUEST_HEADERS[$headername]}
	done

} #}}}main

[[ ${1} == -s ]] && { # start server with -s
	# echo ":$0:"
# 	2>/dev/null
	socat TCP4-LISTEN:${LISTEN_PORT},fork EXEC:"${0}"
} || {
	main
	parseGET
	uploadPOST
	source "${BASHTTPD_CONF}"
# 	fail_with 500
}

:<<'CMNT'
bashlibhttp(){
#{{{
# Author:     darren chamberlain <dlc@users.sourceforge.net>
# Co-Author:  Paul Bournival <paulb-ns@cajun.nu>
#
# bashlib is used by sourcing it at the beginning of scripts that
# needs its functionality (by using the . or source commands).

# PATH=/bin:/usr/bin

#
# Set version number
#
VERSION=$(/bin/echo '$Revision: 1.3 $' | /usr/bin/awk '{print $2}')

# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Initialization stuff begins here. These things run immediately, and
# do the parameter/cookie parsing.
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

# Global debug flag. Set to 0 to disable debugging throughout the lib
DEBUG=0

# capture stdin for POST methods. POST requests don't always come in
# with a newline attached, so we use cat to grab stdin and append a newline.
# This is a wonderful hack, and thanks to paulb.
STDIN=$(/bin/cat)
if [ -n "${STDIN}" ]; then
  QUERY_STRING="${STDIN}&${QUERY_STRING}"
fi

# Handle GET and POST requests... (the QUERY_STRING will be set)
if [ -n "${QUERY_STRING}" ]; then
  # name=value params, separated by either '&' or ';'
  if echo ${QUERY_STRING} | grep '=' >/dev/null ; then
    for Q in $(/bin/echo ${QUERY_STRING} | /usr/bin/tr ";&" "\012") ; do
      #
      # Clear our local variables
      #
      unset name
      unset value
      unset tmpvalue

      #
      # get the name of the key, and decode it
      #
      name=${Q%%=*}
      name=$(/bin/echo ${name} | \
             /bin/sed -e 's/%\(\)/\\\x/g' | \
             /usr/bin/tr "+" " ")
      name=$(/bin/echo ${name} | \
             /usr/bin/tr -d ".-")
      name=$(/usr/bin/printf ${name}

      #
      # get the value and decode it. This is tricky... printf chokes on
      # hex values in the form \xNN when there is another hex-ish value
      # (i.e., a-fA-F) immediately after the first two. My (horrible)
      # solution is to put a space aftet the \xNN, give the value to
      # printf, and then remove it.
      #
      tmpvalue=${Q#*=}
      tmpvalue=$(/bin/echo ${tmpvalue} | \
                 /bin/sed -e 's/%\(..\)/\\\x\1 /g')
      #echo "Intermediate \$value: ${tmpvalue}" 1>&2

      #
      # Iterate through tmpvalue and printf each string, and append it to
      # value
      #
      for i in ${tmpvalue}; do
          g=$(/usr/bin/printf ${i})
          value="${value}${g}"
      done
      #value=$(echo ${value})

      eval "export FORM_${name}='${value}'"
    done
  else # keywords: foo.cgi?a+b+c
    Q=$(echo ${QUERY_STRING} | tr '+' ' ')
    eval "export KEYWORDS='${Q}'"
  fi
fi

#
# this section works identically to the query string parsing code,
# with the (obvious) exception that variables are stuck into the
# environment with the prefix COOKIE_ rather than FORM_. This is to
# help distinguish them from the other variables that get set
# automatically.
#
if [ -n "${HTTP_COOKIE}" ]; then
  for Q in ${HTTP_COOKIE}; do
    #
    # Clear our local variables
    #
    name=
    value=
    tmpvalue=

    #
    # Strip trailing ; off the value
    #
    Q=${Q%;}

    #
    # get the name of the key, and decode it
    #
    name=${Q%%=*}
    name=$(/bin/echo ${name} | \
           /bin/sed -e 's/%\(\)/\\\x/g' | \
           /usr/bin/tr "+" " ")
    name=$(/bin/echo ${name} | \
           /usr/bin/tr -d ".-")
    name=$(/usr/bin/printf ${name})

    # Decode the cookie value. See the parameter section above for
    # an explanation of what this is doing.
    tmpvalue=${Q#*=}
    tmpvalue=$(/bin/echo ${tmpvalue} | \
               /bin/sed -e 's/%\(..\)/\\\x\1 /g')
    #echo "Intermediate \$value: ${tmpvalue}" 1>&2

    #
    # Iterate through tmpvalue and printf each string, and append it to
    # value
    #
    for i in ${tmpvalue}; do
        g=$(/usr/bin/printf ${i})
        value="${value}${g}"
    done
    #value=$(echo ${value})

    #
    # Export COOKIE_${name} into the environment
    #
    #echo "exporting COOKIE_${name}=${value}" 1>&2
    eval "export COOKIE_${name}='${value}'"
  done
fi

# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# functions and all that groovy stuff
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#
# Shameless plug, advertises verion.
function version {
  echo "bashlib, version ${VERSION}"
}

function version_html {
  echo -n "<a href=\"http://sevenroot.org/software/bashlib/\">bashlib</a>,"
  echo "version ${VERSION}"
}

#
# Parameter function.
# * When called with no arguments, returns a list of parameters that
#   were passed in.
# * When called with one argument, returns the value of that parameter
#   (if any)
# * When called with more than one argument, assumes that the first is a
#   paramter name and the rest are values to be assigned to a paramter of
#   that name.
#
function param {
  local name
  local value
  if [ $# -eq 1 ]; then
    name=$1
    name=$(echo ${name} | /bin/sed -e 's/FORM_//')
    value=$(/usr/bin/env | /bin/grep "^FORM_${name}" | /bin/sed -e 's/FORM_//' | /usr/bin/cut -d= -f2-)
  elif [ $# -gt 1 ]; then
    name=$1
    shift
    eval "export 'FORM_${name}=$*'"
  else
    value=$(/usr/bin/env | /bin/grep '^FORM_' | /bin/sed -e 's/FORM_//' | /usr/bin/cut -d= -f1)
  fi
  echo ${value}
  unset name
  unset value
}

# cookie function. Same explanation as param
function cookie {
  local name
  local value
  if [ $# -eq 1 ]; then
    name=$1
    name=$(echo ${name} | /bin/sed -e 's/COOKIE_//')
    value=$(/usr/bin/env | /bin/grep "^COOKIE_${name}" | /bin/sed -e 's/COOKIE_//' | /usr/bin/cut -d= -f2-)
  elif [ $# -gt 1 ]; then
    name=$1
    shift
    eval "export 'COOKIE_${name}=$*'"
  else
    value=$(/usr/bin/env | /bin/grep '^COOKIE_' | /bin/sed -e 's/COOKIE_//' | /usr/bin/cut -d= -f1)
  fi
  echo ${value}
  unset name
  unset value
}

# keywords returns a list of keywords. This is only set when the script is
# called with an ISINDEX form (these are pretty rare nowadays).
function keywords {
  echo ${KEYWORDS}
}

function set_cookie {
  local name=$1
  shift
  local value=$*
  bashlib_cookies="${bashlib_cookies}; ${name}=${value}"

  bashlib_cookies=${bashlib_cookies#;}

  cookie $name $value
}

#
# send_redirect takes a URI and redirects the browser to that uri, exiting
# the script along the way.
#
function send_redirect {
  local uri
  if [ $# -eq 1 ]; then
    uri=$1
  else
    uri="http://${SERVER_NAME}/${SCRIPT_NAME}"
  fi
  echo "Location: ${uri}"
  echo ""
}

#Using bashlib

#Using bashlib is pretty straight-forward. More important, however, is knowing what to do with the variables once they come into your script and knowing how to write CGI scripts. (This script is not running here, for obvious reasons.)

# this sources bashlib into your current environment
# . /usr/local/lib/bashlib

echo "Content-type: text/html"
echo ""

# OK, so we've sent the header... now send some content
echo "<html><title>Crack This Server</title><body>"

# print a "hello" if the username is filled out
username=`param username`
if [ -n "x$username" != "x" ] ; then
    echo "<h1>Hello, $username</h1>
fi

echo "<h2>Users on `/bin/hostname`</h2>"
echo "<ul>"

# for each user in the passwd file, print their login and full name
# bold them if they are the current user
for user in $(cat /etc/passwd | awk -F: '{print $1 "\t" $5}') ; do
    echo "<li>"
    if [ "$username" = "$user" ] ; then
        echo "<strong>$user</strong>"
    else
        echo "$user"
    fi
    echo "</li>"
done
echo "</ul>"
echo "</body></html>"
} #}}}
CMNT

