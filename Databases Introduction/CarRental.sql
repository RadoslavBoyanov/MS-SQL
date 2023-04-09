CREATE DATABASE CarRental

CREATE TABLE Categories
(
	Id INT IDENTITY PRIMARY KEY,
	CategoryName NVARCHAR(50) NOT NULL,
	DailyRate MONEY NOT NULL,
	WeeklyRate MONEY NOT NULL,
	MonthlyRate MONEY NOT NULL,
	WeekendRate MONEY NOT NULL
)

CREATE TABLE Cars
(
	Id INT NOT NULL IDENTITY PRIMARY KEY,
	PlateNumber NVARCHAR(15) NOT NULL,
	Make NVARCHAR(100) NOT NULL,
	Model NVARCHAR(100) NOT NULL,
	CarYear DATE NOT NULL,
	CategoryId INT NOT NULL,
	Doors INT NOT NULL,
	Picture VARBINARY(MAX),
	Condition NVARCHAR(MAX),
	Available BIT NOT NULL
)

CREATE TABLE Employees
(
	Id INT NOT NULL IDENTITY PRIMARY KEY,
	FirstName NVARCHAR (50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Title NVARCHAR(50),
	Notes NVARCHAR(MAX)
)

CREATE TABLE Customers
(
	Id INT NOT NULL IDENTITY PRIMARY KEY,
	DriverLicenseNumber NVARCHAR(30) NOT NULL UNIQUE,
	FullName NVARCHAR(150) NOT NULL,
	Address NVARCHAR(150) NOT NULL,
	City NVARCHAR(100) NOT NULL,
	ZIPCode INT NOT NULL,
	Notes NVARCHAR(MAX)
)

CREATE TABLE RentalOrders
(
Id INT NOT NULL IDENTITY PRIMARY KEY,
EmployeeId INT NOT NULL,
CustomerId INT NOT NULL,
CarId INT NOT NULL,
CarCondition NVARCHAR(MAX) DEFAULT 'NORMAL',
TankLevel NVARCHAR(100) NOT NULL DEFAULT 'Not Full',
KilometrageStart INT NOT NULL,
KilometrageEnd INT NOT NULL,
CONSTRAINT chk_Kilometers CHECK (KilometrageEnd >= KilometrageStart),
TotalKilometrage INT NOT NULL,
StartDate DATE NOT NULL,
EndDate DATE NOT NULL DEFAULT GETDATE(),
CONSTRAINT chk_Date CHECK (EndDate >= StartDate),
TotalDays INT NOT NULL,
RateApplied MONEY NOT NULL DEFAULT 0,
TaxRate MONEY NOT NULL DEFAULT 0,
OrderStatus NVARCHAR(200) NOT NULL DEFAULT 'Confirmed',
Notes NVARCHAR(MAX)
)

INSERT Categories(CategoryName, DailyRate, WeeklyRate, MonthlyRate, WeekendRate)
VALUES
('Cheap', 5.50, 55, 175.50, 15),
('Budget', 11, 77, 215.50, 25),
('Lux', 50, 300, 800, 100)

INSERT Cars
(PlateNumber, Make, Model, CarYear, CategoryId, Doors, Condition, Available)
VALUES
('CA1010BA', 'Opel', 'Vectra', '2000-11-24', 1, 4, 'Good', 1),
('BH4748AK', 'Volkswagen', 'Golf', '2000-11-24', 2, 4, 'Good', 1),
('M3236KA', 'Tesla', 'Model S', '2016-11-24', 3, 4, 'New', 1)

INSERT Employees
( FirstName, LastName, Title, Notes)
VALUES
( 'Radoslav', 'Boyanov', 'Mr', 'Cheap Labor'),
( 'Biser', 'Boyanov', 'Sir', 'Crazy'),
( 'Kiril', 'Evtimov', 'Ms', 'Cool name')

INSERT Customers
(DriverLicenseNumber, FullName, Address, City, ZIPCode)
VALUES
('ZZA46656', 'Petat Leshtakov', 'Trun', 'Trun', 1000),
('ZZA43236', 'Samuel Umtiti', 'Washington', 'Nice', 1001),
('ZZA45466', 'Djony Depp', 'Washington', 'Washington', 1002)

INSERT RentalOrders
(EmployeeId, CustomerId, CarId, CarCondition, TankLevel, KilometrageStart, KilometrageEnd, TotalKilometrage, StartDate, EndDate, TotalDays, RateApplied, TaxRate, OrderStatus, Notes)
VALUES
(1, 2, 3, DEFAULT, DEFAULT, 100, 200, 100, '2017-01-17', DEFAULT, 1, 10.0, 10.0, DEFAULT, 'None'),
(1, 2, 3, DEFAULT, DEFAULT, 100, 200, 100, '2017-01-17', DEFAULT, 1, 10.0, 10.0, DEFAULT, 'None'),
(1, 2, 3, DEFAULT, DEFAULT, 100, 200, 100, '2017-01-17', DEFAULT, 1, 10.0, 10.0, DEFAULT, 'None')