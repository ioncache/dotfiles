#!/bin/bash
# web.sh -- http://localhost:9000/hello?world

RESP=/tmp/webresp
[ -p $RESP ] || mkfifo $RESP

while true ; do
( cat $RESP ) | nc -l -p 9000 | (
REQ=`while read L && [ " " "<" "$L" ] ; do echo "$L" ; done`
echo "[`date '+%Y-%m-%d %H:%M:%S'`] $REQ" | head -1
cat >$RESP <<EOF
HTTP/1.0 200 OK
Cache-Control: private
Content-Type: text/plain
Server: bash/2.0
Connection: Close
Content-Length: ${#REQ}

$REQ
EOF
)
done
