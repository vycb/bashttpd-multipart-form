#!/usr/bin/awk
BEGIN{
  #{{{
  #	name="name"
  # Orders
  # name="body"
  # Orders subject to approval.
  # name="image";filename="temp.txt"
  # Content-Type: text/plain
  #}}}
	tmpfile="png.tmpfileout"
}

{
	if(PROC =="getformfields"){ #PROC

		if($0 ~ "Content-Disposition:"){
			NEWREC=NR
			sub(".*form-data; name=", "")
			gsub(/"/, "")
# 			field=$0 #$1$2$34
			print #CNT, CNT%2, field;
#       CNT++
		}

		if(NEWREC>0 && NR > NEWREC+1 && NR < NEWREC+3){
# 			value=$0
			print #CNT, CNT%2,  value
#       CNT++
	  }

		if($0 ~ "Content-Type:"){
			print #CNT, $0
# 		CNT++
			NEWFILE=NR
		}

  }else if(PROC =="getContentType"){ #PROC

		if($0 ~ "Content-Type:"){
			print #CNT, $0
# 		CNT++
			NEWFILE=NR
		}
	}
	else if(PROC == "getfiledata"){
		if($0 ~ "Content-Type:"){
# 			print #CNT, $0
# 		CNT++
			NEWFILE=NR
		}
		if(NEWFILE>0 && NR >NEWFILE+1 && !($0 ~"------"))
			print
		#>tmpfile

	} #PROC

}
