#!/bin/sh
#
# This mails to user plom the message in the file named by the first parameter,
# decoded with the first line as subject and everything below the second line
# as the message body. The subject line MUST NOT contain '"' double quotes.

subject=`head -1 $1`
body=`tail -n +2 $1`
echo $body | mutt -s "$subject" plom
