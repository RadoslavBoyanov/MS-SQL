--01. DDL
CREATE DATABASE NationalTouristSitesOfBulgaria

CREATE TABLE Categories
(
	Id INT IDENTITY PRIMARY KEY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Locations
(
	Id INT IDENTITY PRIMARY KEY,
	[Name] VARCHAR(50) NOT NULL,
	Municipality VARCHAR(50),
	Province VARCHAR(50)
)

CREATE TABLE Sites
(
	Id INT IDENTITY PRIMARY KEY,
	[Name] VARCHAR(100) NOT NULL,
	LocationId INT NOT NULL FOREIGN KEY REFERENCES Locations(Id),
	CategoryId INT NOT NULL FOREIGN KEY REFERENCES Categories(Id),
	Establishment VARCHAR(15)
)

CREATE TABLE Tourists
(
	Id INT IDENTITY PRIMARY KEY,
	[Name] VARCHAR(50) NOT NULL,
	Age INT NOT NULL CHECK(Age >= 0 AND Age <= 120),
	PhoneNumber VARCHAR(20) NOT NULL,
	Nationality VARCHAR(30) NOT NULL,
	Reward VARCHAR(20)
)

CREATE TABLE SitesTourists
(
	TouristId INT NOT NULL FOREIGN KEY REFERENCES Tourists(Id),
	SiteId INT NOT NULL FOREIGN KEY REFERENCES Sites(Id),
	PRIMARY KEY(TouristId, SiteId)
)

CREATE TABLE BonusPrizes
(
	Id INT IDENTITY PRIMARY KEY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE TouristsBonusPrizes
(
	TouristId INT NOT NULL FOREIGN KEY REFERENCES Tourists(Id),
	BonusPrizeId INT NOT NULL FOREIGN KEY REFERENCES BonusPrizes(Id),
	PRIMARY KEY(TouristId, BonusPrizeId)
)

--02. Insert
INSERT INTO Tourists([Name], Age, PhoneNumber, Nationality, Reward)
VALUES
('Borislava Kazakova', 52,	'+359896354244'	,'Bulgaria', NULL),
('Peter Bosh' ,	48,	'+447911844141',	'UK',	NULL),
('Martin Smith', 29, '+353863818592', 'Ireland', 'Bronze badge'),
('Svilen Dobrev', 49, '+359986584786',	'Bulgaria',	'Silver badge'),
('Kremena Popova',	38,	'+359893298604', 'Bulgaria',	NULL)

INSERT INTO Sites([Name], LocationId, CategoryId, Establishment)
VALUES
('Ustra fortress' ,90 , 7, 'X'),
('Karlanovo Pyramids',	65,	7,	NULL),
('The Tomb of Tsar Sevt', 63, 8, 'V BC'),
('Sinite Kamani Natural Park', 17, 1, NULL),
('St. Petka of Bulgaria – Rupite', 92, 6, '1994')

--03. Update
UPDATE Sites
SET Establishment = '(not defined)'
WHERE Establishment IS NULL

--04. Delete
DELETE FROM TouristsBonusPrizes WHERE BonusPrizeId = 5
DELETE FROM BonusPrizes WHERE Id = 5

--05. Tourists
SELECT
	t.[Name],
	t.Age,
	t.PhoneNumber,
	t.Nationality
FROM Tourists AS t
ORDER BY t.Nationality ASC, 
	t.Age DESC, 
	t.[Name] ASC
 
 --06. Sites with Their Location and Category
SELECT
	s.[Name],
	l.[Name],
	s.Establishment,
	c.[Name]
FROM Sites AS s
JOIN Locations AS l ON s.LocationId = l.Id
JOIN Categories AS c ON s.CategoryId = c.Id
ORDER BY c.[Name] DESC,
	l.[Name] ASC,
	s.[Name] ASC

--07. Count of Sites in Sofia Province
SELECT
	l.Province,
	l.Municipality,
	l.[Name],
	COUNT(s.[Name]) AS CountOfSites
FROM Locations AS l
JOIN Sites AS s ON l.Id = s.LocationId
WHERE Province = 'Sofia'
GROUP BY Province, l.Municipality, l.[Name]
ORDER BY COUNT(s.[Name]) DESC, l.[Name] ASC

--08. Tourist Sites established BC
SELECT
	s.[Name],
	l.[Name],
	l.Municipality,
	l.Province,
	s.Establishment
FROM Sites AS s
JOIN Locations AS l ON s.LocationId = l.Id
WHERE (l.[Name] NOT LIKE 'B%' 
AND l.[Name] NOT LIKE 'M%' 
AND l.[Name] NOT LIKE 'D%')
AND s.Establishment LIKE '%BC'
ORDER BY s.[Name] ASC

--09. Tourists with their Bonus Prizes
SELECT 
	t.Name, 
	t.Age, 
	t.PhoneNumber, 
	t.Nationality,
IIF(bp.Name is null, '(no bonus prize)', bp.Name)
AS BonusPrize
FROM Tourists AS t
left join TouristsBonusPrizes AS tbp ON tbp.TouristId = t.Id
left join BonusPrizes as bp ON bp.Id = tbp.BonusPrizeId
ORDER BY t.Name

--10. Tourists visiting History & Archaeology sites
SELECT
	distinct(substring(t.Name, charindex(' ', t.Name) + 1, len(t.Name) - charindex(' ', t.Name))) as LastName,
	t.Nationality,
	t.Age,
	t.PhoneNumber
FROM Tourists AS t
JOIN SitesTourists AS st ON t.Id = st.TouristId
JOIN Sites AS s ON st.SiteId = s.Id
JOIN Categories AS c ON s.CategoryId = c.Id
WHERE c.[Name] = 'History and archaeology'
ORDER BY LastName

--11. Tourists Count on a Tourist Site
CREATE FUNCTION udf_GetTouristsCountOnATouristSite (@Site VARCHAR(100)) 
RETURNS INT 
BEGIN
	DECLARE @siteId INT = (SELECT Id FROM Sites WHERE [Name] = @Site);
	DECLARE @count INT = (SELECT COUNT(*) FROM Tourists AS t
                          JOIN SitesTourists AS st ON t.Id = st.TouristId
						  JOIN Sites AS s ON st.SiteId = s.Id
						  WHERE s.Id = @siteId)
	RETURN @count;

END

--12. Annual Reward Lottery
CREATE PROC usp_AnnualRewardLottery(@TouristName VARCHAR(100)) 
as
    begin
        declare @TouristId int = (select Id from Tourists where Name = @TouristName);
        declare @count int = (select count(*) from SitesTourists where TouristId = @TouristId);
        declare @reward varchar(20) = null;

        if(@count >= 100) set @reward = 'Gold badge';
        else if(@count >= 50) set @reward = 'Silver badge';
        else if(@count >= 25) set @reward = 'Bronze badge';

        if(@reward is not null)
        begin
            update Tourists set Reward = @reward
            where Id = @TouristId
        end

        select Name, Reward from Tourists where Id = @TouristId
    end