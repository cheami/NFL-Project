USE NFL
GO

/*
VERY IMPORTANT. RUN THIS FIRST TO CLEAN [PlayByPlay] TABLE!
FIXES PASSERID, PASSER, ReceiverID, Receiver, ReceiverID, RECEIVERID, RECEIVER
*/
UPDATE PlayByPlay
SET Passer = pass.Passer
FROM	(SELECT p1.PasserID, a.Passer
		FROM (SELECT DISTINCT PasserID FROM PlayByPlay) AS p1
		JOIN (SELECT p2.PasserID, p2.Passer, COUNT(*) OVER(PARTITION BY p2.PasserID ORDER BY COUNT(*) DESC) AS num FROM PlayByPlay AS p2 WHERE p2.Passer IS NOT NULL GROUP BY p2.PasserID, p2.Passer) AS a
		ON p1.PasserID = a.PasserID
		WHERE num = 1) AS pass
WHERE PlayByPlay.PasserID = pass.PasserID
GO

UPDATE PlayByPlay
SET Rusher = rush.Rusher
FROM	(SELECT p1.RusherID, a.Rusher
		FROM (SELECT DISTINCT RusherID FROM PlayByPlay) AS p1
		JOIN (SELECT p2.RusherID, p2.Rusher, COUNT(*) OVER(PARTITION BY p2.RusherID ORDER BY COUNT(*) DESC) AS num FROM PlayByPlay AS p2 WHERE p2.Rusher IS NOT NULL GROUP BY p2.RusherID, p2.Rusher) AS a
		ON p1.RusherID = a.RusherID
		WHERE num = 1) AS rush
WHERE PlayByPlay.RusherID = rush.RusherID
GO

UPDATE PlayByPlay
SET Receiver = receive.Receiver
FROM	(SELECT p1.ReceiverID, a.Receiver
		FROM (SELECT DISTINCT ReceiverID FROM PlayByPlay) AS p1
		JOIN (SELECT p2.ReceiverID, p2.Receiver, COUNT(*) OVER(PARTITION BY p2.ReceiverID ORDER BY COUNT(*) DESC) AS num FROM PlayByPlay AS p2 WHERE p2.Receiver IS NOT NULL GROUP BY p2.ReceiverID, p2.Receiver) AS a
		ON p1.ReceiverID = a.ReceiverID
		WHERE num = 1) AS receive
WHERE PlayByPlay.ReceiverID = receive.ReceiverID
GO

/*
Inserts all games from [PlayByPlay] table into [Game] table.
Only insert games that are not already in [Game] table.
*/
INSERT INTO Game (GameID, Season, Date, HomeTeamID, AwayTeamID, HomeTeamScore, AwayTeamScore)
	SELECT Table_1.GameID, Season, Date, HomeTeamID, AwayTeamID, HomeTeamScore, AwayTeamScore
	FROM (
		SELECT 
			GameID, 
			Season, 
			Date, 
			MIN(t1.TeamID) AS HomeTeamID, 
			MIN(t2.TeamID) AS AwayTeamID
		FROM PlayByPlay AS pbp
		JOIN Team AS t1
			ON pbp.HomeTeam = t1.Short_Name
		JOIN Team AS t2
			ON pbp.AwayTeam = t2.Short_Name
		WHERE NOT EXISTS (SELECT * FROM Game AS g WHERE g.GameID = pbp.GameID)
		GROUP BY GameID, Date, Season) AS Table_1
	JOIN (
		SELECT 
			GameID,
			SUM(CASE WHEN Touchdown = 1 AND HomeTeam = OffensiveTeam AND ReturnResult IS NULL THEN 6 ELSE 0 END + 
				CASE WHEN Touchdown = 1 AND HomeTeam = DefensiveTeam AND ReturnResult = 'Touchdown' AND PlayType != 'Kickoff' THEN 7 ELSE 0 END + 
				CASE WHEN Touchdown = 1 AND HomeTeam = DefensiveTeam AND ReturnResult = 'Touchdown' AND PlayType = 'Kickoff' AND RecoverFumbTeam = HomeTeam THEN 6 ELSE 0 END + 
				CASE WHEN Touchdown = 1 AND HomeTeam = OffensiveTeam AND ReturnResult = 'Touchdown' AND PlayType = 'Kickoff' AND RecoverFumbTeam IS NULL THEN 6 ELSE 0 END + 
				CASE WHEN FieldGoalResult = 'Good' AND HomeTeam = OffensiveTeam AND ReturnResult IS NULL THEN 3 ELSE 0 END + 
				CASE WHEN ExtraPointResult = 'Made' AND HomeTeam = OffensiveTeam AND ReturnResult IS NULL THEN 1 ELSE 0 END + 
				CASE WHEN TwoPointConversion = 'Made' AND HomeTeam = OffensiveTeam AND ReturnResult IS NULL THEN 2 ELSE 0 END + 
				CASE WHEN Safety = 1 AND HomeTeam = DefensiveTeam AND ReturnResult IS NULL THEN 2 ELSE 0 END) AS HomeTeamScore,
			SUM(CASE WHEN Touchdown = 1 AND AwayTeam = OffensiveTeam AND ReturnResult IS NULL THEN 6 ELSE 0 END + 
				CASE WHEN Touchdown = 1 AND AwayTeam = DefensiveTeam AND ReturnResult = 'Touchdown' AND PlayType != 'Kickoff' THEN 7 ELSE 0 END + 
				CASE WHEN Touchdown = 1 AND AwayTeam = DefensiveTeam AND ReturnResult = 'Touchdown' AND PlayType = 'Kickoff' AND RecoverFumbTeam = AwayTeam THEN 6 ELSE 0 END + 
				CASE WHEN Touchdown = 1 AND AwayTeam = OffensiveTeam AND ReturnResult = 'Touchdown' AND PlayType = 'Kickoff' AND RecoverFumbTeam IS NULL THEN 6 ELSE 0 END + 
				CASE WHEN FieldGoalResult = 'Good' AND AwayTeam = OffensiveTeam AND ReturnResult IS NULL THEN 3 ELSE 0 END + 
				CASE WHEN ExtraPointResult = 'Made' AND AwayTeam = OffensiveTeam AND ReturnResult IS NULL THEN 1 ELSE 0 END + 
				CASE WHEN TwoPointConversion = 'Made' AND AwayTeam = OffensiveTeam AND ReturnResult IS NULL THEN 2 ELSE 0 END + 
				CASE WHEN Safety = 1 AND AwayTeam = DefensiveTeam AND ReturnResult IS NULL THEN 2 ELSE 0 END) AS AwayTeamScore
		FROM PlayByPlay AS pbp
		WHERE ScoringPlay = 1 AND NOT EXISTS (SELECT * FROM Game AS g WHERE g.GameID = pbp.GameID)
		GROUP BY GameID, HomeTeam, AwayTeam) AS Table_2
	ON Table_1.GameID = Table_2.GameID
GO

/*
Inserts all players from [PlayByPlay] table into [Player] table.
Only insert players that are not already in [Player] table.
*/
INSERT INTO Player (PlayerID, Name)
	SELECT DISTINCT PasserID, Passer
	FROM PlayByPlay AS pbp
	WHERE PlayType = 'Pass' AND PasserID IS NOT NULL AND Passer IS NOT NULL AND 
		NOT EXISTS (SELECT * FROM Player AS p WHERE p.PlayerID = pbp.PasserID)
	UNION
	SELECT DISTINCT RusherID, Rusher
	FROM PlayByPlay AS pbp
	WHERE PlayType = 'Run' AND RusherID IS NOT NULL AND Rusher IS NOT NULL AND 
		NOT EXISTS (SELECT * FROM Player AS p WHERE p.PlayerID = pbp.RusherID)
	UNION
	SELECT DISTINCT ReceiverID, Receiver
	FROM PlayByPlay AS pbp
	WHERE PlayType = 'Pass' AND ReceiverID IS NOT NULL AND Receiver IS NOT NULL AND 
		NOT EXISTS (SELECT * FROM Player AS p WHERE p.PlayerID = pbp.ReceiverID)
GO

/*
Inserts all game per player passing data from [PlayByPlay] table to [GamePassing] table.
Only inserts game per player passing data that is not already in [GamePassing] table.
DO NOT add game per player if the game is not finished. Most data is aggregated.
*/
INSERT INTO GamePassing (GameID, PasserID, TeamID, OpponentID, Player_Name, Attempts, Completions, Drives, Total_Yards, Total_Raw_AirYards, Total_Comp_AirYards, Times_Hit, Interceptions, TDs, Air_TDs)
	SELECT 
		GameID, 
		PasserID, 
		MIN(t1.TeamID) AS TeamID, 
		MIN(t2.TeamID) AS OpponentID, 
		pbp.Passer AS Player_Name, 
		SUM(PassAttempt) AS Attempts, 
		SUM(Reception) AS Completions, 
		COUNT(DISTINCT Drive) AS Drives, 
		SUM(YardsGained) AS Total_Yards, 
		SUM(AirYards) AS Total_Raw_AirYards, 
		SUM(YardsGained - YardsAfterCatch) AS Total_Comp_AirYards, 
		SUM(QBHit) AS Times_Hit, 
		SUM(InterceptionThrown) AS Interceptions, 
		SUM(Touchdown) AS TDs,
		SUM(CASE WHEN YardsAfterCatch = 0 THEN Touchdown ELSE 0 END) AS Air_TDs
	FROM PlayByPlay AS pbp
	JOIN Team as t1
		ON t1.Short_Name = pbp.OffensiveTeam
	JOIN Team as t2
		ON t2.Short_Name = pbp.DefensiveTeam
	JOIN Player as p
		ON pbp.PasserID = p.PlayerID 
		AND pbp.Passer = p.Name
	WHERE PlayType = 'Pass' AND PasserID IS NOT NULL AND Passer IS NOT NULL AND ReturnResult IS NULL AND
		NOT EXISTS (SELECT * FROM GamePassing AS gp WHERE gp.PasserID = pbp.PasserID AND gp.GameID = pbp.GameID)
	GROUP BY pbp.GameID, pbp.PasserID, pbp.Passer
GO

/*
Inserts all game per player rushing data from [PlayByPlay] table to [GameRushing] table.
Only inserts game per player rushing data that is not already in [GameRushing] table.
DO NOT add game per player if the game is not finished. Most data is aggregated.
*/
INSERT INTO GameRushing (GameID, RusherID, TeamID, OpponentID, Player_Name, Carries, Drives, Total_Yards, Fumbles, TDs)
	SELECT 
		GameID, 
		RusherID, 
		MIN(t1.TeamID) AS TeamID, 
		MIN(t2.TeamID) AS OpponentID, 
		pbp.Rusher AS Player_Name, 
		SUM(RushAttempt) AS Carries,
		COUNT(DISTINCT Drive) AS Drives, 
		SUM(YardsGained) AS Total_Yards, 
		SUM(Fumble) AS Fumbles, 
		SUM(Touchdown) as TDs
	FROM PlayByPlay AS pbp
	JOIN Team as t1
		ON t1.Short_Name = pbp.OffensiveTeam
	JOIN Team as t2
		ON t2.Short_Name = pbp.DefensiveTeam
	JOIN Player as p
		ON pbp.RusherID = p.PlayerID 
		AND pbp.Rusher = p.Name
	WHERE PlayType = 'Run' AND RusherID IS NOT NULL AND Rusher IS NOT NULL AND ReturnResult IS NULL AND
		NOT EXISTS (SELECT * FROM GameRushing AS gr WHERE gr.RusherID = pbp.RusherID AND gr.GameID = pbp.GameID)
	GROUP BY GameID, RusherID, pbp.Rusher
GO

/*
Inserts all game per player receiving data from [PlayByPlay] table to [GameReceiving] table.
Only inserts game per player receiving data that is not already in [GameReceiving] table.
DO NOT add game per player if the game is not finished. Most data is aggregated.
*/
INSERT INTO GameReceiving (GameID, ReceiverID, TeamID, OpponentID, Player_Name, Targets, Receptions, Drives, Total_Yards, Total_Raw_YAC, Fumbles, TDs)
	SELECT 
		GameID, 
		ReceiverID, 
		MIN(t1.TeamID) AS TeamID, 
		MIN(t2.TeamID) AS OpponentID, 
		pbp.Receiver AS Player_Name, 
		COUNT(Reception) AS Targets,
		SUM(Reception) AS Receptions,
		COUNT(DISTINCT Drive) AS Drives, 
		SUM(YardsGained) AS Total_Yards, 
		SUM(YardsAfterCatch) AS Total_Raw_YAC,
		SUM(Fumble) AS Fumbles, 
		SUM(Touchdown) as TDs
	FROM PlayByPlay AS pbp
	JOIN Team as t1
		ON t1.Short_Name = pbp.OffensiveTeam
	JOIN Team as t2
		ON t2.Short_Name = pbp.DefensiveTeam
	JOIN Player as p
		ON pbp.ReceiverID = p.PlayerID 
		AND pbp.Receiver = p.Name
	WHERE PlayType = 'Pass' AND ReceiverID IS NOT NULL AND Receiver IS NOT NULL AND ReturnResult IS NULL AND
		NOT EXISTS (SELECT * FROM GameReceiving AS gr WHERE gr.ReceiverID = pbp.ReceiverID AND gr.GameID = pbp.GameID)
	GROUP BY GameID, ReceiverID, pbp.Receiver
GO

/*
Inserts all team season records from [Game] and [Team] tables.
*/
INSERT INTO SeasonRecord(TeamID, Season, Win, Lose, Tie, Points_For, Points_Against, Home, Away)
	SELECT 
		t.TeamID AS TeamID,
		Season,
		SUM(CASE 
			WHEN g.HomeTeamScore > g.AwayTeamScore AND t.TeamID = g.HomeTeamID THEN 1 
			WHEN g.AwayTeamScore > g.HomeTeamScore AND t.TeamID = g.AwayTeamID THEN 1 
			ELSE 0 END) AS Win,
		SUM(CASE 
			WHEN g.HomeTeamScore < g.AwayTeamScore AND t.TeamID = g.HomeTeamID THEN 1 
			WHEN g.AwayTeamScore < g.HomeTeamScore AND t.TeamID = g.AwayTeamID THEN 1 
			ELSE 0 END) AS Lose,
		SUM(CASE 
			WHEN g.HomeTeamScore = g.AwayTeamScore AND t.TeamID = g.HomeTeamID THEN 1 
			WHEN g.AwayTeamScore = g.HomeTeamScore AND t.TeamID = g.AwayTeamID THEN 1 
			ELSE 0 END) AS Tie,
		SUM(CASE 
			WHEN t.TeamID = g.HomeTeamID THEN g.HomeTeamScore
			ELSE g.AwayTeamScore END) AS [Points For],
		SUM(CASE 
			WHEN t.TeamID = g.HomeTeamID THEN g.AwayTeamScore
			ELSE g.HomeTeamScore END) AS [Points Against],
		CONCAT(SUM(CASE WHEN g.HomeTeamScore > g.AwayTeamScore AND t.TeamID = g.HomeTeamID THEN 1 ELSE 0 END), '-', 
			SUM(CASE WHEN g.HomeTeamScore < g.AwayTeamScore AND t.TeamID = g.HomeTeamID THEN 1 ELSE 0 END), '-', 
			SUM(CASE WHEN g.HomeTeamScore = g.AwayTeamScore AND t.TeamID = g.HomeTeamID THEN 1 ELSE 0 END)) AS Home,
		CONCAT(SUM(CASE WHEN g.HomeTeamScore < g.AwayTeamScore AND t.TeamID = g.AwayTeamID THEN 1 ELSE 0 END), '-', 
			SUM(CASE WHEN g.HomeTeamScore > g.AwayTeamScore AND t.TeamID = g.AwayTeamID THEN 1 ELSE 0 END), '-', 
			SUM(CASE WHEN g.HomeTeamScore = g.AwayTeamScore AND t.TeamID = g.AwayTeamID THEN 1 ELSE 0 END)) AS Away			
	FROM Game AS g
	JOIN Team AS t
		ON g.HomeTeamID = t.TeamID
		OR g.AwayTeamID = t.TeamID
	WHERE NOT EXISTS(SELECT * FROM SeasonRecord AS sr WHERE sr.TeamID = t.TeamID AND sr.Season = g.Season)
	GROUP BY t.TeamID, Season
GO