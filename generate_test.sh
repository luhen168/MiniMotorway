#!/bin/bash

# Function to generate a random number within a given range
random_in_range() {
    local lower=$1
    local upper=$2
    echo $((RANDOM % (upper - lower + 1) + lower))
}

# Prompt user for the template
read -p "Enter template (e.g., add x{\$0}, x{\$1}, 0x{\$2}): " template

# Prompt for value ranges with placeholders intact
read -p "Enter value range of {\$0} (e.g., 0,31): " range0
read -p "Enter value range of {\$1} (e.g., 0,31): " range1
read -p "Enter value range of {\$2} (e.g., 0,999): " range2

# Extract lower and upper bounds from input
IFS=',' read -r lower0 upper0 <<< "$range0"
IFS=',' read -r lower1 upper1 <<< "$range1"
IFS=',' read -r lower2 upper2 <<< "$range2"

# Prompt for the number of commands to generate
read -p "How many commands do you want to generate? " command_count

# Create a .S file and write the commands to it
output_file="generated_commands.S"
> "$output_file"  # Clear the file if it exists

for ((i = 0; i < command_count; i++)); do
    # Generate random values based on the provided ranges
    value0=$(random_in_range "$lower0" "$upper0")
    value1=$(random_in_range "$lower1" "$upper1")
    value2=$(random_in_range "$lower2" "$upper2")

    # Substitute the placeholders with random values
    command="${template//\{\$0\}/$value0}"
    command="${command//\{\$1\}/$value1}"
    command="${command//\{\$2\}/$value2}"

    # Write the command to the file
    echo "$command" >> "$output_file"
done

cat $output_file
echo "Generated $command_count commands written to $output_file"
