#!/bin/bash

# Eventually pull from config file
# Config should have a notebook directory
# Config should have a default notebook
# Maybe config can define whether you are viewing by line count or day count

CONFIG=""

NOTEBOOK="default"
DIRECTORY="$HOME/notebooks"
READING=false
NUMLINES=5

usage () { echo "Usage: notes [-b <notebook name>] [-d <path/to/directory>] [-v] <note>"; exit 1; }

# b - check without arguments
# b: - check with arguments
# :b - silences errors for unsupported options
while getopts "b:d:rn:" opt; do
  case ${opt} in
    b ) 
      # Get next argument and set NOTEBOOK to its value
      NOTEBOOK=$OPTARG
      ;;
    d )
      # Get next argument and set DIRECTORY to its value
      DIRECTORY=$OPTARG
      ;;
    r ) 
      # View the contents of the notebook
      READING=true
      ;;
    n )
      # Set number of lines to read
      NUMLINES=$OPTARG
      ;;
    \? ) 
      usage
      ;;
  esac
done

shift "$((OPTIND-1))"
NOTE=$1

FILE="$DIRECTORY/$NOTEBOOK"

#DEBUG
#echo "$NOTEBOOK"
#echo "$DIRECTORY"
#echo "$READING"

# If Reading (-r), list the contents of the Notebook and exit
# Prints out all contents of the notebook (maybe an line count flag/argument) separated by date

if [ "$READING" = true ]; then
  #cat $FILE
  
  # grab the last X lines and print out
  # FRI Feb 12
  #  - test
  #  - Testt2
  # SAT Feb 13
  #  - Random Note
  
  OLD=""
  tail -n $NUMLINES $FILE | while read line
  do
    CURRENT=$(echo $line | awk 'BEGIN{FS=";"} { print $1 }' | awk '{print $1, $2, $3, $4}')
    if [[ $CURRENT != $OLD ]]; then
      OLD=$CURRENT
      echo $CURRENT
    fi
    echo $line | awk 'BEGIN{FS=";"} { print " - ", $2 }'
  done
  exit 0
fi

# Create a new notebook if it doesnt exist in the notebook directory
# write to line to notebook file with date

if [[ ! -d $DIRECTORY ]]; then
  echo "Creating $DIRECTORY"
  mkdir -p $DIRECTORY
fi

if [[ ! -f $FILE ]]; then
  # File Doesn't Exist
  echo "Creating $FILE"
  touch $FILE
fi

OUTPUT="$(date);$NOTE"

echo $OUTPUT | tee -a $FILE

exit 0
