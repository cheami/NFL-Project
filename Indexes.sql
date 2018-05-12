USE NFL
GO

/*
Create indexes on most common queries.
These queries are mostly used for reporting from SSRS.
*/
CREATE NONCLUSTERED INDEX SeasonPassing_TeamID_Season
	ON SeasonPassing(PasserID, TeamID, Season) 
	INCLUDE (Player_Name, Attempts, Completions, Comp_Per, Drives, Total_Raw_AirYards, Times_Hit, Total_Yards, Interceptions, TDs)
GO

CREATE NONCLUSTERED INDEX SeasonRushing_TeamID_Season
	ON SeasonRushing(RusherID, TeamID, Season) 
	INCLUDE (Player_Name, Carries, Drives, Yards_per_Car, Total_Yards, Fumbles, TDs)
GO

CREATE NONCLUSTERED INDEX SeasonReceiving_TeamID_Season
	ON SeasonReceiving(ReceiverID, TeamID, Season) 
	INCLUDE (Player_Name, Targets, Receptions, Receptions_Percentage, Drives, Total_Yards, Total_Raw_YAC, Fumbles, Tds)
GO