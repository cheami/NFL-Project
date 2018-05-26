# NFL-Project
NFL project to practice ETL with SSIS, data warehousing, SQL DML/DDL, and reporting with SSRS

## Information
Used play by play data to act as "transactional" data, to which I stored all information into a database with multiple tables.
Check each .sql file for descriptions on each batch of code. Database has a total of 480033 rows across 11 tables. I make use of triggers, functions, stored procedures, indexes, foreign keys, inline-TFVs, optimized queries, window functions, and more. The database is set up so you can load a full new game, week, or year into the database and all you'll have to do is run the insert script. I plan to add the insert script as a trigger on the [PlayByPlay] table to remove the need to run the insert script for each load of new data.

All scripts are separated for display purposes, but you can combine each .sql file together so you don't have to execute each one at a time.

I suggest you create the database and then run the report files in SSRS or upload to your Report Server to view the reports. They are all made to be rendered in HTML/EXCEL, but you will need to create the database to allow the reports to query from the shared data sources.

DEMO OF REPORTS (5/12/18): https://www.youtube.com/watch?v=JZiU8kPYY04
## Data
The data (.csv) is too large to upload to GitHub. Each .csv file is >25mb with ~45k rows each and consists of every NFL play for each season, dating back to 2009.

Source for data is here: https://github.com/ryurko/nflscrapR-data/tree/master/data/season_play_by_play
My C# script in the ETL package (Package.dtsx) cleans the .csv files by find and replacing all 'NA' and 'None' with '' (blank).

## Steps to install project
I used SQL Server 2017, SSMS 17.6, SSDT 2017 (for SSIS and SSRS) developer editions for everything.
### 1. Download everything into C:\NFL Project
This includes the data linked above. Move all .csv files to `C:\NFL Project\data\season_play_by_play\`.
### 2. Execute `Create Database.sql` in SSMS
Creates NFL database with a primary filegroup, a secondary filegroup containing 2 files, and a log file.
- NFL.mdf
- NFL_1.ndf
- NFL_2.ndf
- NFL_log.ldf

Also sets [SECONDARY] filegroup to default.
### 3. Execute `Create Tables.sql` in SSMS
Creates tables on the database. Includes primary keys/clustered indexes.
- GamePassing
- GameReceiving
- GameRushing
- SeasonPassing
- SeasonReceiving
- SeasonRushing
- Game
- Team
- Player
- PlayByPlay
- SeasonRecord

`Create Tables.sql` also inserts static data into [Team] table.
### 4. Execute `Relationships.sql` in SSMS
Creates many relationships between tables from foreign keys.
### 5. Execute `Indexes.sql` in SSMS
Creates indexes that are mostly used for reports from SSRS.
### 6. Execute `Triggers.sql` in SSMS
Creates triggers for INSERT on game tables to update or insert player data into season tables.
Also adds game week to [Game] table.
### 7. Execute `Views.sql` in SSMS
Currently no VIEWs are created as of 5/12/18.
### 8. Execute `Functions.sql` in SSMS
Creates functions that are used with stored procedures. 
### 9. Execute `Stored Procedures.sql` in SSMS
Creates stored procedures that mostly return top X passer/rusher/receiver. Some are used for SSRS.
### 10. Open `C:\NFL Project\SSIS\NFL\NFL.sln` in SSIS and execute package.
YOU WILL NEED TO CHANGE CONNECTION MANAGER FOR DATABASE DESTINATION. It is currently set to my personal server at home.
### 11. Execute `Inserts.sql` in SSMS
After this execution the database is fully loaded!
### 12. All report files are in `C:\NFL Project\SSRS\`
- NFL is my first project that only displays passer stats and information. Use Passing All Team For Season as the home report and navigate from there. All other reports have their parameter inputs hidden (they get their input from previous report).
- NFL_New is my second project that will be much more user friendly and polished. It consists of all stats and demostrates more. Use Season as the home report and navigate from there. All other reports have their parameter inputs hidden (they get their input from previous report).
- Use NFL_New, it is more polished and I do not work on NFL anymore. NFL_New is the most up to date report.
## TO-DO
- Finish NFL_New
- Add all inserts as triggers for automation
- Maintience plans for statistics (not much change though)
- Upload reports to domain/server to allow anyone to view

# SKOL
