CREATE DATABASE ColonialJourney

--01. DDL
CREATE TABLE Planets
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL
)

CREATE TABLE Spaceports
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	PlanetId INT FOREIGN KEY REFERENCES Planets(Id) NOT NULL,
)

CREATE TABLE Spaceships
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	Manufacturer VARCHAR(30) NOT NULL,
	LightSpeedRate INT DEFAULT(0)
)

CREATE TABLE Colonists
(
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(20) NOT NULL,
	LastName VARCHAR(20) NOT NULL,
	Ucn VARCHAR(10) NOT NULL UNIQUE,
	BirthDate DATE NOT NULL
)

CREATE TABLE Journeys
(
	Id INT PRIMARY KEY IDENTITY,
	JourneyStart DATETIME NOT NULL,
	JourneyEnd DATETIME NOT NULL,
	Purpose VARCHAR(11) CHECK(Purpose = 'Medical'OR Purpose = 'Technical' OR Purpose = 'Educational' OR Purpose = 'Military'),
	DestinationSpaceportId INT FOREIGN KEY REFERENCES Spaceports(Id) NOT NULL,
	SpaceshipId INT FOREIGN KEY REFERENCES Spaceships(Id) NOT NULL
)

CREATE TABLE TravelCards
(
	Id INT PRIMARY KEY IDENTITY,
	CardNumber VARCHAR(10) CHECK (LEN(CardNumber) = 10) NOT NULL UNIQUE,
	JobDuringJourney VARCHAR(8) CHECK(JobDuringJourney = 'Pilot' OR JobDuringJourney = 'Engineer' OR JobDuringJourney = 'Trooper' OR JobDuringJourney = 'Cleaner' OR JobDuringJourney = 'Cook'),
	ColonistId INT FOREIGN KEY REFERENCES Colonists(Id),
	JourneyId INT FOREIGN KEY REFERENCES Journeys(Id)
)

--02. Insert
INSERT INTO Planets([Name])
VALUES
('Mars'),
('Earth'),
('Jupiter'),
('Saturn')

INSERT INTO Spaceships([Name], Manufacturer, LightSpeedRate)
VALUES
('Golf', 'VW', 3),
('WakaWaka', 'Wakanda',	4),
('Falcon9',	'SpaceX', 1),
('Bed', 'Vidolov', 6)

--03. Update
UPDATE Spaceships
SET LightSpeedRate = LightSpeedRate + 1
WHERE Id BETWEEN 8 AND 12

--04. Delete
DELETE FROM TravelCards
WHERE JourneyId BETWEEN 1 AND 3

DELETE FROM Journeys
WHERE Id BETWEEN 1 AND 3

--05. Select All Military Journeys
SELECT
	Id,
	FORMAT(JourneyStart, 'dd/MM/yyyy') AS JourneyStart,
	FORMAT(JourneyEnd, 'dd/MM/yyyy') AS JourneyEnd
FROM Journeys
WHERE Purpose = 'Military'
ORDER BY JourneyStart ASC

--06. Select All Pilots
SELECT
	c.Id,
	CONCAT(c.FirstName, ' ', c.LastName) AS full_name
FROM Colonists AS c
JOIN TravelCards AS tc ON c.Id = tc.ColonistId
WHERE tc.JobDuringJourney = 'Pilot'
ORDER BY Id ASC

--07. Count Colonists
SELECT
	COUNT(*) AS count
FROM Colonists AS c
JOIN TravelCards AS tc ON c.Id = tc.ColonistId
JOIN Journeys AS j ON tc.JourneyId = j.Id
WHERE j.Purpose = 'Technical'

--08. Select Spaceships With Pilots
SELECT
	s.[Name],
	s.Manufacturer
FROM Spaceships AS s
JOIN Journeys AS j ON s.Id = j.SpaceshipId
JOIN TravelCards AS tc ON j.Id = tc.JourneyId
JOIN Colonists AS c ON tc.ColonistId = c.Id
WHERE tc.JobDuringJourney = 'Pilot'
AND DATEDIFF(YEAR, c.BirthDate, '01-01-2019') < 30
ORDER BY s.[Name] ASC

--09. Planets And Journeys
SELECT
	p.[Name] AS PlanetName,
	COUNT(*) AS JourneysCount
FROM Planets AS p
JOIN Spaceports AS s ON p.Id = s.PlanetId
JOIN Journeys AS j ON s.Id = j.DestinationSpaceportId
GROUP BY p.[Name]
ORDER BY JourneysCount DESC, p.[Name] ASC

--10. Select Special Colonists
SELECT JobDuringJourney,FULLNAME, RANKQUERY.RANK
     FROM (SELECT TC.JobDuringJourney AS JobDuringJourney,
       C.FirstName+' '+C.LastName AS FULLNAME,
      ( DENSE_RANK() over (PARTITION BY TC.JobDuringJourney ORDER BY C.BirthDate)) AS RANK
FROM Colonists AS C
JOIN TravelCards TC on C.Id = TC.ColonistId) AS RANKQUERY
WHERE RANK=2

--11. Get Colonists Count
CREATE FUNCTION dbo.udf_GetColonistsCount (@PlanetName VARCHAR (30)) 
RETURNS INT
BEGIN
	DECLARE @countOfColonists INT = 
	(
		SELECT 
			COUNT(c.Id)
		FROM Planets AS p
		JOIN Spaceports AS s ON p.Id = s.PlanetId
		JOIN Journeys AS j ON s.Id = j.DestinationSpaceportId
		JOIN TravelCards AS tc ON j.Id = tc.JourneyId
		JOIN Colonists AS c ON tc.ColonistId = c.Id
		WHERE p.[Name] = @PlanetName
 	)

	RETURN @countOfColonists
END

--12. Change Journey Purpose 
CREATE PROC usp_ChangeJourneyPurpose(@JourneyId INT, @NewPurpose VARCHAR(11))
AS
BEGIN
	IF(@JourneyId NOT IN(SELECT Id FROM Journeys))
		THROW 50001, 'The journey does not exist!', 1
	IF((SELECT 
		COUNT(*) 
		FROM Journeys 
		WHERE Id = @JourneyId 
		AND Purpose = @NewPurpose) != 0)
		THROW 50001, 'You cannot change the purpose!', 1

	UPDATE Journeys
	SET Purpose = @NewPurpose
	WHERE Id = @JourneyId
END