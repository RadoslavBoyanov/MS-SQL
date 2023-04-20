CREATE DATABASE CigarShop

--01. DDL
CREATE TABLE Sizes
(
	Id INT IDENTITY PRIMARY KEY,
	[Length] INT NOT NULL CHECK([Length] BETWEEN 10 AND 25),
	RingRange DECIMAL(18,2) NOT NULL CHECK(RingRange BETWEEN 1.5 AND 7.5)
)

CREATE TABLE Tastes
(
	Id INT IDENTITY PRIMARY KEY,
	TasteType VARCHAR(20) NOT NULL,
	TasteStrength VARCHAR(15) NOT NULL,
	ImageURL NVARCHAR(100) NOT NULL
)

CREATE TABLE Brands
(
	Id INT IDENTITY PRIMARY KEY,
	BrandName VARCHAR(30) NOT NULL,
	BrandDescription VARCHAR(MAX)
)

CREATE TABLE Cigars
(
	Id INT IDENTITY PRIMARY KEY,
	CigarName VARCHAR(80) NOT NULL,
	BrandId INT NOT NULL FOREIGN KEY REFERENCES Brands(Id),
	TastId INT NOT NULL FOREIGN KEY REFERENCES Tastes(Id),
	SizeId INT NOT NULL FOREIGN KEY REFERENCES Sizes(Id),
	PriceForSingleCigar DECIMAL NOT NULL,
	ImageURL NVARCHAR(100) NOT NULL
)

CREATE TABLE Addresses
(
	Id  INT IDENTITY PRIMARY KEY,
	Town VARCHAR(30) NOT NULL,
	Country NVARCHAR(30) NOT NULL,
	Streat NVARCHAR(100) NOT NULL,
	ZIP VARCHAR(20) NOT NULL
)

CREATE TABLE Clients
(
	Id INT IDENTITY PRIMARY KEY,
	FirstName NVARCHAR(30) NOT NULL,
	LastName NVARCHAR(30) NOT NULL,
	Email NVARCHAR(50) NOT NULL,
	AddressId INT NOT NULL FOREIGN KEY REFERENCES Addresses(Id)
)

CREATE TABLE ClientsCigars
(
	ClientId INT NOT NULL FOREIGN KEY REFERENCES Clients(Id),
	CigarId INT NOT NULL FOREIGN KEY REFERENCES Cigars(Id)
	PRIMARY KEY(ClientId, CigarId)
)

--02. Insert
INSERT INTO Cigars(CigarName, BrandId, TastId, SizeId, PriceForSingleCigar, ImageURL)
VALUES
('COHIBA ROBUSTO',	9,	1, 5, 15.50, 'cohiba-robusto-stick_18.jpg'),
('COHIBA SIGLO I',	9,	1, 10, 410.00, 'cohiba-siglo-i-stick_12.jpg'),
('HOYO DE MONTERREY LE HOYO DU MAIRE', 14, 5, 11, 7.50,	'hoyo-du-maire-stick_17.jpg'),
('HOYO DE MONTERREY LE HOYO DE SAN JUAN', 14, 4, 15, 32.00,	'hoyo-de-san-juan-stick_20.jpg'),
('TRINIDAD COLONIALES',	2, 3, 8, 85.21,	'trinidad-coloniales-stick_30.jpg')

INSERT INTO Addresses(Town, Country, Streat, ZIP)
VALUES
('Sofia', 'Bulgaria', '18 Bul. Vasil levski', 1000),
('Athens', 'Greece', '4342 McDonald Avenue', 10435),
('Zagreb', 'Croatia', '4333 Lauren Drive', 10000)

--03. Update
UPDATE Cigars
SET PriceForSingleCigar = PriceForSingleCigar * 1.20
WHERE TastId IN (SELECT
					c.TastId
				 FROM Cigars AS c
				 JOIN Tastes AS t ON c.TastId = t.Id 
				 WHERE t.TasteType = 'Spicy')
UPDATE Brands
SET BrandDescription = 'New description'
WHERE BrandDescription IS NULL

--04. Delete
DELETE FROM Clients
WHERE AddressId IN (SELECT Id FROM Addresses WHERE Country LIKE 'C%') 

DELETE FROM Addresses
WHERE Country LIKE 'C%'

--05. Cigars by Price
SELECT
	CigarName,
	PriceForSingleCigar,
	ImageURL
FROM Cigars
ORDER BY PriceForSingleCigar ASC, CigarName DESC

--06. Cigars by Taste
SELECT
	c.Id,
	c.CigarName,
	c.PriceForSingleCigar,
	t.TasteType,
	t.TasteStrength
FROM Cigars AS c
JOIN Tastes  AS t ON c.TastId = t.Id
WHERE t.TasteType = 'Earthy' 
OR t.TasteType = 'Woody'
ORDER BY c.PriceForSingleCigar DESC

--07. Clients without Cigars
SELECT
	cl.Id,
	cl.FirstName + ' ' + cl.LastName AS ClientName,
	cl.Email
FROM Clients AS cl
WHERE cl.Id NOT IN	(SELECT
						c.Id
					FROM Clients AS c
					JOIN ClientsCigars AS cc ON c.Id = cc.ClientId)
ORDER BY ClientName ASC

--08. First 5 Cigars
SELECT TOP(5)
	c.CigarName,
	c.PriceForSingleCigar,
	c.ImageURL
FROM Cigars AS c
JOIN Sizes AS s ON c.SizeId = s.Id
WHERE s.[Length] >= 12
AND (c.CigarName LIKE '%ci%' OR c.PriceForSingleCigar > 50)
AND s.RingRange > 2.55
ORDER BY c.CigarName ASC, c.PriceForSingleCigar DESC

--09. Clients with ZIP Codes
SELECT
	cl.FirstName + ' ' + cl.LastName AS FullName,
	a.Country,
	a.ZIP,
	'$' + CAST(MAX(c.PriceForSingleCigar) AS varchar) AS  CigarPrice
FROM Cigars AS c
JOIN ClientsCigars AS cc ON c.Id = cc.CigarId
JOIN Clients AS cl ON cc.ClientId = cl.Id
JOIN Addresses AS a ON cl.AddressId = a.Id
WHERE a.ZIP NOT LIKE '%[^0-9]%'
GROUP BY cl.FirstName, cl.LastName, a.Country, a.ZIP
ORDER BY FullName ASC

--10. Cigars by Size
SELECT
	cl.LastName,
	AVG(s.[Length]) AS CiagrLength,
	CEILING(AVG(s.RingRange)) AS CiagrRingRange
FROM Clients AS cl
JOIN ClientsCigars AS cc ON cl.Id = cc.ClientId
JOIN Cigars AS c ON cc.CigarId = c.Id
JOIN Sizes AS s ON c.SizeId = s.Id
GROUP BY cl.LastName
ORDER BY CiagrLength DESC

--11. Client with Cigars
CREATE FUNCTION udf_ClientWithCigars(@name NVARCHAR(30))
RETURNS INT 
AS
BEGIN
	DECLARE @clientCigars INT = (SELECT
									COUNT(*)
								FROM Clients AS cl
								JOIN ClientsCigars AS cc ON cl.Id = cc.ClientId
								JOIN Cigars AS c ON cc.CigarId = c.Id
								WHERE cl.FirstName = @name)
	RETURN @clientCigars
END

--12. Search for Cigar with Specific Taste
CREATE PROC usp_SearchByTaste(@taste VARCHAR(20))
AS
SELECT
	c.CigarName,
	CONCAT('$', c.PriceForSingleCigar) AS Price,
	t.TasteType,
	b.BrandName,
	CONCAT(s.Length, ' ','cm') AS CigarLength,
	CONCAT(s.RingRange, ' ', 'cm') AS CigarRingRange
FROM Cigars AS c
JOIN Sizes AS s ON c.SizeId = s.Id
JOIN Tastes AS t ON c.TastId = t.Id
JOIN Brands AS b ON c.BrandId = b.Id
WHERE t.TasteType = @taste
ORDER BY CigarLength ASC, CigarRingRange DESC
