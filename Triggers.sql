USE NFL
GO

/*
Create trigger to update [Week] column when new data is inserted in [Game] table.
Sets week number by calculating the difference in days between game date and first game date of season. Then divides by 7 and adds 1. 

e.g. 
First game of 2017 season is '09/07/2017' (Thursday) in DD/MM/YYYY format. 
A Thursday game on week 3 is '09/21/2017'. (21 - 7) / 7 + 1 = 3
A Monday game on week 3 is '09/24/2017'. (24 - 7) / 7 + 1 = 3, (17 / 7) truncates to 2
*/
CREATE TRIGGER AddGameWeek
ON Game
FOR INSERT AS
BEGIN
	WITH CTE AS(
		SELECT DATEDIFF(DAY, MIN(Date) OVER(PARTITION BY Season), Date)/7 + 1 AS Week, GameID
		FROM Game
	)
	UPDATE Game
	SET Week = CTE.Week
	FROM CTE
	WHERE CTE.GameID = Game.GameID
END
GO

/*
Create trigger to add inserted data into [SeasonPassing] table.
First update existing player per season per team passing data, then insert new player per season per team passing data.
*/
CREATE TRIGGER AddtoSeasonPassing
ON GamePassing
FOR INSERT AS
BEGIN
	UPDATE SeasonPassing
	SET Attempts += (SELECT SUM(Attempts) FROM inserted JOIN Game AS g ON g.GameID = inserted.GameID GROUP BY g.Season, inserted.PasserID, inserted.TeamID),
		Completions += (SELECT SUM(Completions) FROM inserted JOIN Game AS g ON g.GameID = inserted.GameID GROUP BY g.Season, inserted.PasserID, inserted.TeamID),
		Drives += (SELECT SUM(Drives) FROM inserted JOIN Game AS g ON g.GameID = inserted.GameID GROUP BY g.Season, inserted.PasserID, inserted.TeamID),
		Total_Yards += (SELECT SUM(Total_Yards) FROM inserted JOIN Game AS g ON g.GameID = inserted.GameID GROUP BY g.Season, inserted.PasserID, inserted.TeamID),
		Total_Raw_AirYards += (SELECT SUM(Total_Raw_AirYards) FROM inserted JOIN Game AS g ON g.GameID = inserted.GameID GROUP BY g.Season, inserted.PasserID, inserted.TeamID),
		Total_Comp_AirYards += (SELECT SUM(Total_Comp_AirYards) FROM inserted JOIN Game AS g ON g.GameID = inserted.GameID GROUP BY g.Season, inserted.PasserID, inserted.TeamID),
		Times_Hit += (SELECT SUM(Times_Hit) FROM inserted JOIN Game AS g ON g.GameID = inserted.GameID GROUP BY g.Season, inserted.PasserID, inserted.TeamID),
		Interceptions += (SELECT SUM(Interceptions) FROM inserted JOIN Game AS g ON g.GameID = inserted.GameID GROUP BY g.Season, inserted.PasserID, inserted.TeamID),
		TDs += (SELECT SUM(TDs) FROM inserted JOIN Game AS g ON g.GameID = inserted.GameID GROUP BY g.Season, inserted.PasserID, inserted.TeamID),
		Air_TDs += (SELECT SUM(Air_TDs) FROM inserted JOIN Game AS g ON g.GameID = inserted.GameID GROUP BY g.Season, inserted.PasserID, inserted.TeamID)
	FROM  SeasonPassing AS sp, inserted
	JOIN Game AS g
	ON inserted.GameID = g.GameID
	WHERE sp.PasserID = inserted.PasserID AND sp.Season = g.Season AND sp.TeamID = inserted.TeamID

	INSERT INTO SeasonPassing (PasserID, TeamID, Player_Name, Attempts, Completions, Drives, Total_Yards, Total_Raw_AirYards, Total_Comp_AirYards, Times_Hit, Interceptions, TDs, Air_TDs, Season)
		SELECT 
			PasserID, 
			TeamID, 
			MIN(Player_Name) AS Player_Name, 
			SUM(Attempts) AS Attempts, 
			SUM(Completions) AS Completions, 
			SUM(Drives) AS Drives, 
			SUM(Total_Yards) AS Total_Yards, 
			SUM(Total_Raw_AirYards) AS Total_Raw_AirYards, 
			SUM(Total_Comp_AirYards) AS Total_Comp_AirYards, 
			SUM(Times_Hit) AS Times_Hit, 
			SUM(Interceptions) AS Interceptions, 
			SUM(TDs) AS TDs, 
			SUM(Air_TDs) AS Air_TDs, 
			g.Season AS Season
		FROM inserted
		JOIN Game AS g
			ON g.GameID = inserted.GameID
		WHERE NOT EXISTS (SELECT * FROM SeasonPassing AS sp 
			WHERE sp.PasserID = inserted.PasserID 
			AND sp.Season = g.Season 
			AND sp.TeamID = inserted.TeamID)
		GROUP BY g.Season, inserted.PasserID, inserted.TeamID
END
GO

/*
Create trigger to add inserted data into [SeasonRushing] table.
First update existing player per season per team rushing data, then insert new player per season per team rushing data.
*/
CREATE TRIGGER AddtoSeasonRushing
ON GameRushing
FOR INSERT AS
BEGIN
	UPDATE SeasonRushing
		SET Carries += (SELECT SUM(Carries) FROM inserted JOIN Game AS g ON g.GameID = inserted.GameID GROUP BY g.Season, inserted.RusherID, inserted.TeamID),
		Drives += (SELECT SUM(Drives) FROM inserted JOIN Game AS g ON g.GameID = inserted.GameID GROUP BY g.Season, inserted.RusherID, inserted.TeamID),
		Total_Yards += (SELECT SUM(Total_Yards) FROM inserted JOIN Game AS g ON g.GameID = inserted.GameID GROUP BY g.Season, inserted.RusherID, inserted.TeamID),
		Fumbles += (SELECT SUM(Fumbles) FROM inserted JOIN Game AS g ON g.GameID = inserted.GameID GROUP BY g.Season, inserted.RusherID, inserted.TeamID),
		TDs += (SELECT SUM(TDs) FROM inserted JOIN Game AS g ON g.GameID = inserted.GameID GROUP BY g.Season, inserted.RusherID, inserted.TeamID)
	FROM  SeasonRushing AS sr, inserted
	JOIN Game AS g
	ON inserted.GameID = g.GameID
	WHERE sr.RusherID = inserted.RusherID 
		AND sr.Season = g.Season 
		AND sr.TeamID = inserted.TeamID

	INSERT INTO SeasonRushing (RusherID, TeamID, Player_Name, Carries, Drives, Total_Yards, Fumbles, TDs, Season)
		SELECT 
			RusherID, 
			TeamID, 
			MIN(Player_Name) AS Player_Name, 
			SUM(Carries) AS Carries, 
			SUM(Drives) AS Drives, 
			SUM(Total_Yards) AS Total_Yards, 
			SUM(Fumbles) AS Fumbles, 
			SUM(TDs) AS TDs, 
			g.Season AS Season
		FROM inserted
		JOIN Game AS g
			ON g.GameID = inserted.GameID
		WHERE NOT EXISTS (SELECT * FROM SeasonRushing AS sr 
			WHERE sr.RusherID = inserted.RusherID 
			AND sr.Season = g.Season 
			AND sr.TeamID = inserted.TeamID)
		GROUP BY g.Season, inserted.RusherID, inserted.TeamID
END
GO

/*
Create trigger to add inserted data into [SeasonReceiving] table.
First update existing player per season per team receiving data, then insert new player per season per team receiving data.
*/
CREATE TRIGGER AddtoSeasonReceiving
ON GameReceiving
FOR INSERT AS
BEGIN
	UPDATE SeasonReceiving
		SET Targets += (SELECT SUM(Targets) FROM inserted JOIN Game AS g ON g.GameID = inserted.GameID GROUP BY g.Season, inserted.ReceiverID, inserted.TeamID),
		Receptions += (SELECT SUM(Receptions) FROM inserted JOIN Game AS g ON g.GameID = inserted.GameID GROUP BY g.Season, inserted.ReceiverID, inserted.TeamID),
		Drives += (SELECT SUM(Drives) FROM inserted JOIN Game AS g ON g.GameID = inserted.GameID GROUP BY g.Season, inserted.ReceiverID, inserted.TeamID),
		Total_Yards += (SELECT SUM(Total_Yards) FROM inserted JOIN Game AS g ON g.GameID = inserted.GameID GROUP BY g.Season, inserted.ReceiverID, inserted.TeamID),
		Total_Raw_YAC += (SELECT SUM(Total_Raw_YAC) FROM inserted JOIN Game AS g ON g.GameID = inserted.GameID GROUP BY g.Season, inserted.ReceiverID, inserted.TeamID),
		TDs += (SELECT SUM(TDs) FROM inserted JOIN Game AS g ON g.GameID = inserted.GameID GROUP BY g.Season, inserted.ReceiverID, inserted.TeamID)
	FROM  SeasonReceiving AS sr, inserted
	JOIN Game AS g
	ON inserted.GameID = g.GameID
	WHERE sr.ReceiverID = inserted.ReceiverID 
		AND sr.Season = g.Season 
		AND sr.TeamID = inserted.TeamID

	INSERT INTO SeasonReceiving (ReceiverID, TeamID, Player_Name, Targets, Receptions, Drives, Total_Yards, Total_Raw_YAC, Fumbles, TDs, Season)
		SELECT 
			ReceiverID, 
			TeamID, 
			MIN(Player_Name) AS Player_Name, 
			SUM(Targets) AS Targets, 
			SUM(Receptions) AS Receptions, 
			SUM(Drives) AS Drives, 
			SUM(Total_Yards) AS Total_Yards, 
			SUM(Total_Raw_YAC) AS Total_Raw_YAC, 
			SUM(Fumbles) AS Fumbles, 
			SUM(TDs) AS TDs, 
			g.Season AS Season
		FROM inserted
		JOIN Game AS g
			ON g.GameID = inserted.GameID
		WHERE NOT EXISTS (SELECT * FROM SeasonReceiving AS sr 
			WHERE sr.ReceiverID = inserted.ReceiverID 
			AND sr.Season = g.Season 
			AND sr.TeamID = inserted.TeamID)
		GROUP BY g.Season, inserted.ReceiverID, inserted.TeamID
END
GO