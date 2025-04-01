Scripts to fix wrong coordinates of PTUSE data by replacing them with the FBFUSE coordinates.

## Usage:
1. List all PTUSE data in SCI-MK-02 to all_ptuse_files.csv
```find /path/ -type f -name "*.sf" > all_ptuse_files.csv```
2. Run check.py from within a singularity image with psrchive installed. This file will check all .sf files listed in all_ptuse_files.csv, and output 
    a. incorrect_coords.csv - A file containing filenames, PSRJname, and coordinates quoted in the file, of files with incorrect coordinates
    b. all_results.csv - A file filenames, PSRJname, and coordinates quoted in the file, for ALL PTUSE files.
    c. errors_files.csv - A file containing filenames of files that have format errors and cannot be read by psrstat
3. Run ptuse_update.py locally to read each of the lines from incorrect_coords.csv and convert the date times to unix times. This saves the output to unix_times.csv which has columns: Jname, Date, UTC_start, UTC_end, UNIX time start, UNIX time end, Verified UTC start, and Verified UTC end.
4. Now run get_fbfuse_coordinates.sh. This runs get_coordinate_history on katportalclient in a loop until it runs successfully and the output is saved to katportalclient_output.csv.
5. Run fbfuse_coordinates_cleanup.sh to grep the Jname,unix time, and fbfuse coordinates from katportalclient_output.csv. This saves the output to fbfuse_coordinates.csv


