CREATE DATABASE SoftUni

CREATE TABLE Towns
(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Addresses
(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	AddressText NVARCHAR(100) NOT NULL,
	TownId INT FOREIGN KEY REFERENCES Towns(Id)
)

CREATE TABLE Departments
(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	[Name] NVARCHAR(100) NOT NULL
)

CREATE TABLE  Employees
(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	FirstName NVARCHAR(50) NOT NULL,
	MiddleName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	JobTitle NVARCHAR(50) NOT NULL,
	DepartmentId INT FOREIGN KEY REFERENCES Departments(Id),
	HireDate DATE,
	Salary MONEY,
	AddressId INT FOREIGN KEY REFERENCES Addresses(Id)
)

INSERT Towns([Name])
VALUES
('Sofia'),
('Plovdiv'),
('Varna'),
('Burgas')

INSERT Departments([Name])
VALUES
('Engineering'),
('Sales'),
('Marketing'),
('Software Development'),
('Quality Assurance')

INSERT Employees(FirstName, MiddleName, LastName, JobTitle, DepartmentId ,HireDate, Salary)
VALUES
('Ivan', 'Ivanov', 'Ivanov', '.NET Developer',4 ,'2013-02-01', 3500.00),
('Petar', 'Petrov', 'Petrov', 'Senior Engineer',1 , '2004-03-02', 4000.00),
('Maria', 'Petrova', 'Ivanova', 'Intern',5 , '2016-08-28', 525.25),
('Georgi', 'Teziev', 'Ivanov', 'CEO',2 , '2007-12-09', 3000.00),
('Petar', 'Pan', 'Pan', 'Intern',3 , '2016-08-28', 599.88)

SELECT * FROM Towns
ORDER BY [Name]
SELECT * FROM Departments
ORDER BY [Name]
SELECT * FROM Employees 
ORDER BY Salary DESC


SELECT [Name] FROM Towns 
ORDER BY [Name]
SELECT [Name] FROM Departments
ORDER BY [Name]
SELECT FirstName, LastName, JobTitle, Salary FROM Employees
ORDER BY Salary DESC

UPDATE Employees
  SET
      Salary *= 1.10;

SELECT [Salary]
FROM Employees

USE Hotel;

UPDATE Payments
  SET
      TaxRate = TaxRate - (TaxRate * 0.03);

SELECT TaxRate
FROM Payments

TRUNCATE TABLE Occupancies