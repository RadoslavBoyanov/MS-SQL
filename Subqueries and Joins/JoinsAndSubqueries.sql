--01. Employee Address
SELECT TOP(5)
	e.EmployeeID,
	e.JobTitle,
	a.AddressID,
	a.AddressText
FROM Employees AS e
JOIN Addresses AS a ON e.AddressID = a.AddressID
ORDER BY a.AddressID ASC

--02. Addresses with Towns
SELECT TOP(50)
	e.FirstName,
	e.LastName,
	t.[Name],
	a.AddressText
FROM Employees AS e
JOIN Addresses AS a ON e.AddressID = a.AddressID
JOIN Towns AS t ON a.TownID = t.TownID
ORDER BY e.FirstName ASC, e.LastName ASC

--03. Sales Employees
SELECT 
	e.EmployeeID,
	e.FirstName,
	e.LastName,
	d.[Name]
FROM Employees AS e
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
WHERE d.[Name] = 'Sales'
ORDER BY e.EmployeeID ASC

--04. Employee Departments
SELECT TOP(5)
	e.EmployeeID,
	e.FirstName,
	e.Salary,
	d.[Name]
FROM Employees AS e
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
WHERE e.Salary > 15000
ORDER BY d.DepartmentID ASC

--05. Employees Without Projects
SELECT TOP(3)
	e.EmployeeID,
	e.FirstName
FROM Employees AS e
FULL OUTER JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
WHERE ep.EmployeeID IS NULL
ORDER BY e.EmployeeID ASC

--06. Employees Hired After
SELECT
	e.FirstName,
	e.LastName,
	e.HireDate,
	d.[Name] AS [DeptName]
FROM Employees AS e
JOIN Departments AS d ON  e.DepartmentID = d.DepartmentID
WHERE e.HireDate > '1999-01-01'
AND d.[Name] IN ('Sales', 'Finance')
ORDER BY e.HireDate ASC

--07. Employees With Project
SELECT TOP(5)
	e.EmployeeID,
	e.FirstName,
	p.[Name]
FROM Employees AS e
JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
JOIN Projects AS p ON ep.ProjectID = p.ProjectID
WHERE p.StartDate > '2002-08-13'
AND p.EndDate IS NULL
ORDER BY e.EmployeeID ASC

--08. Employee 24
SELECT
	e.EmployeeID,
	e.FirstName,
CASE 
   WHEN P.StartDate > '01/01/2005' THEN NULL
   ELSE P.NAME
END 
FROM Employees AS e
JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
JOIN Projects AS p ON ep.ProjectID = p.ProjectID
WHERE e.EmployeeID = '24'

--09. Employee Manager
SELECT 
	em.EmployeeID,
	em.FirstName,
	em.ManagerID,
	e.FirstName AS [ManagerName]
FROM Employees AS e
JOIN Employees AS em ON e.EmployeeID = em.ManagerID
WHERE em.ManagerID IN(3, 7)
ORDER BY em.EmployeeID ASC

--10. Employees Summary
SELECT TOP(50)
	e.EmployeeID,
	CONCAT(e.FirstName, ' ', e.LastName) AS [EmployeeName],
	CONCAT(em.FirstName, ' ', em.LastName) AS [ManagerName],
	d.[Name] AS [DepartmentName]
FROM Employees AS e
LEFT JOIN Employees AS em ON em.EmployeeID = e.ManagerID
LEFT JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
ORDER BY e.EmployeeID ASC

--11. Min Average Salary
SELECT   MIN(a.AverageSalary) AS MinAverageSalary
  FROM 
  (
     SELECT e.DepartmentID, 
            AVG(e.Salary) AS AverageSalary
       FROM Employees AS e
   GROUP BY e.DepartmentID
  ) AS a

--12. Highest Peaks in Bulgaria
SELECT
	c.CountryCode,
	m.MountainRange,
	p.PeakName,
	p.Elevation
FROM Peaks AS p
JOIN Mountains AS m ON p.MountainId = m.Id
JOIN MountainsCountries AS mc ON m.Id = mc.MountainId
JOIN Countries AS c ON mc.CountryCode = c.CountryCode
WHERE p.Elevation > 2835
AND c.CountryCode = 'BG'
ORDER BY p.Elevation DESC

--13. Count Mountain Ranges
SELECT 
	c.CountryCode,
	COUNT(m.MountainRange) AS MountainRanges
FROM Mountains AS m
JOIN MountainsCountries AS mc ON m.Id = mc.MountainId
JOIN Countries AS c ON mc.CountryCode = c.CountryCode
WHERE c.CountryCode IN('BG', 'RU', 'US')
GROUP BY c.CountryCode 

--14. Countries With or Without Rivers
SELECT TOP(5)
	c.CountryName,
	r.RiverName
FROM Countries AS c
LEFT JOIN CountriesRivers AS cs ON c.CountryCode = cs.CountryCode
LEFT JOIN Rivers AS r ON cs.RiverId = r.Id
WHERE c.ContinentCode = 'AF'
ORDER BY c.CountryName ASC

--15. Continents and Currencies
SELECT rankedCurrencies.ContinentCode, rankedCurrencies.CurrencyCode, rankedCurrencies.Count
FROM (
SELECT c.ContinentCode, c.CurrencyCode, 
	COUNT(c.CurrencyCode) AS [Count], 
	DENSE_RANK() OVER (PARTITION BY c.ContinentCode ORDER BY COUNT(c.CurrencyCode) DESC) AS [rank] 
FROM Countries AS c
GROUP BY c.ContinentCode, c.CurrencyCode) AS rankedCurrencies
WHERE rankedCurrencies.rank = 1 and rankedCurrencies.Count > 1

--16. Countries Without any Mountains
SELECT
	COUNT(c.CountryCode) AS [Count]
FROM Countries AS c
LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
WHERE mc.MountainId IS NULL

--17. Highest Peak and Longest River by Country
SELECT TOP(5) 
	c.CountryName, 
	MAX(p.Elevation) AS [HighestPeakElevation], 
	MAX(r.Length) AS [LongestRiverLength]
FROM Countries AS c
LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
LEFT JOIN Peaks AS p ON p.MountainId = mc.MountainId
LEFT JOIN CountriesRivers AS cr ON c.CountryCode = cr.CountryCode
LEFT JOIN Rivers AS r ON cr.RiverId = r.Id
GROUP BY c.CountryName
ORDER BY [HighestPeakElevation] DESC, [LongestRiverLength] DESC, c.CountryName

--18. Highest Peak Name and Elevation by Country
SELECT TOP (5) WITH TIES c.CountryName, ISNULL(p.PeakName, '(no highest peak)') AS 'HighestPeakName', ISNULL(MAX(p.Elevation), 0) AS 'HighestPeakElevation', ISNULL(m.MountainRange, '(no mountain)')
FROM Countries AS c
LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
LEFT JOIN Peaks AS p ON m.Id = p.MountainId
GROUP BY c.CountryName, p.PeakName, m.MountainRange
ORDER BY c.CountryName, p.PeakName



