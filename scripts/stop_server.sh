#!/bin/bash +xe
# source: https://stackoverflow.com/questions/13711855/linux-script-to-kill-java-process
# source: https://askubuntu.com/questions/100186/how-to-kill-only-if-process-is-running
if [ $(pgrep 'java') ];then
  pkill -f 'java';
fi