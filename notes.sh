#!/bin/bash

# Eventually pull from config file
# Config should have a notebook directory
# Config should have a default notebook

CONFIG=""

NOTEBOOK=""
DIRECTORY=""
VIEWING=false

while getopts ":bdv" opt; do
  case ${opt} in
    b ) 
      # Get next argument (I think shift) and set NOTEBOOK to its value
      ;;
    d )
      # Get next argument and set DIRECTORY to its value
      ;;
    v ) 
      # View the contents of the notebook
      VIEWING=true
      ;;
    \? ) 
      echo "Usage: notes [-b] [-d] [-v] <note>"
      ;;
  esac
done

# If Viewing (-v), list the contents of the Notebook and exit
# Prints out all contents of the notebook (maybe an line count flag/argument) separated by date

# Create a new notebook if it doesnt exist in the notebook directory
# write to line to notebook file with date

exit 0
