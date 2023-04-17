CREATE DATABASE TripService

--01. DDL
CREATE TABLE Cities 
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(20) NOT NULL,
	CountryCode NVARCHAR(2) NOT NULL
)

CREATE TABLE Hotels
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(20) NOT NULL,
	CityId INT FOREIGN KEY REFERENCES Cities(Id) NOT NULL,
	EmployeeCount INT NOT NULL,
	BaseRate DECIMAL(18,2)
)

CREATE TABLE Rooms
(
	Id INT PRIMARY KEY IDENTITY,
	Price DECIMAL(18,2) NOT NULL,
	[Type] NVARCHAR(20) NOT NULL,
	Beds INT NOT NULL,
	HotelId INT FOREIGN KEY REFERENCES Hotels(Id) NOT NULL
)

CREATE TABLE Trips
(
	Id INT PRIMARY KEY IDENTITY,
	RoomId INT FOREIGN KEY REFERENCES Rooms(Id) NOT NULL,
	BookDate DATE NOT NULL,
	ArrivalDate DATE NOT NULL,
	ReturnDate DATE NOT NULL,
	CancelDate DATE,
	CONSTRAINT Checked_BookDate_ArrivalDate CHECK(DATEDIFF(DAY, BookDate, ArrivalDate) > 0),
    CONSTRAINT Checked_ArrivalDate_ReturnDate CHECK(DATEDIFF(DAY, ArrivalDate, ReturnDate) > 0)
)

CREATE TABLE Accounts
(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	MiddleName NVARCHAR(20),
	LastName NVARCHAR(50) NOT NULL,
	CityId INT FOREIGN KEY REFERENCES Cities(Id) NOT NULL,
	BirthDate DATE NOT NULL,
	Email VARCHAR(100) NOT NULL UNIQUE
)

CREATE TABLE AccountsTrips
(
	AccountId INT FOREIGN KEY REFERENCES Accounts(Id),
	TripId INT FOREIGN KEY REFERENCES Trips(Id),
	Luggage INT CHECK(Luggage >= 0) NOT NULL
	PRIMARY KEY(AccountId, TripId)
)

--02. Insert
INSERT INTO Accounts(FirstName, MiddleName, LastName, CityId, BirthDate, Email)
VALUES
('John', 'Smith', 'Smith', 34, '1975-07-21', 'j_smith@gmail.com'),
('Gosho', NULL,	'Petrov', 11, '1978-05-16',	'g_petrov@gmail.com'),
('Ivan', 'Petrovich', 'Pavlov',	59,	'1849-09-26', 'i_pavlov@softuni.bg'),
('Friedrich', 'Wilhelm', 'Nietzsche', 2, '1844-10-15', 'f_nietzsche@softuni.bg')

INSERT INTO Trips(RoomId, BookDate, ArrivalDate, ReturnDate, CancelDate)
VALUES
(101, '2015-04-12',	'2015-04-14', '2015-04-20',	'2015-02-02'),
(102, '2015-07-07',	'2015-07-15', '2015-07-22',	'2015-04-29'),
(103, '2013-07-17',	'2013-07-23', '2013-07-24',	NULL),
(104, '2012-03-17',	'2012-03-31', '2012-04-01',	'2012-01-10'),
(109, '2017-08-07',	'2017-08-28', '2017-08-29',	NULL)

--03. Update
UPDATE Rooms
SET Price = Price * 1.14
WHERE HotelId IN(5, 7, 9)

--04. Delete
DELETE FROM AccountsTrips
WHERE AccountId = 47

--05. EEE-Mails
SELECT
	a.FirstName,
	a.LastName, 
	FORMAT(BirthDate, 'MM-dd-yyyy'),
	c.[Name] AS Hometown,
	a.Email
FROM Accounts AS a
JOIN Cities AS c ON a.CityId = c.Id
WHERE Email LIKE 'e%'
ORDER BY c.[Name] ASC

--06. City Statistics
SELECT 
	c.[Name] AS City,
	COUNT(*) AS Hotels
FROM Cities AS c
JOIN Hotels AS h ON c.Id = h.CityId
GROUP BY c.[Name], c.Id
ORDER BY Hotels DESC, c.[Name] ASC

--07. Longest and Shortest Trips
SELECT 
	a.Id AS AccountId,
	CONCAT(a.FirstName, ' ', a.LastName) AS FullName,
	MAX(DATEDIFF(DAY ,tr.ArrivalDate, tr.ReturnDate)) AS LongestTrip,
	MIN(DATEDIFF(DAY ,tr.ArrivalDate, tr.ReturnDate)) AS ShortestTrip
FROM Accounts AS a
JOIN AccountsTrips AS atr ON a.Id = atr.AccountId
JOIN Trips AS tr ON atr.TripId = tr.Id
WHERE a.MiddleName IS NULL 
AND tr.CancelDate IS NULL
GROUP BY a.Id, a.FirstName, a.LastName
ORDER BY LongestTrip DESC, ShortestTrip ASC

--08. Metropolis
SELECT TOP(10)
	c.Id,
	c.[Name] AS City,
	c.CountryCode AS Country,
	COUNT(*) AS Accounts
FROM Cities AS c
JOIN Accounts AS a ON c.Id = a.CityId
GROUP BY c.Id, c.[Name], c.CountryCode
ORDER BY Accounts DESC

--09. Romantic Getaways
SELECT
	a.Id,
	a.Email,
	c.[Name] AS City,
	COUNT(T2.Id) AS Trips
FROM Accounts AS a
JOIN AccountsTrips T on A.Id = T.AccountId
JOIN Trips T2 on T2.Id = T.TripId
    JOIN Rooms R2 on R2.Id = T2.RoomId
    JOIN Hotels H on A.CityId = H.CityId AND H.Id=R2.HotelId
JOIN Cities C on C.Id = A.CityId
GROUP BY a.Id, a.Email, c.[Name]
HAVING COUNT(T2.Id) >= 1
ORDER BY Trips DESC, a.Id ASC

--10. GDPR Violation
SELECT T.Id,
       CONCAT(A2.FirstName, ' ', ISNULL( A2.MiddleName + ' ',''), A2.LastName)
               AS [Full Name],
       C.Name  AS [From],
       C2.Name AS [To],
       CASE
           WHEN T.CancelDate IS  NULL
               THEN (CAST(DATEDIFF(DAY, T.ArrivalDate, T.ReturnDate) AS VARCHAR(10)) + ' days')
           ELSE 'Canceled'
           END AS Duration
FROM Trips AS T
        full JOIN AccountsTrips A on T.Id = A.TripId
        JOIN Accounts A2 on A2.Id = A.AccountId
       JOIN Cities C on C.Id = A2.CityId
        JOIN Rooms R2 on R2.Id = T.RoomId
         JOIN Hotels H on H.Id = R2.HotelId
        JOIN Cities C2 on C2.Id = H.CityId
ORDER BY [Full Name], T.Id

--11. Available Room
CREATE OR
ALTER FUNCTION udf_GetAvailableRoom(@HotelId int, @Date date, @People int)
    RETURNS nvarchar(max) AS
BEGIN
    DECLARE @roomId INT = (SELECT TOP (1) r.Id
                           FROM Trips AS t
                                    JOIN Rooms AS r ON t.RoomId = r.Id
                                    JOIN Hotels AS h ON r.HotelId = h.Id
                           WHERE h.Id = @HotelId
                             AND @Date NOT BETWEEN t.ArrivalDate AND t.ReturnDate
                             AND t.CancelDate IS NULL
                             AND r.Beds >= @People
                             AND YEAR(@Date) = YEAR(t.ArrivalDate)
                           ORDER BY r.Price DESC)

    IF (@roomId IS NULL)
        RETURN 'No rooms available'

    DECLARE @beds int=(SELECT beds FROM Rooms WHERE id = @roomId);
    DECLARE @baseRate decimal(18, 2)= (SELECT BaseRate
                                       FROM Hotels
                                       WHERE id = (SELECT HotelId FROM Rooms WHERE id = @roomId));
    DECLARE @roomPrice decimal(18, 2)=(SELECT Price FROM Rooms WHERE id = @roomId);
    DECLARE @roomType nvarchar(20)=(SELECT Type FROM Rooms WHERE id = @roomId)
    DECLARE @totalPrice decimal(18, 2)= (@baseRate + @roomPrice) * @People
    DECLARE @output nvarchar(max)=CONCAT('Room ', @RoomId, ': ', @RoomType, ' (', @beds, ' beds', ') - $', @TotalPrice)

    RETURN @output;


END

--12. Switch Room
CREATE PROC usp_SwitchRoom(@TripId int, @TargetRoomId int)
AS
BEGIN
    DECLARE @tripHotelId int =(SELECT h.id
                               FROM Trips AS t
                                        JOIN Rooms AS r ON t.RoomId = r.Id
                                        JOIN Hotels AS h ON r.HotelId = h.Id
        where t.id=@TripId);
    DECLARE @RoomHotelId int= (SELECT  HotelId FROM rooms WHERE id = @TargetRoomId);
    if(@tripHotelId<>@RoomHotelId)
    begin
        THROW 50001,'Target room is in another hotel!',1;
    END
    DECLARE @CountTripAccounts int=(SELECT count(AccountId) from AccountsTrips where TripId=@TripId);
    declare @RoomBeds int=(SELECT Beds from Rooms where id=@TargetRoomId);
    if(@CountTripAccounts>@RoomBeds)
    begin
        throw 50002,'Not enough beds in target room!',1;
    END
    update Trips
    set RoomId=@TargetRoomId
    where id=@TripId
END
