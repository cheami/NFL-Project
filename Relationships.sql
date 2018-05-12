USE NFL
GO

/*
[Game] table relationships.
[HomeTeamID] column references [TeamID] column on [Team] table.
[AwayTeamID] column references [TeamID] column on [Team] table.
*/
ALTER TABLE Game
WITH CHECK 
ADD CONSTRAINT FK_Game_Team_TeamID_HomeTeamID FOREIGN KEY(HomeTeamID)
	REFERENCES Team(TeamID)
GO

ALTER TABLE Game 
WITH CHECK 
ADD CONSTRAINT FK_Game_Team_TeamID_AwayTeamID FOREIGN KEY(AwayTeamID)
	REFERENCES Team(TeamID)
GO

/*
[SeasonRecord] table relationships.
[TeamID] column references [TeamID] column on [Team] table.
*/
ALTER TABLE SeasonRecord 
WITH CHECK 
ADD CONSTRAINT FK_SeasonRecord_Team_TeamID_TeamID FOREIGN KEY(TeamID)
	REFERENCES Team(TeamID)
GO

/*
[GamePassing] table relationships.
[GameID] column references [GameID] column on [Game] table.
[PasserID] and [Player_Name] columns references [PlayerID] and [Name] columns on [Player] table.
[TeamID] column references [TeamID] column on [Team] table.
[OpponentID] column references [TeamID] column on [Team] table.
*/
ALTER TABLE GamePassing 
WITH CHECK 
ADD CONSTRAINT FK_GamePassing_Game_GameID_GameID FOREIGN KEY(GameID)
	REFERENCES Game(GameID)
GO

ALTER TABLE GamePassing 
WITH CHECK 
ADD CONSTRAINT FK_GamePassing_Player_PlayerID_PasserID_Name_Player_Name FOREIGN KEY(PasserID, Player_Name)
	REFERENCES Player(PlayerID, Name)
GO

ALTER TABLE GamePassing 
WITH CHECK 
ADD CONSTRAINT FK_GamePassing_Team_TeamID_TeamID FOREIGN KEY(TeamID)
	REFERENCES Team(TeamID)
GO

ALTER TABLE GamePassing 
WITH CHECK 
ADD CONSTRAINT FK_GamePassing_Team_TeamID_OpponentID FOREIGN KEY(OpponentID)
	REFERENCES Team(TeamID)
GO

/*
[GameRushing] table relationships.
[GameID] column references [GameID] column on [Game] table.
[RusherID] and [Player_Name] columns references [PlayerID] and [Name] columns on [Player] table.
[TeamID] column references [TeamID] column on [Team] table.
[OpponentID] column references [TeamID] column on [Team] table.
*/
ALTER TABLE GameRushing 
WITH CHECK 
ADD CONSTRAINT FK_GameRushing_Game_GameID_GameID FOREIGN KEY(GameID)
	REFERENCES Game(GameID)
GO

ALTER TABLE GameRushing 
WITH CHECK 
ADD CONSTRAINT FK_GameRushing_Player_PlayerID_RusherID_Name_Player_Name FOREIGN KEY(RusherID, Player_Name)
	REFERENCES Player(PlayerID, Name)
GO

ALTER TABLE GameRushing 
WITH CHECK 
ADD CONSTRAINT FK_GameRushing_Team_TeamID_TeamID FOREIGN KEY(TeamID)
	REFERENCES Team(TeamID)
GO

ALTER TABLE GameRushing 
WITH CHECK 
ADD CONSTRAINT FK_GameRushing_Team_TeamID_OpponentID FOREIGN KEY(OpponentID)
	REFERENCES Team(TeamID)
GO

/*
[GameReceiving] table relationships.
[GameID] column references [GameID] column on [Game] table.
[ReceiverID] and [Player_Name] columns references [PlayerID] and [Name] columns on [Player] table.
[TeamID] column references [TeamID] column on [Team] table.
[OpponentID] column references [TeamID] column on [Team] table.
*/
ALTER TABLE GameReceiving 
WITH CHECK 
ADD CONSTRAINT FK_GameReceiving_Game_GameID_GameID FOREIGN KEY(GameID)
	REFERENCES Game(GameID)
GO

ALTER TABLE GameReceiving 
WITH CHECK 
ADD CONSTRAINT FK_GameReceiving_Player_PlayerID_ReceiverID_Name_Player_Name FOREIGN KEY(ReceiverID, Player_Name)
	REFERENCES Player(PlayerID, Name)
GO

ALTER TABLE GameReceiving 
WITH CHECK 
ADD CONSTRAINT FK_GameReceiving_Team_TeamID_TeamID FOREIGN KEY(TeamID)
	REFERENCES Team(TeamID)
GO

ALTER TABLE GameReceiving 
WITH CHECK 
ADD CONSTRAINT FK_GameReceiving_Team_TeamID_OpponentID FOREIGN KEY(OpponentID)
	REFERENCES Team(TeamID)
GO


