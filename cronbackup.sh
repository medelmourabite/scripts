#!/bin/bash

# get parameters
# first parameter is the directory to backup or current directory if not specified
directory=${1:-.}
# second parameter is the prefix of the file name, default empty
prefix=${2:-""}

if [ ! -d $directory ]; then
    mkdir $directory
fi

# create a trash directory if it doesn't exit
if [ ! -d "$directory/trash" ]; then
    mkdir "$directory/trash"
fi

# run a cron job every 5 minutes that executes the backup script and save logs to a file
#write out current crontab
crontab -l > tmpcron
#echo new cron into cron file
echo "*/5 * * * * $PWD/backup.sh $PWD/$directory $prefix >>$PWD/$directory/stdout.log 2>>$PWD/$directory/stderr.log" >> tmpcron
#install new cron file
crontab tmpcron
rm tmpcron