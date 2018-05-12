USE NFL
GO

/*
Create function to return team schedule for season.
Team name must be in name format, e.g. 'vikings'.
*/
CREATE FUNCTION TeamScheduleForSeason(@team_name NVARCHAR(50), @season INT)
RETURNS TABLE
AS
RETURN
(
	SELECT 
		g.GameID AS GameID,
		g.Date AS Date,
		g.Season AS Season, 
		g.Week AS Week, 
		t1.Name AS HomeTeam,
		t2.Name AS AwayTeam,
		g.HomeTeamScore AS HomeTeamScore,
		g.AwayTeamScore AS AwayTeamScore,
		CASE 
			WHEN @team_name = t1.Name AND g.HomeTeamScore > g.AwayTeamScore THEN 'W'
			WHEN @team_name = t2.Name AND g.HomeTeamScore < g.AwayTeamScore THEN 'W'
			WHEN g.HomeTeamScore = g.AwayTeamScore THEN 'T'
			ELSE 'L' END AS Result,
		CONCAT(
			SUM(CASE WHEN (@team_name = t1.Name AND g.HomeTeamScore > g.AwayTeamScore) OR (@team_name = t2.Name AND g.HomeTeamScore < g.AwayTeamScore) THEN 1 ELSE 0 END) OVER(ORDER BY Week ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), '-', 
			SUM(CASE WHEN (@team_name = t1.Name AND g.HomeTeamScore < g.AwayTeamScore) OR (@team_name = t2.Name AND g.HomeTeamScore > g.AwayTeamScore) THEN 1 ELSE 0 END) OVER(ORDER BY Week ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), '-', 
			SUM(CASE WHEN g.HomeTeamScore = g.AwayTeamScore THEN 1 ELSE 0 END) OVER(ORDER BY Week ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) 
			 AS CurrentRecord		
	FROM Game AS g
	JOIN Team AS t1
		ON g.HomeTeamID = t1.TeamID
	JOIN Team AS t2
		ON g.AwayTeamID = t2.TeamID
	WHERE Season = @season AND (t1.Name = @team_name OR t2.Name = @team_name)
)
GO

/*
Create function to return top X passers for team for game.
Based on yards thrown then TDs.
*/
CREATE FUNCTION TopXPassersForTeamForGame(@team_name NVARCHAR(50), @gameid INT, @num INT)
RETURNS TABLE
AS
RETURN
(
	SELECT TOP (@num) gp.PasserID, gp.Player_Name
	FROM GamePassing AS gp
	JOIN Team AS t
		ON gp.TeamID = t.TeamID
	WHERE t.Name = @team_name AND gp.GameID = @gameid
	ORDER BY Total_Yards DESC, TDs DESC
)
GO

/*
Create function to return top X rushers for team for game.
Based on total yards then TDs.
*/
CREATE FUNCTION TopXRushersForTeamForGame(@team_name NVARCHAR(50), @gameid INT, @num INT)
RETURNS TABLE
AS
RETURN
(
	SELECT TOP (@num) gr.RusherID, gr.Player_Name
	FROM GameRushing AS gr
	JOIN Team AS t
		ON gr.TeamID = t.TeamID
	WHERE t.Name = @team_name AND gr.GameID = @gameid
	ORDER BY Total_Yards DESC, TDs DESC
)
GO

/*
Create function to return top X receivers for team for game.
Based on total yards then TDs.
*/
CREATE FUNCTION TopXReceiversForTeamForGame(@team_name NVARCHAR(50), @gameid INT, @num INT)
RETURNS TABLE
AS
RETURN
(
	SELECT TOP (@num) gr.ReceiverID, gr.Player_Name
	FROM GameReceiving AS gr
	JOIN Team AS t
		ON gr.TeamID = t.TeamID
	WHERE t.Name = @team_name AND gr.GameID = @gameid
	ORDER BY Total_Yards DESC, TDs DESC
)
GO

/*
Create function to return top X passers for team for season.
Based on yards thrown then TDs.
*/
CREATE FUNCTION TopXPassersForTeamForSeason(@team_name NVARCHAR(50), @season INT, @num INT)
RETURNS TABLE
AS
RETURN
(
	SELECT TOP (@num) sp.PasserID, sp.Player_Name
	FROM SeasonPassing AS sp
	JOIN Team AS t
		ON sp.TeamID = t.TeamID
	WHERE t.Name = @team_name AND sp.Season = @season
	ORDER BY Total_Yards DESC, TDs DESC
)
GO

/*
Create function to return top X rushers for team for season.
Based on total yards then TDs.
*/
CREATE FUNCTION TopXRushersForTeamForSeason(@team_name NVARCHAR(50), @season INT, @num INT)
RETURNS TABLE
AS
RETURN
(
	SELECT TOP (@num) sr.RusherID, sr.Player_Name
	FROM SeasonRushing AS sr
	JOIN Team AS t
		ON sr.TeamID = t.TeamID
	WHERE t.Name = @team_name AND sr.Season = @season
	ORDER BY Total_Yards DESC, TDs DESC
)
GO

/*
Create function to return top X receivers for team for season.
Based on total yards then TDs.
*/
CREATE FUNCTION TopXReceiversForTeamForSeason(@team_name NVARCHAR(50), @season INT, @num INT)
RETURNS TABLE
AS
RETURN
(
	SELECT TOP (@num) sr.ReceiverID, sr.Player_Name
	FROM SeasonReceiving AS sr
	JOIN Team AS t
		ON sr.TeamID = t.TeamID
	WHERE t.Name = @team_name AND sr.Season = @season
	ORDER BY Total_Yards DESC, TDs DESC
)
GO

/*
Create function to return every game stats for player passing.
*/
CREATE FUNCTION PassingAgainstTeam(@player_name NVARCHAR(100), @team_name NVARCHAR(50))
RETURNS TABLE
AS
RETURN
(
	SELECT 
		gp.GameID AS GameID, 
		t1.Name AS TeamName, 
		t2.Name AS OpponentName, 
		gp.Player_Name AS PlayerName,
		gp.Attempts AS Attempts,
		gp.Completions AS Completions,
		gp.Comp_Per AS Comp_Per,
		gp.Drives AS Drives,
		gp.Total_Yards AS Total_Yards,
		gp.Total_Raw_AirYards AS Total_Raw_AirYards,
		gp.Total_Comp_AirYards AS Total_Comp_AirYards,
		gp.Times_Hit AS Times_Hit,
		gp.Interceptions AS Interceptions,
		gp.TDs AS TDs,
		gp.Air_TDs AS Air_TDs
	FROM GamePassing as gp
	JOIN Team as t1
		ON gp.TeamID = t1.TeamID
	JOIN Team as t2
		ON gp.OpponentID = t2.TeamID
	WHERE t2.Name = @team_name AND gp.Player_Name = @player_name
)
GO