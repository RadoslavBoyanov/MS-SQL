--01. Employees with Salary Above 35000
CREATE PROC usp_GetEmployeesSalaryAbove35000 
AS
SELECT 
	FirstName AS [First Name],
	LastName AS [Last Name]
FROM Employees
WHERE Salary > 35000

--02. Employees with Salary Above Number
CREATE PROCEDURE usp_GetEmployeesSalaryAboveNumber @num DECIMAL(18,4)
AS
SELECT 
	FirstName,
	LastName
FROM Employees
WHERE Salary >= @num

--03. Town Names Starting With
CREATE PROC usp_GetTownsStartingWith @string NVARCHAR(MAX)
AS
SELECT
	[Name] AS Town
FROM Towns
WHERE [Name] LIKE @string + '%'

--04. Employees from Town
CREATE PROC usp_GetEmployeesFromTown @town NVARCHAR(MAX)
AS
SELECT
	FirstName,
	LastName
FROM Employees AS e
JOIN Addresses AS a ON e.AddressID = a.AddressID
JOIN Towns AS t ON a.TownID = t.TownID
WHERE t.[Name] = @town

--05. Salary Level Function
CREATE FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4)) 
RETURNS VARCHAR(20) AS
BEGIN
DECLARE @salaryLevel VARCHAR(20)
	IF(@salary < 30000)
		SET @salaryLevel = 'Low' 
	ELSE IF(@salary BETWEEN 30000 AND 50000)
		SET @salaryLevel = 'Average'
	ELSE
		SET @salaryLevel = 'High'
RETURN @salaryLevel
END

--06. Employees by Salary Level
CREATE PROC usp_EmployeesBySalaryLevel(@SalaryLevel VARCHAR(10))
AS SELECT FirstName,LastName 
FROM Employees 
WHERE dbo.ufn_GetSalaryLevel(Salary) = @SalaryLevel