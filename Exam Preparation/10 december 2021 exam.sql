CREATE DATABASE Airport

--01. DDL
CREATE TABLE Passengers
(
	Id INT IDENTITY PRIMARY KEY,
	FullName VARCHAR(100) NOT NULL UNIQUE,
	Email VARCHAR(50) NOT NULL UNIQUE
)

CREATE TABLE Pilots
(
	Id INT IDENTITY PRIMARY KEY,
	FirstName VARCHAR(30) NOT NULL UNIQUE,
	LastName VARCHAR(30) NOT NULL UNIQUE,
	Age TINYINT NOT NULL CHECK(Age >= 21 AND Age <= 62),
	Rating FLOAT CHECK(Rating >= 0.0 AND Rating <= 10.0)
)

CREATE TABLE AircraftTypes
(
	Id INT IDENTITY PRIMARY KEY,
	TypeName VARCHAR(30) NOT NULL UNIQUE
)

CREATE TABLE Aircraft
(
	Id INT IDENTITY PRIMARY KEY,
	Manufacturer VARCHAR(25) NOT NULL,
	Model VARCHAR(30) NOT NULL,
	[Year] INT NOT NULL,
	FlightHours INT,
	Condition CHAR(1) NOT NULL,
	TypeId INT NOT NULL FOREIGN KEY REFERENCES AircraftTypes(Id)
)

CREATE TABLE PilotsAircraft
(
	AircraftId INT NOT NULL FOREIGN KEY REFERENCES Aircraft(Id),
	PilotId INT NOT NULL FOREIGN KEY REFERENCES Pilots(Id)
	PRIMARY KEY(AircraftId, PilotId)
)

CREATE TABLE Airports
(
	Id INT IDENTITY PRIMARY KEY,
	AirportName VARCHAR(70) NOT NULL UNIQUE,
	Country VARCHAR(100) NOT NULL UNIQUE
)

CREATE TABLE FlightDestinations
(
	Id INT IDENTITY PRIMARY KEY,
	AirportId INT NOT NULL FOREIGN KEY REFERENCES Airports(Id),
	[Start] DATETIME NOT NULL,
	AircraftId INT NOT NULL FOREIGN KEY REFERENCES Aircraft(Id),
	PassengerId INT NOT NULL FOREIGN KEY REFERENCES Passengers(Id),
	TicketPrice DECIMAL(18,2) NOT NULL DEFAULT(15)
)

--02. Insert
INSERT INTO Passengers
SELECT
	p.FirstName + ' ' + p.LastName,
	p.FirstName + p.LastName + '@gmail.com' 
FROM Pilots AS p
WHERE p.Id BETWEEN 5 AND 15

--03. Update
UPDATE Aircraft
SET Condition = 'A'
WHERE Condition IN ('C', 'B')
AND (FlightHours IS NULL OR FlightHours <= 100)
AND [Year] >= 2013

--04. Delete
DELETE FROM Passengers
WHERE LEN(FullName) <= 10

--05. Aircraft
SELECT
	Manufacturer,
	Model,
	FlightHours,
	Condition
FROM Aircraft
ORDER BY FlightHours DESC

--06. Pilots and Aircraft
SELECT
	p.FirstName,
	p.LastName,
	a.Manufacturer,
	a.Model,
	a.FlightHours
FROM Pilots AS p
JOIN PilotsAircraft AS pa ON p.Id = pa.PilotId
JOIN Aircraft AS a ON pa.AircraftId = a.Id
WHERE a.FlightHours IS NOT NULL
AND a.FlightHours <= 304
ORDER BY a.FlightHours DESC, p.FirstName ASC

--07. Top 20 Flight Destinations
SELECT TOP(20)
	fd.Id,
	fd.[Start],
	p.FullName,
	a.AirportName,
	fd.TicketPrice
FROM FlightDestinations AS fd
JOIN Airports AS a ON fd.AirportId = a.Id
JOIN Passengers AS p ON fd.PassengerId = p.Id
WHERE DAY([Start])% 2 = 0
ORDER BY fd.TicketPrice DESC, a.AirportName ASC

--08. Number of Flights for Each Aircraft
SELECT
	a.Id,
	a.Manufacturer,
	a.FlightHours,
	COUNT(*) AS FlightDestinationsCount,
	ROUND(AVG(fd.TicketPrice),2) AS AvgPrice
FROM Aircraft AS a
JOIN FlightDestinations AS fd ON a.Id = fd.AircraftId
GROUP BY a.Id, a.Manufacturer, a.FlightHours
HAVING COUNT(*) >= 2
ORDER BY FlightDestinationsCount DESC, a.Id ASC

--09. Regular Passengers
SELECT
	p.FullName,
	COUNT(fd.TicketPrice) AS CountOfAircraft,
	SUM(fd.TicketPrice) AS TotalPayed
FROM Passengers AS p
JOIN FlightDestinations AS fd ON p.Id = fd.PassengerId
WHERE p.FullName LIKE '_a%'
GROUP BY p.FullName
HAVING COUNT(fd.TicketPrice) > 1
ORDER BY p.FullName ASC

--10. Full Info for Flight Destinations
SELECT 
	ai.AirportName,
	fd.Start,
	fd.TicketPrice,
	p.FullName,
	a.Manufacturer,
	a.Model
FROM Aircraft AS a
JOIN FlightDestinations AS fd ON a.Id = fd.AircraftId
JOIN Airports AS ai ON fd.AirportId = ai.Id
JOIN Passengers AS p ON fd.PassengerId = p.Id
WHERE DATEPART(hour, fd.Start) BETWEEN 6 AND 20
AND fd.TicketPrice > 2500
ORDER BY a.Model ASC

--11. Find all Destinations by Email Address
CREATE FUNCTION udf_FlightDestinationsByEmail(@email VARCHAR(50)) 
RETURNS INT 
AS
BEGIN 
	DECLARE @countOfFlights INT =
	(
		SELECT 
			COUNT(*)
		FROM Passengers AS p
		JOIN FlightDestinations AS fd ON p.Id = fd.PassengerId
		WHERE p.Email = @email
	)
	RETURN @countOfFlights
END

--12. Full Info for Airports
CREATE PROC usp_SearchByAirportName (@airportName VARCHAR(70))
AS
	SELECT
		a.AirportName,
		p.FullName,
		CASE
			WHEN fd.TicketPrice <= 400 THEN 'Low'
			WHEN fd.TicketPrice BETWEEN 401 AND 1500 THEN 'Medium'
			WHEN fd.TicketPrice >= 1501 THEN 'High'
        END AS LevelOfTicketPrice,
		cr.Manufacturer,
		cr.Condition,
		crt.TypeName
	FROM Airports AS a
	JOIN FlightDestinations AS fd ON a.Id = fd.AirportId
	JOIN Passengers AS p ON fd.PassengerId = p.Id
	JOIN Aircraft AS cr ON fd.AircraftId = cr.Id
	JOIN AircraftTypes AS crt ON cr.TypeId = crt.Id
	WHERE a.AirportName = @airportName
	ORDER BY cr.Manufacturer ASC, p.FullName ASC
