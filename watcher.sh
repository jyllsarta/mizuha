#!/bin/sh

count=`ps -ef | grep  mizuha | grep -v grep | wc -l`
if [ $count = 0 ]; then
	date >> ~/mizuha/watcher.log
 	echo "mizuha is not runnning.." >> ~/mizuha/watcher.log
     	~/mizuha/mizuha.sh
fi

