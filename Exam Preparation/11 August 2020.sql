CREATE DATABASE Bakery

--01. DDL
CREATE TABLE Countries
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(50) NOT NULL UNIQUE
)

CREATE TABLE Customers
(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(25) NOT NULL,
	LastName NVARCHAR(25) NOT NULL,
	Gender CHAR(1) NOT NULL CHECK(Gender IN('M', 'F')),
	Age INT NOT NULL,
	PhoneNumber VARCHAR(10) CHECK(LEN(PhoneNumber) = 10),
	CountryId INT NOT NULL FOREIGN KEY REFERENCES Countries(Id)
)

CREATE TABLE Products
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(25) NOT NULL UNIQUE,
	[Description] NVARCHAR(250),
	Recipe NVARCHAR(MAX) NOT NULL,
	Price DECIMAL(18,2) NOT NULL CHECK(Price >= 0)
)

CREATE TABLE Feedbacks
(
	Id INT PRIMARY KEY IDENTITY,
	[Description] NVARCHAR(250),
	Rate DECIMAL(15,2) NOT NULL CHECK(Rate BETWEEN 0 AND 10),
	ProductId INT NOT NULL FOREIGN KEY REFERENCES Products(Id),
	CustomerId INT NOT NULL FOREIGN KEY REFERENCES Customers(Id)
)

CREATE TABLE Distributors
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(25) NOT NULL UNIQUE,
	AddressText NVARCHAR(30) NOT NULL,
	Summary NVARCHAR(200) NOT NULL,
	CountryId INT NOT NULL FOREIGN KEY REFERENCES Countries(Id)
)

CREATE TABLE Ingredients
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30) NOT NULL,
	[Description] NVARCHAR(250),
	OriginCountryId INT NOT NULL FOREIGN KEY REFERENCES Countries(Id),
	DistributorId INT NOT NULL FOREIGN KEY REFERENCES Distributors(Id)
)

CREATE TABLE ProductsIngredients
(
	ProductId INT FOREIGN KEY REFERENCES Products(Id),
	IngredientId INT FOREIGN KEY REFERENCES Ingredients(Id),
	PRIMARY KEY(ProductId, IngredientId)
)

--02. Insert
INSERT INTO Distributors([Name], CountryId, AddressText, Summary)
VALUES
('Deloitte & Touche', 2, '6 Arch St #9757',	'Customizable neutral traveling'),
('Congress Title', 13, '58 Hancock St',	'Customer loyalty'),
('Kitchen People', 1, '3 E 31st St #77', 'Triple-buffered stable delivery'),
('General Color Co Inc', 21, '6185 Bohn St #72', 'Focus group'),
('Beck Corporation', 23, '21 E 64th Ave', 'Quality-focused 4th generation hardware')

INSERT INTO Customers(FirstName, LastName, Age, Gender, PhoneNumber, CountryId)
VALUES
('Francoise', 'Rautenstrauch', 15, 'M',	'0195698399', 5),
('Kendra', 'Loud', 22, 'F',	'0063631526', 11),
('Lourdes', 'Bauswell',	50,	'M', '0139037043', 8),
('Hannah', 'Edmison', 18, 'F', '0043343686', 1),
('Tom',	'Loeza', 31, 'M', '0144876096', 23),
('Queenie',	'Kramarczyk', 30, 'F', '0064215793', 29),
('Hiu',	'Portaro', 25, 'M',	'0068277755',	16),
('Josefa', 'Opitz',	43,	'F', '0197887645', 17)

--03. Update
UPDATE Ingredients
SET DistributorId = 35
WHERE [Name] IN('Bay Leaf', 'Paprika', 'Poppy')

UPDATE Ingredients
SET OriginCountryId = 14
WHERE OriginCountryId = 8

--04. Delete
DELETE FROM Feedbacks
WHERE CustomerId = 14 
OR ProductId = 5

--05. Products By Price
SELECT
	[Name],
	Price,
	[Description]
FROM Products
ORDER BY Price DESC, [Name] ASC

--06. Negative Feedback
SELECT
	f.ProductId,
	f.Rate,
	f.[Description],
	f.CustomerId,
	c.Age,
	c.Gender
FROM Feedbacks AS f
JOIN Customers AS c ON f.CustomerId = c.Id
WHERE f.Rate < 5.0
ORDER BY f.ProductId DESC, f.Rate ASC

--07. Customers without Feedback
SELECT 
	CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
	c.PhoneNumber,
	c.Gender
FROM Customers AS C
WHERE NOT EXISTS
(SELECT CustomerId FROM Feedbacks WHERE c.Id = CustomerId)
ORDER BY c.Id ASC

--08. Customers by Criteria
SELECT 
	FirstName,
	Age,
	PhoneNumber
FROM Customers
WHERE Age >= 21
AND FirstName LIKE '%an%' 
OR PhoneNumber LIKE '%38'
AND CountryId != 31 
ORDER BY FirstName ASC, Age DESC

--09. Middle Range Distributors
SELECT
	d.[Name] AS DistributorName,
	i.[Name] AS IngredientName,
	p.[Name] AS ProductName,
	AVG(f.Rate) AS AverageRate
FROM Distributors AS d
JOIN Ingredients AS i ON d.Id = i.DistributorId
JOIN ProductsIngredients AS pr ON i.Id = pr.IngredientId
JOIN Products AS p ON pr.ProductId = p.Id
JOIN Feedbacks AS f ON p.Id = f.ProductId
GROUP BY d.[Name], i.[Name], p.[Name] 
HAVING AVG(f.Rate) BETWEEN 5 AND 8
ORDER BY d.[Name] ASC, i.[Name] ASC, p.[Name] ASC

--10. Country Representative
SELECT rankQuery.Name, rankQuery.DistributorName
FROM (
SELECT c.Name, d.Name as DistributorName,
       DENSE_RANK() OVER (PARTITION by c.Name ORDER BY COUNT(i.Id) desc) as rank
FROM Countries as c
      JOIN  Distributors D on c.Id = D.CountryId
     LEFT JOIN Ingredients I on D.Id = I.DistributorId
GROUP BY  c.Name, d.Name
) AS rankQuery
WHERE rankQuery.rank=1
 ORDER BY rankQuery.Name, rankQuery.DistributorName

--11. Customers With Countries
CREATE VIEW v_UserWithCountries AS
(
SELECT CONCAT(C.FirstName, ' ', c.LastName) AS CustomerName,
       C.Age AS Age,
       C.Gender AS Gender,
       C2.Name AS CountryName
FROM Customers AS C
       JOIN Countries C2 on C2.Id = C.CountryId)

SELECT TOP 5 *
  FROM v_UserWithCountries
 ORDER BY Age


--12. Delete Products
create table DeletedProducts
(
     Id          int identity
        primary key,
    Name        nvarchar(25)   not null
        unique,
    Description nvarchar(250),
    Recipe      nvarchar(max)  not null,
    Price       decimal(15, 2) not null
        check ([Price] >= 0)
)

create trigger dbo.ProductsToDelete
    on Products
    instead of DELETE
    as
begin
    declare
        @deletedProductId int = (SELECT p.Id
                                 from Products as p
                                          join deleted as d on d.Id = p.Id)
    delete
    from ProductsIngredients
    where ProductId = @deletedProductId
    delete
    from Feedbacks
    where ProductId = @deletedProductId
    delete
    from Products
    where Id = @deletedProductId
end