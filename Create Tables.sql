USE NFL
GO

/*
Drop all tables
*/
DROP TABLE IF EXISTS GamePassing
GO
DROP TABLE IF EXISTS GameReceiving
GO
DROP TABLE IF EXISTS GameRushing
GO
DROP TABLE IF EXISTS SeasonPassing
GO
DROP TABLE IF EXISTS SeasonReceiving
GO
DROP TABLE IF EXISTS SeasonRushing
GO
DROP TABLE IF EXISTS Game
GO
DROP TABLE IF EXISTS Team
GO
DROP TABLE IF EXISTS Player
GO
DROP TABLE IF EXISTS PlayByPlay
GO
DROP TABLE IF EXISTS SeasonRecord
GO

/*
Create all tables
*/
CREATE TABLE GamePassing(
	GameID	INT NOT NULL,
	PasserID	NVARCHAR(10) NOT NULL,
	TeamID	INT NULL,
	OpponentID	INT NULL,
	Player_Name	NVARCHAR(100) NOT NULL,
	Attempts	FLOAT NULL,
	Completions	FLOAT NULL,
	Comp_Per	AS CAST([Completions] / [Attempts] AS DECIMAL(5,3)),
	Drives	FLOAT NULL,
	Total_Yards	FLOAT NULL,
	Total_Raw_AirYards	FLOAT NULL,
	Total_Comp_AirYards	FLOAT NULL,
	Times_Hit	FLOAT NULL,
	Interceptions	FLOAT NULL,
	TDs	FLOAT NULL,
	Air_TDs	FLOAT NULL,
	CONSTRAINT PK_GamePassing_GameID_PasserID PRIMARY KEY (GameID, PasserID, Player_Name)
)
GO

CREATE TABLE GameRushing(
	GameID	INT NOT NULL,
	RusherID	NVARCHAR(10) NOT NULL,
	TeamID	INT NULL,
	OpponentID	INT NULL,
	Player_Name	NVARCHAR(100) NOT NULL,
	Carries	FLOAT NULL,
	Drives	FLOAT NULL,
	Yards_per_Car	AS CAST([Total_Yards] / [Carries] AS DECIMAL(5,3)),
	Total_Yards	FLOAT NULL,
	Fumbles	FLOAT NULL,
	TDs	FLOAT NULL,
	CONSTRAINT PK_GameRushing_GameID_RusherID PRIMARY KEY (GameID, RusherID, Player_Name)
)
GO

CREATE TABLE GameReceiving(
	GameID	INT NOT NULL,
	ReceiverID	NVARCHAR(10) NOT NULL,
	TeamID	INT NULL,
	OpponentID	INT NULL,
	Player_Name	NVARCHAR(100) NOT NULL,
	Targets	FLOAT NULL,
	Receptions	FLOAT NULL,
	Receptions_Percentage	AS CAST([Receptions] / [Targets] AS DECIMAL(5,3)),
	Drives	FLOAT NULL,
	Total_Yards	FLOAT NULL,
	Total_Raw_YAC	FLOAT NULL,
	Fumbles	FLOAT NULL,
	Tds	FLOAT NULL,
	CONSTRAINT PK_GameReceiving_GameID_ReceiverID PRIMARY KEY (GameID, ReceiverID, Player_Name)
)
GO

CREATE TABLE SeasonPassing(
	PasserID	NVARCHAR(10) NOT NULL,
	TeamID	INT NOT NULL,
	Player_Name	NVARCHAR(100) NULL,
	Attempts	FLOAT NULL,
	Completions	FLOAT NULL,
	Comp_Per	AS CAST([Completions] / [Attempts] AS DECIMAL(5,3)),
	Drives	FLOAT NULL,
	Total_Yards	FLOAT NULL,
	Total_Raw_AirYards	FLOAT NULL,
	Total_Comp_AirYards	FLOAT NULL,
	Times_Hit	FLOAT NULL,
	Interceptions	FLOAT NULL,
	TDs	FLOAT NULL,
	Air_TDs	FLOAT NULL,
	Season	FLOAT NOT NULL,
	CONSTRAINT PK_SeasonPassing_GameID_PasserID_TeamID PRIMARY KEY (Season, PasserID, TeamID)
)
GO

CREATE TABLE SeasonRushing(
	RusherID	NVARCHAR(10) NOT NULL,
	TeamID	INT NOT NULL,
	Player_Name	NVARCHAR(100) NULL,
	Carries	FLOAT NULL,
	Drives	FLOAT NULL,
	Yards_per_Car	AS CAST([Total_Yards] / [Carries] AS DECIMAL(5,3)),
	Total_Yards	FLOAT NULL,
	Fumbles	FLOAT NULL,
	TDs	FLOAT NULL,
	Season	FLOAT NOT NULL,
	CONSTRAINT PK_SeasonRushing_GameID_RusherID_TeamID PRIMARY KEY (Season, RusherID, TeamID)
)

CREATE TABLE SeasonReceiving(
	ReceiverID	NVARCHAR(10) NOT NULL,
	TeamID	INT NOT NULL,
	Player_Name	NVARCHAR(100) NULL,
	Targets	FLOAT NULL,
	Receptions	FLOAT NULL,
	Receptions_Percentage	AS CAST([Receptions] / [Targets] AS DECIMAL(5,3)),
	Drives	FLOAT NULL,
	Total_Yards	FLOAT NULL,
	Total_Raw_YAC	FLOAT NULL,
	Fumbles	FLOAT NULL,
	Tds	FLOAT NULL,
	Season	FLOAT NOT NULL,
	CONSTRAINT PK_SeasonReceiving_GameID_ReceiverID_TeamID PRIMARY KEY (Season, ReceiverID, TeamID)
)
GO
GO

CREATE TABLE Game(
	GameID	INT NOT NULL,
	Season	INT NULL,
	Week	INT NULL,
	Date	DATE NULL,
	HomeTeamID	INT NULL,
	AwayTeamID	INT NULL,
	HomeTeamScore INT NULL,
	AwayTeamScore INT NULL,
	CONSTRAINT PK_Game_GameID PRIMARY KEY (GameID)
)
GO

CREATE TABLE Team(
	TeamID	INT IDENTITY(1, 1) NOT NULL,
	Prefix_Name	NVARCHAR(50) NULL,
	Name	NVARCHAR(50) NULL,
	Short_Name	NVARCHAR(10) NULL,
	Conference	NVARCHAR(15) NULL,
	Division	NVARCHAR(15) NULL,
	State	NVARCHAR(30) NULL,
	City	NVARCHAR(30) NULL,
	Stadium	NVARCHAR(75) NULL,
	Capacity	INT NULL,
	Longitude	Decimal(10,6) NULL,
	Latitude	Decimal(10,6) NULL,
	CONSTRAINT PK_Team_TeamID PRIMARY KEY (TeamID)
)
GO

CREATE TABLE Player(
	PlayerID	NVARCHAR(10) NOT NULL,
	Name	NVARCHAR(100) NOT NULL,
	CONSTRAINT PK_Player_PlayerID_Name PRIMARY KEY (PlayerID, Name)
)
GO

CREATE TABLE SeasonRecord(
	TeamID	INT NOT NULL,
	Season	INT NOT NULL,
	Win	INT NULL,
	Lose 	INT NULL,
	Tie	INT NULL,
	Win_Percentage	AS CAST(Win / CAST((Win + Lose + Tie) AS DECIMAL(5,3)) AS DECIMAL(5,3)),
	Points_For	INT NULL,
	Points_Against	INT NULL,
	Home	NVARCHAR(10) NULL,
	Away	NVARCHAR(10) NULL,
	CONSTRAINT PK_SeasonRecord_TeamID_Season PRIMARY KEY (TeamID, Season)
)
GO

CREATE TABLE PlayByPlay(
	Date	DATE NULL,
	GameID INT NULL,
	Drive	FLOAT NULL,
	Qtr	FLOAT NULL,
	Down	FLOAT NULL,
	Time	TIME NULL,
	TimeUnder	FLOAT NULL,
	TimeSecs	FLOAT NULL,
	PlayTimeDiff	FLOAT NULL,
	SideofField	NVARCHAR(10) NULL,
	YardLine	FLOAT NULL,
	YardLine100	FLOAT NULL,
	YardstoGo	FLOAT NULL,
	YardsNet	FLOAT NULL,
	GoalToGo	FLOAT NULL,
	FirstDown	FLOAT NULL,
	OffensiveTeam	NVARCHAR(10) NULL,
	DefensiveTeam	NVARCHAR(10) NULL,
	Desccription	NVARCHAR(4000) NULL,
	PlayAttempted	FLOAT NULL,
	YardsGained	FLOAT NULL,
	ScoringPlay	FLOAT NULL,
	Touchdown	FLOAT NULL,
	ExtraPointResult	NVARCHAR(30) NULL,
	TwoPointConversion	NVARCHAR(30) NULL,
	DefensiveTwoPoint	NVARCHAR(30) NULL,
	Safety	FLOAT NULL,
	Onsidekick	FLOAT NULL,
	PuntResult	NVARCHAR(30) NULL,
	PlayType	NVARCHAR(30) NULL,
	Passer	NVARCHAR(100) NULL,
	PasserID	NVARCHAR(10) NULL,
	PassAttempt	FLOAT NULL,
	PassOutcome	NVARCHAR(30) NULL,
	PassLength	NVARCHAR(30) NULL,
	AirYards	FLOAT NULL,
	YardsAfterCatch	FLOAT NULL,
	QBHit	FLOAT NULL,
	PassLocation	NVARCHAR(30) NULL,
	InterceptionThrown	FLOAT NULL,
	Interceptor	NVARCHAR(100) NULL,
	Rusher	NVARCHAR(100) NULL,
	RusherID	NVARCHAR(10) NULL,
	RushAttempt	FLOAT NULL,
	RunLocation	NVARCHAR(30) NULL,
	RunGap	NVARCHAR(30) NULL,
	Receiver	NVARCHAR(100) NULL,
	ReceiverID	NVARCHAR(10) NULL,
	Reception	FLOAT NULL,
	ReturnResult	NVARCHAR(30) NULL,
	Returner	NVARCHAR(100) NULL,
	BlockingPlayer	NVARCHAR(100) NULL,
	Tackler1	NVARCHAR(100) NULL,
	Tackler2	NVARCHAR(100) NULL,
	FieldGoalResult	NVARCHAR(30) NULL,
	FieldGoalDistance	NVARCHAR(30) NULL,
	Fumble	FLOAT NULL,
	RecoverFumbTeam	NVARCHAR(10) NULL,
	RecoverFumbPlayer	NVARCHAR(100) NULL,
	Sack	FLOAT NULL,
	ChallengeReplay	FLOAT NULL,
	ChalReplayResult	NVARCHAR(30) NULL,
	AcceptedPenalty	FLOAT NULL,
	PenalizedTeam	NVARCHAR(10) NULL,
	PenaltyType	NVARCHAR(4000) NULL,
	PenalizedPlayer	NVARCHAR(100) NULL,
	PenaltyYards	FLOAT NULL,
	OffensiveTeamScore	FLOAT NULL,
	DefTeamScore	FLOAT NULL,
	ScoreDiff	FLOAT NULL,
	AbsScoreDiff	FLOAT NULL,
	HomeTeam	NVARCHAR(10) NULL,
	AwayTeam	NVARCHAR(10) NULL,
	TimeoutIndicator	FLOAT NULL,
	TimeoutTeam	NVARCHAR(10) NULL,
	OffensiveTeamTimeoutsPre	FLOAT NULL,
	HomeTimeoutsRemainingPre	FLOAT NULL,
	AwayTimeoutsRemainingPre	FLOAT NULL,
	HomeTimeoutsRemainingPost	FLOAT NULL,
	AwayTimeoutsRemainingPost	FLOAT NULL,
	Season	FLOAT NULL
)
GO

/*
Loads [Team] table with all team information.
Does not change unless a team metadata changes.
*/
INSERT INTO Team(Prefix_Name, Name, Short_Name, Conference, Division, State, City, Stadium, Capacity, Longitude, Latitude)
VALUES ('Buffalo', 'Bills', 'BUF', 'American', 'East', 'New York', 'Orchard Park', 'New Era Field', 71608, 42.774000, -78.787000),
('Miami', 'Dolphins', 'MIA', 'American', 'East', 'Florida', 'Miami Gardens', 'Hard Rock Stadium', 65326, 25.958000, -80.239000),
('New England', 'Patriots', 'NE', 'American', 'East', 'Massachusetts', 'Foxborough', 'Gillette Stadium', 66829, 42.091000, -71.264000),
('New York', 'Jets', 'NYJ', 'American', 'East', 'New Jersey', 'East Rutherford', 'MetLife Stadium', 82500, 40.814000, -74.074000),
('Baltimore', 'Ravens', 'BAL', 'American', 'North', 'Maryland', 'Baltimore', 'M&T Bank Stadium', 71008, 39.278000, -76.623000),
('Cincinnati', 'Bengals', 'CIN', 'American', 'North', 'Ohio', 'Cincinnati', 'Paul Brown Stadium', 65515, 39.095000, -84.516000),
('Cleveland', 'Browns', 'CLE', 'American', 'North', 'Ohio', 'Cleveland', 'FirstEnergy Stadium', 67431, 41.506000, -81.699000),
('Pittsburgh', 'Steelers', 'PIT', 'American', 'North', 'Pennsylvania', 'Pittsburgh', 'Heinz Field', 68400, 40.447000, -80.016000),
('Houston', 'Texans', 'HOU', 'American', 'South', 'Texas', 'Houston', 'NRG Stadium', 72220, 29.685000, -95.411000),
('Indianapolis', 'Colts', 'IND', 'American', 'South', 'Indiana', 'Indianapolis', 'Lucas Oil Stadium', 67000, 39.760000, -86.164000),
('Jacksonville', 'Jagurs', 'JAC', 'American', 'South', 'Florida', 'Jacksonville', 'TIAA Bank Field', 67246, 30.324000, -81.638000),
('Tennessee', 'Titans', 'TEN', 'American', 'South', 'Tennessee', 'Nashville', 'Nissan Stadium', 69143, 36.166000, -86.771000),
('Denver', 'Broncos', 'DEN', 'American', 'West', 'Denver', 'Colorado', 'Sports Authority Field at Mile High', 76125, 39.744000, -105.020000),
('Kansas City', 'Chiefs', 'KC', 'American', 'West', 'Missouri', 'Kansas City', 'Arrowhead Stadium', 76416, 39.049000, -94.484000),
('Los Angeles', 'Chargers', 'LAC', 'American', 'West', 'California', 'Carson', 'StubHub Center', 27000, 33.864000, -118.261000),
('Oakland', 'Raiders', 'OAK', 'American', 'West', 'California', 'Oakland', 'Oakland–Alameda County Coliseum', 56063, 37.752000, -122.201000),
('Dallas', 'Cowboys', 'DAL', 'National', 'East', 'Texas', 'Arlington', 'AT&T Stadium', 80000, 32.748000, -97.093000),
('New York', 'Giants', 'NYG', 'National', 'East', 'New Jersey', 'East Rutherford', 'MetLife Stadium', 82500, 40.814000, -74.074000),
('Philadelphia', 'Eagles', 'PHI', 'National', 'East', 'Pennsylvania', 'Philadelphia', 'Lincoln Financial Field', 69596, 39.901000, -75.168000),
('Washington', 'Redskins', 'WAS', 'National', 'East', 'Maryland', 'Landover', 'FedExField', 82000, 38.908000, -76.864000),
('Chicago', 'Bears', 'CHI', 'National', 'North', 'Illinois', 'Chicago', 'Soldier Field', 61500, 41.863000, -87.617000),
('Detroit', 'Lions', 'DET', 'National', 'North', 'Michigan', 'Detroit', 'Ford Field', 65000, 42.340000, -83.046000),
('Green Bay', 'Packers', 'GB', 'National', 'North', 'Wisconsin', 'Green Bay', 'Lambeau Field', 81435, 44.501000, -88.062000),
('Minnesota', 'Vikings', 'MIN', 'National', 'North', 'Minnesota', 'Minneapolis', 'U.S. Bank Stadium', 66655, 44.974000, -93.258000),
('Atlanta', 'Falcons', 'ATL', 'National', 'South', 'Georgia', 'Atlanta', 'Mercedes-Benz Stadium', 71000, 33.755000, -84.401000),
('Carolina', 'Panthers', 'CAR', 'National', 'South', 'North Carolina', 'Charlotte', 'Bank of America Stadium', 75419, 35.226000, -80.853000),
('New Orleans', 'Saints', 'NO', 'National', 'South', 'Louisiana', 'New Orleans', 'Mercedes-Benz Superdome', 73000, 29.951000, -90.081000),
('Tampa Bay ', 'Buccaneers', 'TB', 'National', 'South', 'Florida', 'Tampa', 'Raymond James Stadium', 65890, 27.976000, -82.503000),
('Arizona', 'Cardinals', 'ARI', 'National', 'West', 'Arizona', 'Glendale', 'University of Phoenix Stadium', 63400, 33.528000, -112.263000),
('Los Angeles', 'Rams', 'LA', 'National', 'West', 'California', 'Los Angeles', 'Los Angeles Memorial Coliseum', 93607, 34.014000, -118.288000),
('San Francisco', '49ers', 'SF', 'National', 'West', 'California', 'Santa Clara', 'Levi''s Stadium', 68500, 37.403000, -121.970000),
('Seattle', 'Seahawks', 'SEA', 'National', 'West', 'Washington', 'Seattle', 'CenturyLink Field', 68000, 47.595000, -122.332000),
('St. Louis', 'Rams', 'STL', 'National', 'West', 'Missouri', 'St. Louis', 'The Dome at America''s Center', 70000, 38.632778, -90.188611),
('Jacksonville', 'Jagurs', 'JAX', 'American', 'South', 'Florida', 'Jacksonville', 'TIAA Bank Field', 67246, 30.324000, -81.638000),
('San Diego', 'Chargers', 'SD', 'American', 'West', 'California', 'Carson', 'San Diego County Credit Union Stadium', 70561, 32.783056, -117.119444)
GO