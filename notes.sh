#!/bin/bash

CONFIGFILE="~/notes.conf"

typeset -A config
config=(
  [default_notebook]=default
  [default_directory]=$HOME/notebooks
  [lines_to_read]=5
  [reading_style]=line
)

while read line
do
  if echo $line | grep -F = &>/dev/null
  then
    varname=$(echo "$line" | cut -d '=' -f 1)
    config[$varname]=$(echo "$line" | cut -d '=' -f 2-)
  fi
done < $CONFIGFILE

NOTEBOOK=${config[default_notebook]}
DIRECTORY=${config[default_directory]}
NUMLINES=${config[lines_to_read]}
READINGSTYLE=${config[reading_style]}
READING=false

usage () { echo "Usage: notes [-b <notebook name>] [-d <path/to/notebook-dir>] <note | -r [-n <number of lines>] [-t <line|date>]>"; exit 1; }

# b - check without arguments
# b: - check with arguments
# :b - silences errors for unsupported options
while getopts "b:d:rn:t:" opt; do
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
      # Set number of lines to read. only does something when READING
      NUMLINES=$OPTARG
      ;;
    t )
      # Set Reading Style. only does something when READING
      READINGSTYLE=$OPTARG
      ;;
    \? )
      usage
      ;;
  esac
done

shift "$((OPTIND-1))"
NOTE=$1

FILE="$DIRECTORY/$NOTEBOOK"

# If Reading (-r), list the contents of the Notebook and exit
# Prints out all contents of the notebook (maybe an line count flag/argument) separated by date

if [ "$READING" = true ]; then
  # READINGSTYLE = LINE
  if [ "$READINGSTYLE" = "line" ]; then
    OLD=""
    tail -n $NUMLINES $FILE | while read line
    do
      # Prints new date when it comes to one
      CURRENT=$(echo $line | awk 'BEGIN{FS=";"} { print $1 }' | awk '{print $1, $2, $3, $4}')
      if [[ $CURRENT != $OLD ]]; then
        OLD=$CURRENT
        echo $CURRENT
      fi
      echo $line | awk 'BEGIN{FS=";"} { print "- ", $2 }'
    done
    exit 0

  # READINGSTYLE = DATE
  elif [ "$READINGSTYLE" = "date" ]; then
    OLD=""
    COUNTER=0
    tac $FILE | while read line
    do
      CURRENT=$(echo $line | awk 'BEGIN{FS=";"} { print $1 }' | awk '{print $1, $2, $3, $4}')
      if [[ $CURRENT != $OLD ]]; then
        OLD=$CURRENT
        echo $CURRENT
        ((COUNTER=COUNTER+1))
      fi
      echo $line | awk 'BEGIN{FS=";"} { print "- ", $2 }'
      if [ $COUNTER = $NUMLINES ]; then
        break
      fi
    done
    exit 0
  fi
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
