#!/bin/bash

# Path to the CSV file
csv_file="incorrect_coords.csv"

# Path to search for files
#search_path="/beegfs/DATA/PTUSE/SCI-20200703-MK-02/"  # Change this to the actual path
# Read the CSV line by line
while IFS=',' read -r path jname coords; do
    date_var=$(basename "$path" | cut -c1-10)
    read col8 col9 < <(grep "$date_var" fbfuse_coordinates.csv | grep "$jname" | awk -F' ' '{print $8, $9}')
    v8_=${col8//h,/}
    v9_=${col9//d,nominal/}
    echo $path $v8_ $v9_
    # Find files matching both Jname and xyz
#    find "$search_path" -type f | grep "$jname_cleaned" | grep "$v3" | grep -E "\.sf$" | while read -r file; do
#        v8_=${v8//h,/}
#        v9_=${v9//d,nominal/}
#        echo $file $v8_ $v9_
done < "$csv_file"
