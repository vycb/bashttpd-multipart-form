#!/bin/bash
. CGIBa.sh
MAX_UPLOAD_SIZE=1024000

if [[ -n ${get[note]} ]];then
	POST_FILE=${get[note]}
fi

 [ "$REQUEST_METHOD" == 'POST' -a ! -z "$CONTENT_LENGTH" ] && {
	if test "$CONTENT_LENGTH" -gt "$MAX_UPLOAD_SIZE" ;then
		USER_MSG='Image too large'
	else
# 		POST_FILE=$(date +'%Y%m%d%H%M%S')
# 		cat >$UPLOADDIR/$POST_FILE
			echo cat
# 		echo -e "Location: notes.sh?note=$POST_FILE"$N
	fi
}

# for ((i=0; i<${#parm_post[@]}; i+=2)); do #{{{
# 	post[${parm_post[i]}]=$(urldecode ${parm_post[i+1]})
# done #}}}
declare -A POST
declare CNT=0 fieldn
:<<'CMNT'
while read -r line; do
	if [[ $line == *Content-Type:* ]];then
		line="$(escapewebext $line)"
	else
		line="$(escapeweb $line)"
	fi
	if [[ $((CNT++%2)) -eq 0 ]];then
		if [[ $line == *filename=* ]];then
			OFS=IFS;IFS=';' FILENAMEAR=($line); IFS=$OFS
			for fileline in ${FILENAMEAR[@]};do
				if [[ $((FLCNT++%2)) -eq 0 ]];then
					flfield=${fileline#*=}
				else
					POST[${flfield}]=${fileline#*=}
					continue
				fi
				debug fileline=$fileline
			done
		fi #filename

		fieldn="$line"
		debug CNT=$((CNT%2)) fieldn: $fieldn

	else # fieldn

		if [[ $line == *Content-Type:* ]];then
			fieldn=${line%:*}
			POST[$fieldn]=$line
			debug ContentType: ${POST[$fieldn]}
		else

			POST[$fieldn]="$line"

			debug CNT=$((CNT%2)) lern: ${#POST[@]} fieldn: $fieldn value=${POST[$fieldn]}

		fi
	fi
done<<<$(awk -v PROC="getformfields" -f multipart.awk $UPLOADDIR/$POST_FILE)
CMNT

debug POST="${POST[@]}" lern: ${#POST[@]}
# for item in ${!POST[@]}; do
# 	echo field=$item value=${POST[$item]}
# done

# exit 0

ix(){
#{{{
  local opts id
	[[ -s "$HOME/.netrc" ]] && opts='-n'
	while [[ $1 == -* ]];do
		case $1 in
			-h) echo "ix [-d/r ID] [-i ID] [-n N] [opts]"; return ;;
			-i) id="$2"; shift 2;;
			-d) curl $opts -X DELETE ix.io/$id; return ;;
			-l) curl -s $opts ix.io/user/$(awk '/ix.io/{print $4; exit 0}' ~/.netrc)|lynx -dump -stdin; return ;;
			-g) curl $opts $@; return ;;
			-r) opts="$opts -X PUT -F id:1=$id"; shift	;; # Replace ID, two ways
			-n) shift; opts="$opts -F read:1=$1";; # Paste that can be only be read twice
		esac
	done
	getid(){
		[[ ${#id} -ge 2 ]] && echo /$id  #{{{
	} #}}}
	[[ -t 0 ]] && {
		local filename="$1"
		shift
		[[ -n $filename ]] && {
			curl $opts -F f:1=@"$filename" "$*" ix.io$(getid) # Replace ID, filename - path
				return
			}
		echo "^C to cancel, ^D to send."
	}
	prnblue id=$id:opts=$opts:arg=$*: $N
	curl $opts -F f:1='<-' "$*" ix.io$(getid) # ReplaceID:cat file.ext|curl -F 'f:1=<-' -F 'read:1=2' ix.io
} #}}}

N="\n"
# echo -e "Content-type: text/html$N"
USER="$(stat -c '%U' "$(pwd)")"
YEAR=$(date +"%Y")

#{{{ :<<'CMNT'
cat<<EOF
<!DOCTYPE html>
<html lang="en">
	<head>
		<title>~$USER on envs.net</title>
		<meta http-equiv="content-type" content="text/html; charset=utf-8" />
		<meta name="author" content="$USER">
		<meta name="robots" content="noindex">
		<meta name="description" content="~$USER on envs.net" />
		<meta name="keywords" content="$USER" />
		<link rel="stylesheet" href="https://envs.net/css/css_style.css" />
		<link rel="stylesheet" href="https://envs.net/css/fork-awesome.min.css" />
		<style>
			body{ margin:40px; color:#ffff88 !important; background-color:#000}
			a { color: #55a9dd; text-decoration:none}
			a:active, a:visited  { color: #7e59dd; }
			a:hover {color:#5599aa; text-decoration: underline; }
			a.logo,a.logo:hover{text-decoration: none !important; }
			code{background-color: #020202; color:#15ff11; padding:5px;}
			li{ margin:5px; }
			p{margin:12px 0;}
			div.logo a{float: right; }
			div.logo a img{width: 36px;}
			.head,.footer,.fortune{color:#dfbe00; margin:-45px auto auto;display:block;width: 186px;line-height:normal}
			.footer{margin: 60px auto auto;}
			.fortune {width:500px; margin: -12px auto 20px auto;}
			.ncal {width:500px; margin: 35px auto auto;}
			#gpgpubkey{display:none}
			h3{font-size:20px}
			.error{color:#ff2035}
		</style>
		<script type="text/javascript">
		function toggleElement(el){
					var obj = document.getElementById(el)
								obj.style.display = obj.style.display == "none" ? "block" : "none"
		}
		</script>
	</head>

	<body id="body" class="dark-mode">
		<!-- min-width: needed if the sidebar is enable -->
		<div style="clear:both; /*min-width: 750px;*/">

			<div id="main">
<div class="logo">
	<a class="logo" href="notes.sh"><img src="https://addons.cdn.mozilla.net/user-media/userpics/11/11446/11446242.png" alt="VYCB"></a>
</div>
<pre class="head">
 __ __ __ __    __ ____
|  Y  |  Y  I  /  |    Y
|  |  |  |  I /  /|  o  )
|  |  |  -  |/  / |     T
l  :  l___, /   \_|  O  |
 \   /|     \     |     |
  \_/ l____/ \____l_____j
                              </pre>
<pre class="fortune">$(
#/usr/games/fortune
)</pre>

$(#{{{
# <form action="?note=${note:=$(date +'%Y%m%d%H%M%S')}" method="POST" enctype="application/x-www-form-urlencoded">
#}}} }}}
)
<form action="?note=${note:=$POST_FILE}" method="POST" enctype="multipart/form-data">
Name: <input type="text" name="name" value="${POST[name]}"><br>
Body: <textarea name="body">${POST[body]}</textarea><br>
Image: <input type="file" name="image" id="image"><br>
<input type="submit">
</form>
<pre>
CONTENT_LENGTH=$CONTENT_LENGTH
note=$POST_FILE
$(
cat <<<\
"name=$(escapeweb ${POST[name]})
body=$(escapeweb "${POST[body]}")
"
if [[ -n $USER_MSG ]]; then
	echo $(error_msg $USER_MSG)
fi
#{{{
)
<img src="imagesrc.sh?ID=$POST_FILE"/>
</pre>

<ul>
<li><a href="https://keybase.pub/vycb/box/">https://keybase.pub/vycb/box/</a> - <em>Files Share</em></li>
<li><a href="https://keybase.pub/vycb">https://keybase.pub/vycb</a> - <em>Navigable site</em></li>
<li><a href="https://www.patreon.com/vacheslawbo">https://www.patreon.com/vacheslawbo</a> - <em>Patreon home</em></li>
<li><a href="https://keybase.io/vycb/chat">https://keybase.io/vycb/chat</a> - to an encrypted chat. Even if you haven&#39;t installed Keybase yet, it will work.</li>
<li><a href="javascript:" onclick="toggleElement('gpgpubkey');return false">GPG finger-print: </a>64E2 49F3 BB80 E89E 0646  D950 28D8 8102 8F90 C5B4</li>
</ul>
<pre id="gpgpubkey" style="display:none">
-----BEGIN PGP PUBLIC KEY BLOCK-----

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
=JNZK
-----END PGP PUBLIC KEY BLOCK-----
</pre>
<pre class="footer">
IRC:   $USER on tilde.chat
Mail:  <code>$USER on envs.net</code>
<blockquote>
Copyright © $YEAR
</blockquote>
</pre>
			</div>
$(:<<'CMNT'
<!-- You can also enable a right sidebar

			<div id="sidebar">
<pre class="sidebar">

more text

</pre>
			</div>

-->}}}
CMNT
)
		</div>

	</body>
</html>
EOF
# CMNT
