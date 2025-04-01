#!/bin/bash

# Clear or create fbfuse_coordinates.csv file
> fbfuse_coordinates.csv

# Read unix_times.csv, skipping the header
tail -n +2 unix_times.csv | while IFS=, read -r Jname Date UTC_start UTC_end UNIX_start UNIX_end Verified_UTC_start Verified_UTC_end
do
    # Check if the UNIX start and Jname values are present
    if [ -z "$UNIX_start" ] || [ -z "$Jname" ]; then
        echo "Skipping entry with missing UNIX_start or Jname"
        continue
    fi

    # Grep katportalclient_output.csv within a ±50-line range of the UNIX start time
    match_line=$(grep -n "$UNIX_start" katportalclient_output.csv | head -n 1 | cut -d: -f1)
    if [ -n "$match_line" ]; then
        # Define the range of lines to search
        start_line=$((match_line - 2))
        end_line=$((match_line + 2))

        # Ensure the start and end line are within valid limits
        [ $start_line -lt 1 ] && start_line=1
        total_lines=$(wc -l < katportalclient_output.csv)
        [ $end_line -gt $total_lines ] && end_line=$total_lines

        # Extract the relevant lines from katportalclient_output.csv
        relevant_lines=$(sed -n "${start_line},${end_line}p" katportalclient_output.csv)

        # Grep for Jname in the extracted lines
        jname_line=$(echo "$relevant_lines" | grep "$Jname")

       # If both lines are found, write them to fbfuse_coordinates.csv
        if [ -n "$jname_line" ]; then
            echo "$Jname, $UNIX_start, $UTC_start, $jname_line, $request_line" >> fbfuse_coordinates.csv
        else
            echo "No matching lines found for $Jname at UNIX time $UNIX_start in the specified range."
        fi
    else
        echo "No match found for UNIX time $UNIX_start in katportalclient_output.csv."
    fi
done

