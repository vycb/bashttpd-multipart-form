#!/bin/bash
escapeweb(){
	echo "$@"| sed 's/[^A-Za-z0-9_(): %\*\-]//g' #{{{
} #}}}
escapewebext(){
	echo "$@"| sed 's/[^A-Za-z0-9_(): %\*\/\|\-]//g' #{{{
} #}}}
urldecode(){
	local url_encoded="${1//+/ }" #{{{
	printf '%b' "${url_encoded//%/\\x}"
} #}}}
error_msg(){
	#{{{
	echo "<h3 class=error>$@</h3>"
} #}}}
debug(){
	[[ ! $DEBUGGING -eq 1 ]] && return #{{{
	echo $@
} #}}}
UPLOADDIR=/tmp

OIFS=$IFS
IFS='=&'
parm_get=($QUERY_STRING)
IFS=$'\r\n\r\n'
parm_post=($POST_STRING)
IFS=$OIFS

declare -A get post

for ((i=0; i<${#parm_get[@]}; i+=2)); do
	get[${parm_get[i]}]=$(urldecode ${parm_get[i+1]})
done
