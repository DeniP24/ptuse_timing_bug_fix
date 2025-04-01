#!/bin/bash

# Set the host variable
HOST="portal.mkat.karoo.kat.ac.za"  # Replace with your actual host

# Create or clear katportalclient_output.csv file
> katportalclient_output.csv

# Loop until unix_times.csv is empty
while [ -s unix_times.csv ]; do
    # Create a temporary file to store unsuccessful lines
    > unix_times_temp.csv
    
    # Read the CSV file, skipping the header
    header=$(head -n 1 unix_times.csv)
    tail -n +2 unix_times.csv | while IFS=, read -r Jname Date UTC_start UTC_end UNIX_start UNIX_end Verified_UTC_start Verified_UTC_end
    do
        # Run the Python script with the specified parameters and save output to katportalclient_output.csv
        python3 /home/denisha/Desktop/1PHD/s_band_processing/katportalclient/examples/get_sensor_history.py --host "$HOST" -s "$UNIX_start" -e "$UNIX_end" cbf_1_delaycalc_array_1_primary_target >> katportalclient_output.csv 2>&1
        
        # Check the exit status of the previous command
        if [ $? -ne 0 ]; then
            # If there was an error, print "error" and add the line to the temp file
            echo "Error running get_sensor_history for Jname: $Jname with UNIX start: $UNIX_start and UNIX end: $UNIX_end" >> katportalclient_output.csv
            echo "$Jname,$Date,$UTC_start,$UTC_end,$UNIX_start,$UNIX_end,$Verified_UTC_start,$Verified_UTC_end" >> unix_times_temp.csv
        else
            # Print success message and indicate line was processed successfully
            echo "Successfully ran and deleted entry for Jname: $Jname with UNIX start: $UNIX_start and UNIX end: $UNIX_end" >> katportalclient_output.csv
            echo "Successfully processed and removed: $Jname, $Date, $UNIX_start, $UNIX_end"
        fi
    done

    # Move the temporary file back to unix_times.csv (keeping only unsuccessful lines)
    if [ -s unix_times_temp.csv ]; then
        echo "$header" > unix_times.csv
        cat unix_times_temp.csv >> unix_times.csv
    else
        # If the temporary file is empty, remove the original file to end the loop
        rm unix_times.csv
    fi

done

