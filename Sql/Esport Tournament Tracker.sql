
    DROP DATABASE EsportsTournamentDB;
CREATE DATABASE EsportsTournamentDB;
GO

USE EsportsTournamentDB;
GO

CREATE TABLE Organizer (
    OrganizerID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(15) NOT NULL,
    Organization VARCHAR(100) NULL
);

CREATE TABLE Game (
    GameID INT IDENTITY(1,1) PRIMARY KEY,
    GameName VARCHAR(50) NOT NULL UNIQUE,
    Genre VARCHAR(50) NOT NULL,
    TeamSize INT NOT NULL CHECK (TeamSize > 0)
);

CREATE TABLE Team (
    TeamID INT IDENTITY(1,1) PRIMARY KEY,
    TeamName VARCHAR(100) NOT NULL UNIQUE,
    CaptainName VARCHAR(100) NOT NULL,
    Region VARCHAR(50) NOT NULL,
    CoachName VARCHAR(100) NULL
);

CREATE TABLE Tournament (
    TournamentID INT IDENTITY(1,1) PRIMARY KEY,
    TournamentName VARCHAR(100) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    PrizePool DECIMAL(12,2) NOT NULL DEFAULT 0,
    Status VARCHAR(20) NOT NULL DEFAULT 'Upcoming',
    OrganizerID INT NOT NULL,
    GameID INT NOT NULL,

    CONSTRAINT FK_Tournament_Organizer
        FOREIGN KEY (OrganizerID)
        REFERENCES Organizer(OrganizerID),

    CONSTRAINT FK_Tournament_Game
        FOREIGN KEY (GameID)
        REFERENCES Game(GameID),

    CONSTRAINT CK_Tournament_Dates
        CHECK (EndDate >= StartDate),

    CONSTRAINT CK_Tournament_PrizePool
        CHECK (PrizePool >= 0),

    CONSTRAINT CK_Tournament_Status
        CHECK (Status IN
        ('Upcoming','Ongoing','Completed','Cancelled'))
);

CREATE TABLE Player (
    PlayerID INT IDENTITY(1,1) PRIMARY KEY,
    PlayerName VARCHAR(100) NOT NULL,
    IGN VARCHAR(50) NOT NULL UNIQUE,
    Role VARCHAR(30) NOT NULL,
    Country VARCHAR(50) NOT NULL,
    TeamID INT NOT NULL,

    CONSTRAINT FK_Player_Team
        FOREIGN KEY (TeamID)
        REFERENCES Team(TeamID)
);

CREATE TABLE Registration (
    RegistrationID INT IDENTITY(1,1) PRIMARY KEY,
    RegistrationDate DATE NOT NULL DEFAULT GETDATE(),
    Status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    TournamentID INT NOT NULL,
    TeamID INT NOT NULL,

    CONSTRAINT FK_Registration_Tournament
        FOREIGN KEY (TournamentID)
        REFERENCES Tournament(TournamentID),

    CONSTRAINT FK_Registration_Team
        FOREIGN KEY (TeamID)
        REFERENCES Team(TeamID),

    CONSTRAINT CK_Registration_Status
        CHECK (Status IN ('Pending','Confirmed','Cancelled')),

    CONSTRAINT UQ_Registration_Tournament_Team
        UNIQUE (TournamentID, TeamID)
);

CREATE TABLE Match (
    MatchID INT IDENTITY(1,1) PRIMARY KEY,
    MatchNumber INT NOT NULL,
    MatchDate DATE NOT NULL,
    MapName VARCHAR(50) NOT NULL,
    Stage VARCHAR(30) NOT NULL,
    TournamentID INT NOT NULL,

    CONSTRAINT FK_Match_Tournament
        FOREIGN KEY (TournamentID)
        REFERENCES Tournament(TournamentID),

    CONSTRAINT CK_Match_Stage
        CHECK (Stage IN
        ('Group Stage','Quarterfinal','Semifinal','Final')),

    CONSTRAINT UQ_Match_Tournament_Number
        UNIQUE (TournamentID, MatchNumber)
);

CREATE TABLE Match_Result (
    ResultID INT IDENTITY(1,1) PRIMARY KEY,
    Placement INT NOT NULL CHECK (Placement > 0),
    KillPoints INT NOT NULL DEFAULT 0 CHECK (KillPoints >= 0),
    PlacementPoints INT NOT NULL DEFAULT 0 CHECK (PlacementPoints >= 0),

    TotalPoints AS
        (KillPoints + PlacementPoints) PERSISTED,

    MatchID INT NOT NULL,
    TeamID INT NOT NULL,

    CONSTRAINT FK_Result_Match
        FOREIGN KEY (MatchID)
        REFERENCES Match(MatchID),

    CONSTRAINT FK_Result_Team
        FOREIGN KEY (TeamID)
        REFERENCES Team(TeamID),

    CONSTRAINT UQ_Result_Match_Team
        UNIQUE (MatchID, TeamID)
);

CREATE TABLE Sponsor (
    SponsorID INT IDENTITY(1,1) PRIMARY KEY,
    SponsorName VARCHAR(100) NOT NULL,
    Amount DECIMAL(12,2) NOT NULL CHECK (Amount >= 0),
    TournamentID INT NOT NULL,

    CONSTRAINT FK_Sponsor_Tournament
        FOREIGN KEY (TournamentID)
        REFERENCES Tournament(TournamentID)
);

CREATE TABLE Prize (
    PrizeID INT IDENTITY(1,1) PRIMARY KEY,
    Position INT NOT NULL CHECK (Position > 0),
    PrizeAmount DECIMAL(12,2) NOT NULL CHECK (PrizeAmount >= 0),
    TournamentID INT NOT NULL,
    TeamID INT NOT NULL,

    CONSTRAINT FK_Prize_Tournament
        FOREIGN KEY (TournamentID)
        REFERENCES Tournament(TournamentID),

    CONSTRAINT FK_Prize_Team
        FOREIGN KEY (TeamID)
        REFERENCES Team(TeamID),

    CONSTRAINT UQ_Prize_Tournament_Position
        UNIQUE (TournamentID, Position)
);

INSERT INTO Organizer (Name, Email, Phone, Organization) VALUES
('Rajesh Sharma', 'rajesh.sharma@esportsnp.com', '9841000001', 'ProGaming Nepal'),
('Anita Gurung', 'anita.gurung@levelupevents.com', '9841000002', 'LevelUp Events'),
('Bishal Karki', 'bishal.karki@arenaesports.com', '9841000003', 'Arena Esports'),
('Sunita Rai', 'sunita.rai@championsleague.com', '9841000004', 'Champions League Esports');

INSERT INTO Game (GameName, Genre, TeamSize) VALUES
('PUBG Mobile', 'Battle Royale', 4),
('Mobile Legends: Bang Bang', 'MOBA', 5),
('Valorant', 'Tactical Shooter', 5),
('Free Fire', 'Battle Royale', 4),
('Dota 2', 'MOBA', 5);


INSERT INTO Team (TeamName, CaptainName, Region, CoachName) VALUES
('Nepal Tigers', 'Suman Thapa', 'Kathmandu', 'Prakash Bhandari'),
('Himalayan Wolves', 'Kiran Magar', 'Pokhara', 'Rita Shrestha'),
('Kathmandu Kings', 'Bikash Lama', 'Kathmandu', 'Deepak Adhikari'),
('Everest Esports', 'Sabin Tamang', 'Kathmandu', NULL),
('Pokhara Panthers', 'Nabin Gurung', 'Pokhara', 'Sarita KC'),
('Lumbini Legends', 'Rajan Chaudhary', 'Lumbini', NULL),
('Chitwan Chargers', 'Anish Bhatt', 'Chitwan', 'Manisha Rana'),
('Dharan Dragons', 'Sujit Rai', 'Dharan', NULL);

INSERT INTO Tournament
(TournamentName, StartDate, EndDate, PrizePool, Status, OrganizerID, GameID)
VALUES
('PMGC Nepal Series 2026', '2026-01-10', '2026-01-20', 500000, 'Completed', 1, 1),
('MLBB Champions Cup', '2026-02-01', '2026-02-10', 300000, 'Ongoing', 2, 2),
('Valorant Masters Kathmandu', '2026-03-05', '2026-03-15', 700000, 'Upcoming', 3, 3),
('Free Fire Fury League', '2026-01-25', '2026-01-30', 200000, 'Completed', 1, 4),
('Dota 2 Himalayan Cup', '2026-04-01', '2026-04-12', 450000, 'Upcoming', 4, 5);

INSERT INTO Player
(PlayerName, IGN, Role, Country, TeamID)
VALUES
('Suman Thapa','SumanX','IGL','Nepal',1),
('Aakash Basnet','AakashSniper','Assaulter','Nepal',1),
('Ramesh KC','RameshRuler','Support','Nepal',1),

('Kiran Magar','KiranWolf','IGL','Nepal',2),
('Bibek Rana','BibekBlaze','Fragger','Nepal',2),
('Manish Thapa','ManishM','Support','Nepal',2),

('Bikash Lama','BikashKing','IGL','Nepal',3),
('Suraj Shah','SurajFire','Fragger','Nepal',3),
('Nirajan Pandey','NirajanN','Support','Nepal',3),

('Sabin Tamang','SabinPeak','IGL','Nepal',4),
('Yubraj Karki','YubrajY','Fragger','Nepal',4),
('Prashant Poudel','PrashantP','Support','Nepal',4),

('Nabin Gurung','NabinP','IGL','Nepal',5),
('Milan Gharti','MilanG','Fragger','Nepal',5),
('Sandesh Rana','SandeshR','Support','Nepal',5),

('Rajan Chaudhary','RajanL','IGL','Nepal',6),
('Bimal Yadav','BimalY','Fragger','Nepal',6),
('Sanjay Mahato','SanjayM','Support','Nepal',6),

('Anish Bhatt','AnishC','IGL','Nepal',7),
('Roshan Ghimire','RoshanG','Fragger','Nepal',7),
('Deepika Thapa','DeepikaT','Support','Nepal',7),



('Sujit Rai','SujitD','IGL','Nepal',8),
('Alina Limbu','AlinaL','Fragger','Nepal',8),
('Bishwas Rai','BishwasR','Support','Nepal',8);

INSERT INTO Registration
(RegistrationDate, Status, TournamentID, TeamID)
VALUES
('2025-12-20','Confirmed',1,1),
('2025-12-20','Confirmed',1,2),
('2025-12-21','Confirmed',1,3),
('2025-12-21','Confirmed',1,4),
('2026-01-15','Confirmed',2,3),
('2026-01-15','Confirmed',2,4),
('2026-01-16','Confirmed',2,6),
('2026-01-17','Pending',2,7),
('2026-02-15','Confirmed',3,1),
('2026-02-15','Confirmed',3,2),
('2026-02-16','Confirmed',3,8),
('2025-12-28','Confirmed',4,5),
('2025-12-28','Confirmed',4,6),
('2025-12-29','Confirmed',4,7);

INSERT INTO Match
(MatchNumber, MatchDate, MapName, Stage, TournamentID)
VALUES
(1,'2026-01-10','Erangel','Group Stage',1),
(2,'2026-01-12','Miramar','Group Stage',1),
(3,'2026-01-16','Sanhok','Semifinal',1),
(4,'2026-01-20','Erangel','Final',1),

(1,'2026-02-01','Land of Dawn','Group Stage',2),
(2,'2026-02-03','Land of Dawn','Group Stage',2),
(3,'2026-02-06','Land of Dawn','Semifinal',2),
(4,'2026-02-10','Land of Dawn','Final',2),

(1,'2026-01-25','Bermuda','Group Stage',4),
(2,'2026-01-27','Purgatory','Group Stage',4),
(3,'2026-01-29','Bermuda','Semifinal',4),
(4,'2026-01-30','Bermuda','Final',4);

INSERT INTO Match_Result
(Placement, KillPoints, PlacementPoints, MatchID, TeamID)
VALUES
(1,10,10,1,1),
(2,6,8,1,2),
(3,4,6,1,3),
(4,2,4,1,4),

(1,12,10,2,2),
(2,8,8,2,1),
(3,5,6,2,4),
(4,3,4,2,3),

(1,9,10,3,1),
(2,7,8,3,2),

(1,11,10,4,1),
(2,9,8,4,2),

(1,5,10,5,3),
(2,3,8,5,4),

(1,4,10,6,6),
(2,2,8,6,7),

(1,6,10,7,3),
(2,3,8,7,6),

(1,7,10,8,3),
(2,4,8,8,7),

(1,10,10,9,5),
(2,7,8,9,6),
(3,4,6,9,7),
(4,2,4,9,8),

(1,9,10,10,6),
(2,8,8,10,5),
(3,5,6,10,8),
(4,3,4,10,7),

(1,6,10,11,5),
(2,4,8,11,6),

(1,8,10,12,5),
(2,5,8,12,6);

INSERT INTO Sponsor
(SponsorName, Amount, TournamentID)
VALUES
('TitanTech Gadgets', 150000, 1),
('RedBull Energy', 100000, 1),
('NexaMobile', 80000, 2),
('GameFuel Drinks', 60000, 2),
('ProGear Peripherals', 120000, 3),
('CyberNet ISP', 90000, 3),
('Everest Bank', 70000, 4),
('Himalayan Java Coffee', 50000, 4);

INSERT INTO Prize
(Position, PrizeAmount, TournamentID, TeamID)
VALUES
(1,300000,1,1),
(2,150000,1,2),
(3,50000,1,4),
(4,20000,1,3),
(1,100000,4,5),
(2,60000,4,6),
(3,40000,4,7);

INSERT INTO Team
(TeamName, CaptainName, Region, CoachName)
VALUES
('Biratnagar Blazers',
 'Nischal Karki',
 'Biratnagar',
 'Uttam Basnet');

INSERT INTO Player
(PlayerName, IGN, Role, Country, TeamID)
VALUES
('Nischal Karki',
 'NischalB',
 'IGL',
 'Nepal',
 9);

 INSERT INTO Registration
(Status, TournamentID, TeamID)
VALUES
('Pending', 3, 9);

UPDATE Team
SET CoachName = 'Rabin Khadka'
WHERE TeamName = 'Everest Esports';

UPDATE Match
SET MatchDate = '2026-03-08'
WHERE MatchID = 12;

UPDATE Tournament
SET Status = 'Completed'
WHERE TournamentID = 2;

UPDATE Player
SET TeamID = 7
WHERE IGN = 'YubrajY';

DELETE FROM Registration
WHERE TournamentID = 2
AND TeamID = 7
AND Status = 'Pending';

DELETE FROM Sponsor
WHERE SponsorName = 'Himalayan Java Coffee'
AND TournamentID = 4;

DELETE FROM Team
WHERE TeamID = 1;

DELETE FROM Player
WHERE TeamID = 9;

DELETE FROM Registration
WHERE TeamID = 9;

DELETE FROM Team
WHERE TeamID = 9;

SELECT * FROM Game;

SELECT
    TournamentName,
    StartDate,
    EndDate,
    PrizePool,
    Status
FROM Tournament;

SELECT
    PlayerName,
    IGN,
    Role
FROM Player;

SELECT TournamentName, Status
FROM Tournament
WHERE Status = 'Ongoing';

SELECT TournamentName, PrizePool
FROM Tournament
WHERE PrizePool > 300000;

SELECT PlayerName, IGN
FROM Player
WHERE Role = 'Fragger'
AND Country = 'Nepal';

SELECT TournamentName, StartDate
FROM Tournament
ORDER BY StartDate ASC;

SELECT TournamentName, PrizePool
FROM Tournament
ORDER BY PrizePool DESC;

SELECT
    T.TeamName,
    SUM(MR.TotalPoints) AS TeamPoints
FROM Team T
JOIN Match_Result MR
    ON T.TeamID = MR.TeamID
GROUP BY T.TeamName
ORDER BY TeamPoints DESC;

SELECT COUNT(*) AS TotalRegistrations
FROM Registration;

SELECT SUM(PrizeAmount) AS TotalPrizeAwarded
FROM Prize;

SELECT AVG(PrizePool) AS AveragePrizePool
FROM Tournament;

SELECT MAX(KillPoints) AS HighestKillPoints
FROM Match_Result;

SELECT MIN(StartDate) AS EarliestTournament
FROM Tournament;

SELECT
    T.TeamName,
    SUM(MR.TotalPoints) AS TotalPoints
FROM Team T
JOIN Match_Result MR
    ON T.TeamID = MR.TeamID
GROUP BY T.TeamName;

SELECT
    TO2.TournamentName,
    COUNT(R.TeamID) AS NumberOfTeams
FROM Tournament TO2
JOIN Registration R
    ON TO2.TournamentID = R.TournamentID
GROUP BY TO2.TournamentName;

SELECT
    T.TeamName,
    COUNT(P.PlayerID) AS NumberOfPlayers
FROM Team T
JOIN Player P
    ON T.TeamID = P.TeamID
GROUP BY T.TeamName;

SELECT
    TO2.TournamentName,
    SUM(PZ.PrizeAmount) AS TotalPrizeAmount
FROM Tournament TO2
JOIN Prize PZ
    ON TO2.TournamentID = PZ.TournamentID
GROUP BY TO2.TournamentName;

SELECT
    T.TeamName,
    SUM(MR.TotalPoints) AS TotalPoints
FROM Team T
JOIN Match_Result MR
    ON T.TeamID = MR.TeamID
GROUP BY T.TeamName
HAVING SUM(MR.TotalPoints) > 50
ORDER BY TotalPoints DESC;

SELECT
    T.TournamentName,
    O.Name AS OrganizerName,
    O.Organization
FROM Tournament T
INNER JOIN Organizer O
    ON T.OrganizerID = O.OrganizerID;

SELECT
    TE.TeamName,
    R.Status,
    R.RegistrationDate
FROM Registration R
INNER JOIN Team TE
    ON R.TeamID = TE.TeamID
WHERE R.TournamentID = 1;

SELECT
    T.TournamentName,
    G.GameName,
    G.Genre
FROM Tournament T
INNER JOIN Game G
    ON T.GameID = G.GameID;

SELECT
    P.PlayerName,
    P.IGN,
    TE.TeamName
FROM Player P
INNER JOIN Team TE
    ON P.TeamID = TE.TeamID;

SELECT
    T.TournamentName,
    S.SponsorName,
    S.Amount
FROM Tournament T
LEFT JOIN Sponsor S
    ON T.TournamentID = S.TournamentID;

SELECT
    TN.TournamentName,
    M.MatchNumber,
    M.Stage,
    TE.TeamName,
    MR.Placement,
    MR.KillPoints,
    MR.PlacementPoints,
    MR.TotalPoints
FROM Match_Result MR
JOIN Match M
    ON MR.MatchID = M.MatchID
JOIN Tournament TN
    ON M.TournamentID = TN.TournamentID
JOIN Team TE
    ON MR.TeamID = TE.TeamID
ORDER BY
    TN.TournamentName,
    M.MatchNumber,
    MR.Placement;

SELECT
    T.TeamName,
    SUM(MR.TotalPoints) AS TotalPoints
FROM Team T
JOIN Match_Result MR
    ON T.TeamID = MR.TeamID
GROUP BY T.TeamName
HAVING SUM(MR.TotalPoints) = (
    SELECT MAX(TeamTotal.TotalPoints)
    FROM (
        SELECT
            SUM(TotalPoints) AS TotalPoints
        FROM Match_Result
        GROUP BY TeamID
    ) AS TeamTotal
);

SELECT
    TournamentName,
    PrizePool
FROM Tournament
WHERE PrizePool = (
    SELECT MAX(PrizePool)
    FROM Tournament
);

SELECT
    P.PlayerName,
    P.IGN,
    P.TeamID
FROM Player P
WHERE P.TeamID IN (
    SELECT R.TeamID
    FROM Registration R
    WHERE R.TournamentID = 1
);

SELECT
    TE.TeamName,
    SUM(MR.KillPoints) AS TotalKillPoints,
    SUM(MR.PlacementPoints) AS TotalPlacementPoints,
    SUM(MR.TotalPoints) AS TotalPoints,
    COUNT(MR.MatchID) AS MatchesPlayed
FROM Match_Result MR
JOIN Match M
    ON MR.MatchID = M.MatchID
JOIN Team TE
    ON MR.TeamID = TE.TeamID
WHERE M.TournamentID = 1
GROUP BY TE.TeamName
ORDER BY TotalPoints DESC;

CREATE VIEW TournamentSummaryView AS
SELECT
    T.TournamentID,
    T.TournamentName,
    T.StartDate,
    T.EndDate,
    T.PrizePool,
    T.Status,
    O.Name AS OrganizerName,
    G.GameName
FROM Tournament T
JOIN Organizer O
    ON T.OrganizerID = O.OrganizerID
JOIN Game G
    ON T.GameID = G.GameID;

SELECT *
FROM TournamentSummaryView
ORDER BY StartDate;

CREATE VIEW TeamLeaderboardView AS
SELECT
    TE.TeamID,
    TE.TeamName,
    SUM(MR.KillPoints) AS TotalKillPoints,
    SUM(MR.PlacementPoints) AS TotalPlacementPoints,
    SUM(MR.TotalPoints) AS TotalPoints,
    COUNT(MR.MatchID) AS MatchesPlayed
FROM Team TE
JOIN Match_Result MR
    ON TE.TeamID = MR.TeamID
GROUP BY
    TE.TeamID,
    TE.TeamName;

SELECT *
FROM TeamLeaderboardView
ORDER BY TotalPoints DESC;

CREATE VIEW MatchResultsView AS
SELECT
    TN.TournamentName,
    M.MatchNumber,
    M.Stage,
    M.MapName,
    TE.TeamName,
    MR.Placement,
    MR.KillPoints,
    MR.PlacementPoints,
    MR.TotalPoints
FROM Match_Result MR
JOIN Match M
    ON MR.MatchID = M.MatchID
JOIN Tournament TN
    ON M.TournamentID = TN.TournamentID
JOIN Team TE
    ON MR.TeamID = TE.TeamID;

SELECT *
FROM MatchResultsView
WHERE TournamentName = 'PMGC Nepal Series 2026';

CREATE PROCEDURE RegisterTeamForTournament
    @TournamentID INT,
    @TeamID INT,
    @Status VARCHAR(20) = 'Pending'
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM Registration
        WHERE TournamentID = @TournamentID
          AND TeamID = @TeamID
    )
    BEGIN
        RAISERROR(
            'This team is already registered for the tournament.',
            16,
            1
        );
        RETURN;
    END;

    INSERT INTO Registration
        (RegistrationDate, Status, TournamentID, TeamID)
    VALUES
        (GETDATE(), @Status, @TournamentID, @TeamID);
END;
GO

EXEC RegisterTeamForTournament
    @TournamentID = 5,
    @TeamID = 3,
    @Status = 'Pending';

CREATE PROCEDURE AddMatchResult
    @MatchID INT,
    @TeamID INT,
    @Placement INT,
    @KillPoints INT,
    @PlacementPoints INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TournamentID INT;

    SELECT @TournamentID = TournamentID
    FROM Match
    WHERE MatchID = @MatchID;

    IF NOT EXISTS (
        SELECT 1
        FROM Registration
        WHERE TournamentID = @TournamentID
        AND TeamID = @TeamID
    )
    BEGIN
        RAISERROR(
            'The team is not registered for this tournament.',
            16,
            1
        );
        RETURN;
    END

    INSERT INTO Match_Result
    (Placement, KillPoints, PlacementPoints, MatchID, TeamID)
    VALUES
    (@Placement, @KillPoints, @PlacementPoints, @MatchID, @TeamID);
END;

EXEC AddMatchResult
    @MatchID = 12,
    @TeamID = 3,
    @Placement = 3,
    @KillPoints = 4,
    @PlacementPoints = 6;

CREATE PROCEDURE GetTournamentLeaderboard
    @TournamentID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        TE.TeamName,
        SUM(MR.KillPoints) AS TotalKillPoints,
        SUM(MR.PlacementPoints) AS TotalPlacementPoints,
        SUM(MR.TotalPoints) AS TotalPoints,
        COUNT(MR.MatchID) AS MatchesPlayed
    FROM Match_Result MR
    JOIN Match M
        ON MR.MatchID = M.MatchID
    JOIN Team TE
        ON MR.TeamID = TE.TeamID
    WHERE M.TournamentID = @TournamentID
    GROUP BY TE.TeamName
    ORDER BY TotalPoints DESC;
END;

EXEC GetTournamentLeaderboard
    @TournamentID = 1;

    SELECT * FROM 
    Prize;