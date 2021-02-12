#!/bin/bash
. CGIBa.sh

imagesrcsendpost(){
	#{{{

	POST_DATA=$(escapeweb ${_GET[ID]})

	[[ -z ${_GET[ID]} ]] || [[ ! -s $UPLOADDIR/$POST_DATA ]] && {
		debug No file id in request
		exit 1
	}

	DEBUGGING=1
	local -A POST\
	CNT=0 N="\n"
	unset RESPONSE_HEADERS
	while read -r line; do
		line="$(escapewebext $line)"

		if [[ $line == *Content-Type:* ]];then
			fieldn=${line%%:*}
			POST[$fieldn]=${line##*': '}
	# 			debug ContentType: ${POST[$fieldn]}
	# 			echo -e "${POST["Content-Type"]}$N"
			add_response_header "Content-Type" "${POST["Content-Type"]}"

		fi

	done<<<$(awk -v PROC='getContentType' -f multipart.awk $UPLOADDIR/$POST_DATA)

	send_redirect 200

	awk -v PROC='getfiledata' -f multipart.awk $UPLOADDIR/$POST_DATA

} #}}}
