import csv
import subprocess
import os
import re

# File names
input_csv = 'all_ptuse_files.csv'  # Input CSV file containing the filenames
incorrect_csv = 'incorrect_coords.csv'  # Output CSV file for mismatched entries

# Initialize lists to store results
results = []
errors = []

def validate_coordinates(source_name, coordinates):
    """Check if the source name and coordinates roughly match."""
    # Extract minutes from the source name
    print("processing" +str(source_name) +str(coordinates))
    source_minutes = int(source_name[3:5])  # J1015-5358 -> 15
    source_ra = int(source_name[1:3])
    dec_deg = int(source_name[6:8])  # J1015-5358 -> 15
    dec_min = int(source_name[8:10])

    real_coords = coordinates.split(":")
    dec = (real_coords[2])[-2:]
    dec = int(dec)
#    print(int(source_ra), int(real_coords[0]))
#    print(int(source_minutes), int(real_coords[1]))
#    print(int(dec_deg), dec)
#    print(int(dec_min), int(real_coords[3]))
    if (abs(int(real_coords[0]) - source_ra) < 2 and abs(int(real_coords[1]) - source_minutes) < 2 and abs(dec - dec_deg) < 2 and abs(int(real_coords[3]) - dec_min) < 2):
#        print("TRUE")
        return True
    else:
        return False

# Read the CSV file and process each filename
with open(input_csv, mode='r') as csvfile:
    reader = csv.reader(csvfile)
    for row in reader:
        filename = row[0]
        # Run the psrstat command
        try:
            result = subprocess.run(
                ['psrstat', filename],
                stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True  # Use universal_newlines for string output
            )

            # Capture output
            output = result.stdout.strip()
            error = result.stderr.strip()

            # Print error if exists
            if result.returncode != 0:
                print("Error processing file {}: {}".format(filename, error))
                continue

            # Extract the source name and coordinates from output
            source_name = None
            coordinates = None
            
            for line in output.split('\n'):
                if 'Source name' in line:
                    source_name = line.split()[-1]  # Assuming the name is the last word
                elif 'Source coordinates' in line:
                    coordinates = line.split()[-1]  # Assuming the coordinates are the last word

            # Check if both values were extracted
            if source_name and coordinates:
                results.append((filename, source_name, coordinates))

                # Validate the name and coordinates
                if not validate_coordinates(source_name, coordinates):  # Check if they match
                    with open(incorrect_csv, mode='a') as incorrect_file:
                        incorrect_file.write("{},{},{}\n".format(filename, source_name, coordinates))
            else:
                print("Could not extract required data from output for file {}".format(filename))
                errors.append(filename)

        except Exception as e:
            print("Error processing file {}: {}".format(filename, e))

# Optionally, write results to a new file if needed
with open('all_results.csv', mode='w') as result_file:
    writer = csv.writer(result_file)
    writer.writerow(['filename', 'source_name', 'coordinates'])  # Header
    for result in results:
        writer.writerow(result)

#Write error files out to a new file
with open('errors_files.csv', mode='w') as result_file:
    result_file.write('filename\n')  # Header
    for error_file in errors:
        result_file.write("{}\n".format(error_file))  
