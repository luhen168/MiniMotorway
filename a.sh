#!/bin/bash

# Check if a filename is provided as an argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 filename"
    exit 1
fi

# Input data from the specified file
filename="$1"

# Process the data
while read -r line; do
    # Extract the data bytes and print them
    echo "$line" | awk '{$1=""; print $0}' | xargs -n1
done < "$filename"
