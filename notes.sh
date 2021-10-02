#!/bin/bash

notesmain()(

# for key in "${!_GET[@]}";do #{{{
# 	debug _GET[$key]=${_GET[$key]}
# done

# debug _POST="${_POST[@]}" lern: ${#_POST[@]}
# for item in ${!_POST[@]}; do
# 	echo field=$item value=${_POST[$item]}
# done #}}}

debug note.sh POST_DATA=$POST_DATA REQUEST_METHOD=$REQUEST_METHOD QUERY_STRING=$QUERY_STRING:REQUEST_URI=${REQUEST_URI}:Content-Length=${_REQUEST_HEADERS[Content-Length]}


local N="\n" \
USER="$(stat -c '%U' "$(pwd)")" \
YEAR=$(date +"%Y")
# echo -e "Content-type: text/html$N"

#{{{
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
		<link rel="shortcut icon" href="/favicon.ico" />
		<style>
			body{ margin:40px; color:#ffff88 !important; background-color:#000}
			a { color: #55a9dd; text-decoration:none}
			a:active, a:visited  { color: #7e59dd; }
			a:hover {color:#5599aa; text-decoration: underline; }
			a.logo,a.logo:hover{text-decoration: none !important; }
			code{background-color: #020202; color:#15ff11; padding:5px;}
			li{ margin:5px; }
			p{margin:12px 0;}
			.head,.fortune{color:#dfbe00; margin:-45px auto 35px;display:block;width:500px;line-height:normal}
			.footer{width:200px; margin:45px auto auto}
			div.logo a{float: right; margin:33px 0 0 0}
			div.logo a img{width: 36px;}
			#postdat{width: 64px}
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
 _____         _
| __  |___ ___| |_  ┏┳┓╻ ╻╻  ╺┳╸╻┏━┓┏━┓┏━┓╺┳╸ ┏━╸┏━┓┏━┓┏┳┓
| __ -| .'|_ -|   | ┃┃┃┃ ┃┃   ┃ ┃┣━┛┣━┫┣┳┛ ┃  ┣╸ ┃ ┃┣┳┛┃┃┃
|_____|__,|___|_|_| ╹ ╹┗━┛┗━╸ ╹ ╹╹  ╹ ╹╹┗╸ ╹  ╹  ┗━┛╹┗╸╹ ╹
</pre>
<pre class="fortune">$(
#/usr/games/fortune
)</pre>

$(
#{{{
# <form action="?note=${note:=$(date +'%Y%m%d%H%M%S')}" method="_POST" enctype="application/x-www-form-urlencoded">
#}}} }}}
)
<form action="?postdat=$POST_DATA" method="POST" enctype="multipart/form-data">
Name: <input type="text" name="name" value="${_POST[name]}"><br>
Body: <textarea name="body">${_POST[body]}</textarea><br>
Image: <input type="file" name="image" id="image"><br>
<input type="submit">
</form>
<pre>
CONTENT_LENGTH=${_REQUEST_HEADERS[Content-Length]}
note=$POST_DATA
$( echo "\
name=$(escapeweb ${_POST[name]})
body=$(escapeweb "${_POST[body]}")
"
 [[ -n $USER_MSG ]] && echo $(error_msg $USER_MSG)

[[ -n $POST_DATA ]] && echo "<img id="postdat" src=" imagesrc.sh?ID=$POST_DATA" />"
)
</pre>
<pre class="footer">
IRC:  $USER on tilde.chat
Mail: $USER on envs.net
<blockquote>
Copyright © $YEAR
</blockquote>
</pre>
			</div>
$(:<<'CMNT'
<!-- You can also enable a right sidebar #{{{

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

) #notesmain
