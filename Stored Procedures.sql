USE NFL
GO

/*
Create stored procedure that returns the top X passers for team for season.
*/
CREATE PROCEDURE ReportTopXPassersForTeamForSeason(@team_name NVARCHAR(50), @season INT, @num INT)
AS
BEGIN
	SET NOCOUNT ON;

    SELECT 
		CONCAT(t.Prefix_Name, ' ', t.Name) AS [Team Name],
		tp.Player_Name AS [Player Name],
		Attempts AS [Pass Attempts],
		Completions AS [Completions],
		Comp_Per AS [Completion Percentage],
		Drives AS [Total Drives],
		Total_Yards AS [Total Yards],
		Total_Raw_AirYards AS [Total Raw Air Yards],
		Total_Comp_AirYards AS [Total Completions Air Yards],
		Times_Hit AS [Times Hit],
		Interceptions AS [Interceptions],
		TDs AS [Touchdowns],
		Air_TDs AS [Air Touchdowns],
		Season AS [Season]
	FROM SeasonPassing as sp
	JOIN Team as t
		ON t.TeamID = sp.TeamID
	CROSS APPLY TopXPassersForTeamForSeason(@team_name, @season, @num) as tp
	WHERE t.Name = @team_name AND sp.Season = @season AND sp.PasserID = tp.PasserID AND sp.Player_Name = tp.Player_Name
END
GO

/*
Create stored procedure that returns the top X rushers for team for season.
*/
CREATE PROCEDURE ReportTopXRushersForTeamForSeason(@team_name NVARCHAR(50), @season INT, @num INT)
AS
BEGIN
	SET NOCOUNT ON;

    SELECT 
		CONCAT(t.Prefix_Name, ' ', t.Name) AS [Team Name],
		tp.Player_Name AS [Player Name],
		Carries AS [Carries],
		Drives AS [Total Drives],
		Total_Yards AS [Total Yards],
		Yards_per_Car AS [Yards per Carry],
		Fumbles AS [Fumbles],
		TDs AS [Touchdowns],
		Season AS [Season]
	FROM SeasonRushing as sr
	JOIN Team as t
		ON t.TeamID = sr.TeamID
	CROSS APPLY TopXRushersForTeamForSeason(@team_name, @season, @num) as tp
	WHERE t.Name = @team_name AND sr.Season = @season AND sr.RusherID = tp.RusherID AND sr.Player_Name = tp.Player_Name
END
GO

/*
Create stored procedure that returns the top X receivers for team for season.
*/
CREATE PROCEDURE ReportTopXReceiversForTeamForSeason(@team_name NVARCHAR(50), @season INT, @num INT)
AS
BEGIN
	SET NOCOUNT ON;

    SELECT 
		CONCAT(t.Prefix_Name, ' ', t.Name) AS [Team Name],
		tp.Player_Name AS [Player Name],
		Targets AS [Targets],
		Receptions AS [Receptions],
		Receptions_Percentage AS [Receptions Percentage],
		Drives AS [Drives],
		Total_Yards AS [Total Yards],
		Total_Raw_YAC AS [Total Raw Yards Ater Catch],
		Fumbles AS [Fumbles],
		TDs AS [Touchdowns],
		Season AS [Season]
	FROM SeasonReceiving as sr
	JOIN Team as t
		ON t.TeamID = sr.TeamID
	CROSS APPLY TopXReceiversForTeamForSeason(@team_name, @season, @num) as tp
	WHERE t.Name = @team_name AND sr.Season = @season AND sr.ReceiverID = tp.ReceiverID AND sr.Player_Name = tp.Player_Name
END
GO

/*
Create stored procedure that returns team schedule for season.
*/
CREATE PROCEDURE ReportTeamScheduleForSeason(@team_name NVARCHAR(50), @season INT)
AS
BEGIN
	SET NOCOUNT ON;

    SELECT *
	FROM TeamScheduleForSeason(@team_name, @season)
	ORDER BY Week ASC
END
GO

/*
Create stored procedure that returns top X receivers for team for each game of season.
*/
CREATE PROCEDURE ReportTopXReceiversForTeamForSeasonSchedule(@team_name NVARCHAR(50), @season INT, @num INT)
AS
BEGIN
	SET NOCOUNT ON;

    SELECT 
		ts.GameID AS [GameID],
		ts.Date AS [Date],
		ts.Season AS [Season], 
		ts.Week AS [Week], 
		ts.HomeTeam AS [Home Team],
		ts.AwayTeam AS [Away Team],
		ts.HomeTeamScore AS [Home Team Score],
		ts.AwayTeamScore AS [Away Team Score],
		ts.CurrentRecord AS [Current Record],
		tr.ReceiverID AS [PlayerID],
		tr.Player_Name AS [Player Name],
		gr.Targets AS [Targets],
		gr.Receptions AS [Receptions],
		gr.Receptions_Percentage AS [Receptions Percentage],
		gr.Drives AS [Drives],
		gr.Total_Yards AS [Total Yards],
		gr.Total_Raw_YAC AS [Total Raw YAC],
		gr.Fumbles AS [Fumbles],
		gr.Tds AS [Touchdowns]
	FROM TeamScheduleForSeason(@team_name, @season) AS ts
	CROSS APPLY TopXReceiversForTeamForGame(@team_name, ts.GameID, @num) AS tr
	JOIN GameReceiving AS gr
		ON ts.GameID = gr.GameID
		AND tr.ReceiverID = gr.ReceiverID
		AND tr.Player_Name = gr.Player_Name
END
GO

/*
Create stored procedure that returns top X passers for team for game.
*/
CREATE PROCEDURE ReportTopXPassersForTeamForGame(@team_name NVARCHAR(50), @gameid INT, @num INT)
AS
BEGIN
	SET NOCOUNT ON;

    SELECT 
		gp.GameID AS [GameID],
		g.Week AS [Week],
		g.Date AS [Date],
		t1.Prefix_Name AS [Team Prefix Name],
		t1.Name AS [Team Name],
		t2.Prefix_Name AS [Opponent Prefix Name],
		t2.Name AS [Opponent Name],
		tp.PasserID AS [PlayerID],
		tp.Player_Name AS [Player Name],
		gp.Attempts AS [Attempts],
		gp.Completions AS [Completions],
		gp.Comp_Per AS [Completion Percentage],
		gp.Drives AS [Drives],
		gp.Total_Yards AS [Total Yards],
		gp.Total_Raw_AirYards AS [Total Raw Air Yards],
		gp.Total_Comp_AirYards AS [Total Completion Air Yards],
		gp.Times_Hit AS [Times Hit],
		gp.Interceptions AS [Interceptions],
		gp.Air_TDs AS [Air Touchdowns],
		gp.Tds AS [Touchdowns]
	FROM GamePassing AS gp
	JOIN Team AS t1
		ON t1.TeamID = gp.TeamID
	JOIN Team AS t2
		ON t2.TeamID = gp.OpponentID
	JOIN Game AS g
		ON gp.GameID = g.GameID
	CROSS APPLY TopXPassersForTeamForGame(@team_name, @gameid, @num) AS tp
	WHERE gp.GameID = @gameid AND gp.PasserID = tp.PasserID AND gp.Player_Name = tp.Player_Name AND t1.Name = @team_Name
END
GO

/*
Create stored procedure that returns top X passers for each team season.
*/
CREATE PROCEDURE ReportTopXPassersAllTeamForSeason(@season INT, @num INT)
AS
BEGIN
	SET NOCOUNT ON;

    SELECT 
		sp.Season AS [Season],
		CONCAT(t.Prefix_Name, ' ' , t.Name) AS [Team Name],
		t.Conference AS [Conference],
		t.Division AS [Division],
		tp.PasserID AS [PlayerID],
		tp.Player_Name AS [Player Name],
		sp.Attempts AS [Attempts],
		sp.Completions AS [Completions],
		sp.Comp_Per AS [Completion Percentage],
		sp.Drives AS [Drives],
		sp.Total_Yards AS [Total Yards],
		sp.Total_Raw_AirYards AS [Total Raw Air Yards],
		sp.Total_Comp_AirYards AS [Total Completion Air Yards],
		sp.Times_Hit AS [Times Hit],
		sp.Interceptions AS [Interceptions],
		sp.Air_TDs AS [Air Touchdowns],
		sp.Tds AS [Touchdowns]
	FROM Team AS t
	JOIN SeasonPassing AS sp
		ON t.TeamID = sp.TeamID
	CROSS APPLY TopXPassersForTeamForSeason(t.Name, @season, @num) AS tp
	WHERE sp.Season = @season AND sp.PasserID = tp.PasserID AND sp.Player_Name = tp.Player_Name
END
GO

/*
Create stored procedure that returns top X rushers for each team season.
*/
CREATE PROCEDURE ReportTopXRushersAllTeamForSeason(@season INT, @num INT)
AS
BEGIN
	SET NOCOUNT ON;

    SELECT 
		sr.Season AS [Season],
		CONCAT(t.Prefix_Name, ' ' , t.Name) AS [Team Name],
		t.Conference AS [Conference],
		t.Division AS [Division],
		tr.RusherID AS [PlayerID],
		tr.Player_Name AS [Player Name],
		sr.Carries AS [Carries],
		sr.Yards_per_Car AS [Yards per Carry],
		sr.Total_Yards AS [Total Yards],
		sr.Drives AS [Drives],
		sr.Fumbles AS [Fumbles],
		sr.Tds AS [Touchdowns]
	FROM Team AS t
	JOIN SeasonRushing AS sr
		ON t.TeamID = sr.TeamID
	CROSS APPLY TopXRushersForTeamForSeason(t.Name, @season, @num) AS tr
	WHERE sr.Season = @season AND sr.RusherID = tr.RusherID AND sr.Player_Name = tr.Player_Name
END
GO


/*
Create stored procedure that returns top X receivers for each team season.
*/
CREATE PROCEDURE ReportTopXReceiversAllTeamForSeason(@season INT, @num INT)
AS
BEGIN
	SET NOCOUNT ON;

    SELECT 
		sr.Season AS [Season],
		CONCAT(t.Prefix_Name, ' ' , t.Name) AS [Team Name],
		t.Conference AS [Conference],
		t.Division AS [Division],
		tr.ReceiverID AS [PlayerID],
		tr.Player_Name AS [Player Name],
		sr.Targets AS [Targets],
		sr.Receptions AS [Receptions],
		sr.Receptions_Percentage AS [Receptions Percentage],
		sr.Drives AS [Drives],
		sr.Total_Yards AS [Total Yards],
		sr.Total_Raw_YAC AS [Total Raw YAC],
		sr.Fumbles AS [Fumbles],
		sr.Tds AS [Touchdowns]
	FROM Team AS t
	JOIN SeasonReceiving AS sr
		ON t.TeamID = sr.TeamID
	CROSS APPLY TopXReceiversForTeamForSeason(t.Name, @season, @num) AS tr
	WHERE sr.Season = @season AND sr.ReceiverID = tr.ReceiverID AND sr.Player_Name = tr.Player_Name
END
GO