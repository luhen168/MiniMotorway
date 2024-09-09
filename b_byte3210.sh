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

# Read the file and combine lines into groups of four with reversed content
awk '{
    # Store each line in an array
    lines[NR] = $0;
} 
END {
    # Process in groups of four
    for (i = 1; i <= NR; i += 4) {
        # Reverse the content of the group
        for (j = 3; j >= 0; j--) {
            if (i + j <= NR) {
                printf "%s", lines[i + j];
            }
        }
        print "";  # New line after each group
    }
}' "$input_file"
