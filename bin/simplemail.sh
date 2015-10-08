#!/bin/sh
#
# This mails to user plom the message in the file named by the first parameter,
# decoded with the first line as subject and everything below the second line
# as the message body.

subject=`head -1 $1`
body=`tail -n +3 $1`
echo "$body" | mutt -s "$subject" plom
