#!/bin/bash

# Check if an argument is provided
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <filename>"
  exit 1
fi

# File to read
input_file="$1"

# Check if file exists
if [[ ! -f "$input_file" ]]; then
  echo "File not found!"
  exit 1
fi

# Read the file and combine lines into groups of four
awk '{printf "%s", $0; if (NR % 4 == 0) print "";}' "$input_file"
