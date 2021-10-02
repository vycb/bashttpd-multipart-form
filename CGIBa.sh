
### CHANGE THIS IF YOU WOULD LIKE TO LISTEN ON A DIFFERENT PORT
declare -i LISTEN_PORT=8080 DEBUG=1 VERBOSE=1

debug(){
	[[ ! $VERBOSE -eq 1 ]] && return #{{{
# 	echo $@ >&2
	( >&2 echo -e "\033[1;38;2;255;100;100m$@\033[00m" )
} #}}}
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

parsePOST(){
#{{{
	local CNT=0 fieldn

	[ -z "$POST_DATA" -o ! -e $UPLOADDIR/$POST_DATA ] && return

	while read -r line; do
		if [[ $line == *Content-Type:* ]];then
			line="$(escapewebext $line)"
		else
			line="$(escapeweb $line)"
		fi

		[[ $((CNT++%2)) -eq 0 ]] && {
			[[ $line == *filename=* ]] && {
				OFS=IFS;IFS=';' FILENAMEAR=($line); IFS=$OFS
				for fileline in ${FILENAMEAR[@]};do
					if [[ $((FLCNT++%2)) -eq 0 ]];then
						flfield=${fileline#*=}
					else
						_POST[${flfield}]=${fileline#*=}
						continue
					fi
	#					debug fileline=$fileline
				done
			} #filename

			fieldn="$line"
	#			debug CNT=$((CNT%2)) fieldn: $fieldn

		} || { # fieldn

			if [[ $line == *Content-Type:* ]];then
				fieldn=${line%:*}
				_POST[$fieldn]=$line
	#				debug ContentType: ${_POST[$fieldn]}
			else

				_POST[$fieldn]="$line"

	#				debug CNT=$((CNT%2)) lern: ${#_POST[@]} fieldn: $fieldn value=${_POST[$fieldn]}

			fi
		} #fi

	done<<<$(awk -v PROC="getformfields" -f multipart.awk $UPLOADDIR/$POST_DATA)


} #}}}parsePOST

urldecode()
{ #{{{
		[ "${1%/}" = "" ] && echo "/"||echo -e "$(sed 's/%\([[:xdigit:]]\{2\}\)/\\\x\1/g' <<< "${1%/}")"
} #}}}

urlencode(){
	local s="${@//'%'/%25}" #{{{
	s="${s//' '/%20}"
	s="${s//'"'/%22}"
	s="${s//'#'/%23}"
	s="${s//'$'/%24}"
	s="${s//'&'/%26}"
	s="${s//'+'/%2B}"
	s="${s//','/%2C}"
	s="${s//'/'/%2F}"
	s="${s//':'/%3A}"
	s="${s//';'/%3B}"
	s="${s//'='/%3D}"
	s="${s//'?'/%3F}"
	s="${s//'@'/%40}"
	s="${s//'['/%5B}"
	s="${s//']'/%5D}"
	printf '%s' "$s"
} #}}}

:<<'CMNT'
{{{
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
}}}
CMNT
