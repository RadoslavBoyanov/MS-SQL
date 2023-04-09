----01. One-To-One Relationship
CREATE TABLE Persons
(
	PersonID INT NOT NULL,
	FirstName NVARCHAR(50) NOT NULL,
	Salary DECIMAL(10,2),
	PassportID INT UNIQUE
)

CREATE TABLE Passports
(	
	PassportID INT NOT NULL UNIQUE,
	PassportNumber NVARCHAR (20)
)

INSERT INTO Persons(PersonID, FirstName, Salary, PassportID)
VALUES
(1, 'Roberto', 43300.00, 102),
(2, 'Tom', 56100.00, 103),
(3, 'Yana', 60200.00, 101)

INSERT INTO Passports (PassportID, PassportNumber)
VALUES
(101, 'N34FG21B'),
(102, 'K65LO4R7'),
(103, 'ZE657QP2')

ALTER TABLE Persons
ADD PRIMARY KEY (PersonID)

ALTER TABLE Passports
ADD PRIMARY KEY(PassportID)

ALTER TABLE Persons
ADD FOREIGN KEY (PassportID) REFERENCES Passports(PassportID)

--02. One-To-Many Relationship
CREATE TABLE Models
(
	ModelID INT NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
	ManufacturerID INT NOT NULL
)

CREATE TABLE Manufacturers
(
	ManufacturerID INT NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
	EstablishedOn NVARCHAR (30) NOT NULL
)

INSERT INTO Models(ModelID, [Name], ManufacturerID)
VALUES
(101, 'X1', 1),
(102, 'i6', 1),
(103, 'Model S',2),
(104, 'Model X', 2),
(105, 'Model 3', 2),
(106, 'Nova', 3)

INSERT INTO Manufacturers (ManufacturerID, [Name], EstablishedOn)
VALUES
(1, 'BMV', '07/03/1916'),
(2, 'Tesla', '01/01/2003'),
(3, 'Lada', '01/05/1966')

ALTER TABLE Models
ADD PRIMARY KEY(ModelID)

ALTER TABLE Manufacturers
ADD PRIMARY KEY(ManufacturerID)

ALTER TABLE Models
ADD FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID)

--03. Many-To-Many Relationship
CREATE TABLE Students
(
	StudentID INT NOT NULL,
	[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Exams
(
	ExamID INT NOT NULL,
	[Name] NVARCHAR (100) NOT NULL
)

CREATE TABLE StudentsExams
(	
	StudentID INT NOT NULL,
	ExamID INT NOT NULL
)

INSERT INTO Students(StudentID, [Name])
VALUES
(1, 'Mila'),
(2, 'Toni'),
(3, 'Ron')

INSERT INTO Exams(ExamID, [Name])
VALUES
(101, 'SpringMVC'),
(102, 'Neo4j'),
(103, 'Oracle 11g')

INSERT INTO StudentsExams(StudentID, ExamID)
VALUES
(1, 101),
(1, 102),
(2, 101),
(3, 103),
(2, 102),
(2, 103)

ALTER TABLE Students
ADD PRIMARY KEY(StudentID)

ALTER TABLE Exams
ADD PRIMARY KEY(ExamID)

ALTER TABLE StudentsExams
ADD CONSTRAINT PK_StudentsExamsID
PRIMARY KEY(StudentID, ExamID)

ALTER TABLE StudentsExams
ADD FOREIGN KEY(StudentID) REFERENCES Students(StudentID)

ALTER TABLE StudentsExams
ADD FOREIGN KEY(ExamID) REFERENCES Exams(ExamID) 

--04. Self-Referencing
CREATE TABLE Teachers
(
	TeacherID INT NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
	ManagerID INT 
)

INSERT INTO Teachers (TeacherID, [Name], ManagerID)
VALUES 
(101, 'John', NULL),
(102, 'Maya', 106),
(103, 'Silvia', 106),
(104, 'Ted', 105),
(105, 'Mark', 101),
(106, 'Greta', 101)

ALTER TABLE Teachers
ADD PRIMARY KEY(TeacherID)

ALTER TABLE Teachers
ADD FOREIGN KEY(ManagerID) REFERENCES Teachers(TeacherID)

09. *Peaks in Rila
SELECT
	m.MountainRange,
	p.PeakName,
	p.Elevation
FROM Mountains AS m
JOIN Peaks AS p ON m.Id = p.MountainId
AND m.MountainRange = 'Rila'
ORDER BY p.Elevation DESC