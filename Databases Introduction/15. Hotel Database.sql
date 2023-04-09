CREATE DATABASE Hotel

CREATE TABLE Employees
(
	Id INT NOT NULL IDENTITY PRIMARY KEY,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Title NVARCHAR(50),
	Notes NVARCHAR(MAX)
)

CREATE TABLE Customers
(
	AccountNumber INT NOT NULL IDENTITY PRIMARY KEY,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	PhoneNumber INT NOT NULL,
	EmergencyName NVARCHAR(80),
	EmergencyNumber INT,
	Notes NVARCHAR(MAX)
)

CREATE TABLE RoomStatus
(
	RoomStatus NVARCHAR(10) NOT NULL DEFAULT 'Ready' PRIMARY KEY,
	Notes NVARCHAR(MAX)
)

CREATE TABLE RoomTypes
(
	RoomType NVARCHAR(30) NOT NULL PRIMARY KEY,
	Notes NVARCHAR(MAX)
)

CREATE TABLE BedTypes
(
	BedType NVARCHAR(30) NOT NULL PRIMARY KEY,
	Notes NVARCHAR(MAX)
)

CREATE TABLE Rooms
(
	RoomNumber INT NOT NULL PRIMARY KEY,
	RoomType NVARCHAR(100) NOT NULL,
	BedType NVARCHAR(100) NOT NULL,
	Rate MONEY NOT NULL DEFAULT 30.50,
	CONSTRAINT chk_Price CHECK (Rate >= 0),
	RoomStatus NVARCHAR(10) NOT NULL,
	Notes NVARCHAR(MAX)
)

CREATE TABLE Payments
(
	Id INT NOT NULL IDENTITY PRIMARY KEY, 
	EmployeeId INT NOT NULL,
	PaymentDate DATE NOT NULL,
	AccountNumber INT NOT NULL,
	FirstDateOccupied DATE NOT NULL,
	LastDateOccupied DATE NOT NULL,
	TotalDays INT NOT NULL DEFAULT 1,
	AmountCharged DECIMAL NOT NULL,
	TaxRate DECIMAL NOT NULL,
	TaxAmount DECIMAL NOT NULL,
	PaymentTotal DECIMAL NOT NULL,
	Notes NVARCHAR(MAX)
)

CREATE TABLE Occupancies
(	
	Id INT NOT NULL IDENTITY PRIMARY KEY,
	EmployeeId INT NOT NULL,
	DateOccupied DATE NOT NULL,
	AccountNumber INT NOT NULL,
	RoomNumber INT NOT NULL,
	RateApplied DECIMAL NOT NULL,
	PhoneCharge DECIMAL NOT NULL,
	Notes NVARCHAR(MAX)
)

INSERT Employees
(FirstName, LastName, Title, Notes)
VALUES
('Dimitrichko', 'Ivanov', 'Mr', 'Dev'),
('Ilian', 'Petraciev', 'Mr', 'Cleaner'),
('Simo', 'Petkov', 'Mr', 'IT')

INSERT Customers
(FirstName, LastName, PhoneNumber)
VALUES
('Stamo', 'Petkov', '0888126701'),
('Kiro', 'Kirov', '0886124292'),
('Emil', 'Chukoev', '0887122173')

INSERT RoomStatus
(RoomStatus)
VALUES
('Ready'),
('Dirty'),
('NotReady')

INSERT RoomTypes
(RoomType)
VALUES
('Small room'),
('Bungalo'),
('BigRoom')

INSERT BedTypes
(BedType)
VALUES
('Small bed'),
('Normal Bed'),
('Huge Bed')

INSERT Rooms
(RoomNumber, RoomType, BedType, Rate, RoomStatus)
VALUES
(111, 'Twin Beds Studio', 'Twin Bed', 2.80, 'Ready'),
(222, 'Twin Beds Studio', 'Twin Bed', 3, 'Ready'),
(333, 'Twin Beds Studio', 'Twin Bed', 5, 'Ready')

INSERT Payments
( EmployeeId, PaymentDate, AccountNumber, FirstDateOccupied, LastDateOccupied, TotalDays, AmountCharged, TaxRate, TaxAmount, PaymentTotal)
VALUES
(1, GETDATE(), 1, '2017-01-01', '2019-05-12', 1, 200.25, 20, 10, 210.25),
(2, GETDATE(), 2, '2017-01-01', '2022-11-22', 1, 210.25, 2, 10, 220.25),
(3, GETDATE(), 3, '2017-01-01', '2023-06-16', 1, 220.25, 22, 10, 230.25)

INSERT Occupancies
(EmployeeId, DateOccupied, AccountNumber, RoomNumber, RateApplied, PhoneCharge)
VALUES
(1, '2012-01-01', 1, 111, 60.50, 11.20),
(2, '2022-12-31', 2, 333, 61.50, 12.20),
(3, '2023-01-10', 3, 222, 62.50, 13.20)