import pandas as pd
from datetime import datetime, timedelta

#First run check.py on apsuse to see if the coordinates match the name, then download incorrect.csv, run locally because of pandas.
#Now open this file and save these dates and Jnames to a dataframe
data = []

with open('incorrect_coords.csv', 'r') as file:
    for line in file:
        path_part = line.split(',')[0]
        segments = path_part.split('/')
        date = segments[7]
        jname = segments[8]
        data.append((jname, date))
        
df = pd.DataFrame(data, columns=['Jname', 'Date'])
df = df.drop_duplicates()
print(df)

#Convert these date times (when the observations happened) to UNIX times

def convert_to_datetime(utc_string):#This is just to convert back and check
    return datetime.strptime(utc_string, "%Y-%m-%d-%H:%M:%S")

def convert(utc):
    return datetime.strptime(utc, "%Y-%m-%d %H:%M:%S")

df['UTC_start'] = df['Date'].apply(convert_to_datetime)
df['UTC_start'] = df['UTC_start'] - timedelta(hours=3)
df['UTC_end'] = df['UTC_start'] + timedelta(hours=3)
df['UNIX time start'] = df['UTC_start'].apply(lambda x: int(x.timestamp())) # Convert to UNIX timestamp
df['UNIX time end'] = df['UTC_end'].apply(lambda x: int(x.timestamp()))

df['Verified UTC start'] = df['UNIX time start'].apply(lambda x: datetime.utcfromtimestamp(x).strftime("%Y-%m-%d-%H-%M-%S")) # Convert UNIX timestamp back to UTC for verification
df['Verified UTC end'] = df['UNIX time end'].apply(lambda x: datetime.utcfromtimestamp(x).strftime("%Y-%m-%d-%H-%M-%S"))

# Display the updated dataframe
print(df[['Jname', 'Date','UTC_start', 'UTC_end', 'UNIX time start', 'UNIX time end','Verified UTC start', 'Verified UTC end']])

# Save the updated dataframe to a new CSV file if needed
df.to_csv('unix_times.csv', index=False)
