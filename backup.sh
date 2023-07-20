#!/bin/bash

# variables
intervals=(5 10 15 30 60 120 240 480 960 1440 2880 10080 43200 129600)

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

# Define a function to convert seconds to relative time
function seconds_to_relative_time() {
  local seconds=$1

  # Calculate the number of days, hours, minutes, and seconds
  local days=$((seconds / 86400))
  local hours=$((seconds / 3600 % 24))
  local minutes=$((seconds / 60 % 60))
  local seconds=$((seconds % 60))

  # Build the relative time string
  local relative_time=""
  if [[ $days -gt 0 ]]; then
    relative_time="$relative_time $days day(s)"
  fi
  if [[ $hours -gt 0 ]]; then
    relative_time="$relative_time $hours hour(s)"
  fi
  if [[ $minutes -gt 0 ]]; then
    relative_time="$relative_time $minutes minute(s)"
  fi
  if [[ $seconds -gt 0 ]]; then
    relative_time="$relative_time $seconds second(s)"
  fi

  # Print the relative time string
  echo "$relative_time"
}

# Function to create files in $directory based on the given timestamp with the given prefix and replace spaces 
create_file() {
  current_timestamp=$(date -j -f "%s" "$(date +%s)" "+%F %T")
  touch "$directory/$prefix$(echo $current_timestamp | sed 's/ /_/g').txt"
}

# Function to remove files based on the given timestamp
remove_file() {
  min_timestamp=$(date -j -v "-${1}S" "+%F %T")
  max_timestamp=$(date -j -v "-${2}S" "+%F %T")
  # echo "$1 - $2 : Removing files created between $min_timestamp and $max_timestamp"
  # find files created within range and move them to trash except the last two created files
  find $directory -maxdepth 1 -type f -name "$prefix*.txt" -newermt "$min_timestamp" -and \( -not -newermt "$max_timestamp" \) | sort -r | sed '$d' | sed '$d' | xargs -I {} mv {} "$directory/trash"
}

remove_files() {
  last_index=18
  for i in ${intervals[@]}
  do
    remove_file $((i * 60)) $((last_index * 60))
    last_index=$((i + 3))
  done
}
 
# find files created within range
find_file() {
    min_timestamp=$(date -j -v "-${1}S" "+%F %T")
    max_timestamp=$(date -j -v "-${2}S" "+%F %T")
    find $directory -maxdepth 1 -type f -name "$prefix*.txt" -newermt "$min_timestamp" -and \( -not -newermt "$max_timestamp" \) | sort -r
}

# Show files in the current directory
show_files() {
  clear
  current_timestamp=$(date -j -f "%s" "$(date +%s)" "+%F %T")
  echo "$current_timestamp: Files in the current directory:"

  last_index=0
  for i in ${intervals[@]}
  do
    local relative_time=$(seconds_to_relative_time $((i * 60)))
    echo "$relative_time ago:"
    find_file $((i * 60)) $((last_index * 60))
    last_index=$i
  done
}

# Create files every 5 minutes
while true; do
  echo "----------------------------------------"
  create_file

  remove_files

  show_files

  sleep $((5 * 60))  # Wait for 5 minutes
done
