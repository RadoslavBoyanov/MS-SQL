CREATE DATABASE Zoo
--01. DDL
CREATE TABLE Owners
(
	Id INT IDENTITY PRIMARY KEY,
	[Name] VARCHAR(50) NOT NULL,
	PhoneNumber VARCHAR(15) NOT NULL,
	[Address] VARCHAR(50) 
)

CREATE TABLE AnimalTypes
(	
	Id INT IDENTITY PRIMARY KEY,
	AnimalType VARCHAR(30) NOT NULL
)

CREATE TABLE Cages
(
	Id INT IDENTITY PRIMARY KEY,
	AnimalTypeId INT NOT NULL FOREIGN KEY REFERENCES AnimalTypes(Id)
)

CREATE TABLE Animals
(
	Id INT IDENTITY PRIMARY KEY,
	[Name] VARCHAR(30) NOT NULL,
	BirthDate DATE NOT NULL, 
	OwnerId INT FOREIGN KEY REFERENCES Owners(Id),
	AnimalTypeId INT NOT NULL FOREIGN KEY REFERENCES AnimalTypes(Id)
)

CREATE TABLE AnimalsCages
(
	CageId INT NOT NULL FOREIGN KEY REFERENCES Cages(Id),
	AnimalId INT NOT NULL FOREIGN KEY REFERENCES Animals(Id),
	PRIMARY KEY(CageId, AnimalId)
)

CREATE TABLE VolunteersDepartments
(
	Id INT IDENTITY PRIMARY KEY,
	DepartmentName VARCHAR(30) NOT NULL
)

CREATE TABLE Volunteers
(
	Id INT IDENTITY PRIMARY KEY,
	[Name] VARCHAR(50) NOT NULL,
	PhoneNumber VARCHAR(15) NOT NULL,
	[Address] VARCHAR(50),
	AnimalId INT FOREIGN KEY REFERENCES Animals(Id),
	DepartmentId INT NOT NULL FOREIGN KEY REFERENCES VolunteersDepartments(Id)
)

--02. Insert
INSERT INTO Volunteers(Name, PhoneNumber, Address, AnimalId, DepartmentId)
VALUES
('Anita Kostova', '0896365412',	'Sofia, 5 Rosa str.',15,	1),
('Dimitur Stoev', '0877564223',	NULL, 42, 4),
('Kalina Evtimova',	'0896321112', 'Silistra, 21 Breza str.', 9,	7),
('Stoyan Tomov', '0898564100',	'Montana, 1 Bor str.',	18,	8),
('Boryana Mileva',	'0888112233', NULL,	31,	5)

INSERT INTO Animals(Name, BirthDate, OwnerId, AnimalTypeId)
VALUES
('Giraffe', '2018-09-21',	21,	1),
('Harpy Eagle',	'2015-04-17',	15,	3),
('Hamadryas Baboon', '2017-11-02', NULL, 1),
('Tuatara',	'2021-06-30',	2, 4)

--03. Update
UPDATE Animals
SET OwnerId = 4
WHERE OwnerId IS NULL

--04. Delete
DELETE FROM Volunteers WHERE DepartmentId = 2;
DELETE FROM VolunteersDepartments WHERE Id = 2;

--05. Volunteers
SELECT
	v.Name,
	v.PhoneNumber,
	v.Address,
	v.AnimalId,
	v.DepartmentId
FROM Volunteers AS v
ORDER BY v.Name ASC,
	v.AnimalId ASC,
	v.DepartmentId ASC

--06. Animals data
SELECT 
	a.Name,
	ant.AnimalType,
	FORMAT(BirthDate, 'dd.MM.yyyy') AS BirthDate
FROM Animals AS a
JOIN AnimalTypes AS ant ON a.AnimalTypeId = ant.Id
ORDER BY a.Name ASC

--07. Owners and Their Animals
SELECT TOP(5)
	o.[Name] AS [Owner],
	COUNT(a.[Name]) AS CountOfAnimals
FROM Owners as o
JOIN Animals as a ON o.Id = a.OwnerId
GROUP BY o.[Name]
ORDER BY CountOfAnimals DESC, o.[Name] ASC

--08. Owners, Animals and Cages
SELECT
	CONCAT(o.[Name], '-', a.[Name]) AS OwnersAnimals,
	o.PhoneNumber,
	c.Id
FROM Owners AS o
JOIN Animals as a ON o.Id = a.OwnerId
JOIN AnimalTypes AS ats ON a.AnimalTypeId = ats.Id
JOIN AnimalsCages AS ac ON a.Id = ac.AnimalId
JOIN Cages AS c ON ac.CageId = c.Id
WHERE ats.AnimalType = 'Mammals'
ORDER BY o.[Name], a.[Name] DESC

--09. Volunteers in Sofia
SELECT 
	v.[Name],
	v.PhoneNumber,
	SUBSTRING(Address, CHARINDEX(',', Address) + 2, LEN(v.Address)) AS Address
FROM
Volunteers AS v
JOIN VolunteersDepartments AS vd ON v.DepartmentId = vd.Id
WHERE vd.DepartmentName = 'Education program assistant' 
AND v.[Address] LIKE '%Sofia%' 
ORDER BY v.[Name]

--10. Animals for Adoption
SELECT 
	Name, 
	YEAR(a.BirthDate) AS BirthYear, 
	at.AnimalType 
FROM Animals AS a
JOIN AnimalTypes AS at ON a.AnimalTypeId = at.Id
WHERE OwnerId IS NULL
	AND AnimalTypeId != 3
	AND DATEDIFF(YEAR, BirthDate, '01/01/2022') < 5
ORDER BY Name

--11. All Volunteers in a Department
CREATE FUNCTION udf_GetVolunteersCountFromADepartment (@VolunteersDepartment VARCHAR(100))
RETURNS INT
AS
BEGIN
	DECLARE @countOfVolunteers INT = 
	(
		SELECT
			COUNT(vd.Id)
		FROM Volunteers AS v
		JOIN VolunteersDepartments AS vd ON v.DepartmentId = vd.Id
		WHERE vd.DepartmentName = @VolunteersDepartment
	)

	RETURN @countOfVolunteers;
END

SELECT dbo.udf_GetVolunteersCountFromADepartment ('Guest engagement')

--12. Animals with Owner or Not
CREATE PROC usp_AnimalsWithOwnersOrNot(@AnimalName VARCHAR(50))
AS
BEGIN
IF (SELECT OwnerId FROM Animals
			WHERE Name = @AnimalName) IS NULL
	BEGIN 
		SELECT Name, 'For adoption' AS OwnerName
			FROM Animals
			WHERE Name = @AnimalName
		END
ELSE
	BEGIN
		SELECT
			a.Name,
			o.Name
		FROM Animals AS a
		JOIN Owners as o ON a.OwnerId = o.Id
		WHERE a.Name = @AnimalName
	END
END

EXEC usp_AnimalsWithOwnersOrNot 'Hippo'