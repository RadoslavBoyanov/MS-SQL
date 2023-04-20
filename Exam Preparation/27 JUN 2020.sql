--CREATE DATABASE WMS

----1. DDL 
CREATE TABLE Clients
(
	ClientId INT IDENTITY PRIMARY KEY,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Phone VARCHAR(12) CHECK(LEN(Phone) = 12) NOT NULL
)

CREATE TABLE Mechanics
(
	MechanicId INT IDENTITY PRIMARY KEY,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	[Address] NVARCHAR(255) NOT NULL
)

CREATE TABLE Models
(
	ModelId INT IDENTITY PRIMARY KEY,
	[Name] NVARCHAR(50) UNIQUE
)

CREATE TABLE Jobs
(
	JobId INT IDENTITY PRIMARY KEY,
	ModelId INT NOT NULL FOREIGN KEY REFERENCES Models(ModelId),
	[Status] NVARCHAR(11) NOT NULL CHECK([Status] = 'Pending' OR [Status] = 'In Progress' OR [Status] = 'Finished') DEFAULT('Pending'),
	ClientId INT NOT NULL FOREIGN KEY REFERENCES Clients(ClientId),
	MechanicId INT FOREIGN KEY REFERENCES Mechanics(MechanicId),
	IssueDate DATE NOT NULL,
	FinishDate DATE
)

CREATE TABLE Orders
(
	OrderId INT IDENTITY PRIMARY KEY,
	JobId INT NOT NULL FOREIGN KEY REFERENCES Jobs(JobId),
	IssueDate DATE,
	Delivered BIT NOT NULL DEFAULT('false')
)

CREATE TABLE Vendors
(
	VendorId INT IDENTITY PRIMARY KEY,
	[Name] NVARCHAR(50) NOT NULL UNIQUE
)

CREATE TABLE Parts
(
	PartId INT IDENTITY PRIMARY KEY,
	SerialNumber NVARCHAR(50) NOT NULL UNIQUE,
	[Description] NVARCHAR(255),
	Price DECIMAL(4,2) NOT NULL CHECK(Price > 0 and Price <= 9999.99),
	VendorId INT NOT NULL FOREIGN KEY REFERENCES Vendors(VendorId),
	StockQty INT NOT NULL CHECK(StockQty >= 0) DEFAULT(0),
)

CREATE TABLE OrderParts
(
	OrderId INT FOREIGN KEY REFERENCES Orders(OrderId),
	PartId INT FOREIGN KEY REFERENCES Parts(PartId),
	Quantity INT NOT NULL CHECK(Quantity >= 1) DEFAULT(1),
	PRIMARY KEY(OrderId, PartId)
)

CREATE TABLE PartsNeeded
(
	JobId INT FOREIGN KEY REFERENCES Jobs(JobId),
	PartId INT FOREIGN KEY REFERENCES Parts(PartId),
	Quantity INT NOT NULL CHECK(Quantity >= 1) DEFAULT(1),
	PRIMARY KEY(JobId, PartId)
)


--02. Insert
INSERT INTO Clients (FirstName, LastName, Phone)
VALUES
('Teri', 'Ennaco', '570-889-5187'),
('Merlyn', 'Lawler', '201-588-7810'),
('Georgene', 'Montezuma', '925-615-5185'),
('Jettie', 'Mconnell', '908-802-3564'),
('Lemuel', 'Latzke', '631-748-6479'),
('Melodie',	'Knipp', '805-690-1682'),
('Candida',	'Corbley', '908-275-8357')

INSERT INTO Parts(SerialNumber, Description, Price, VendorId)
VALUES
('WP8182119', 'Door Boot Seal',	117.86,	2),
('W10780048', 'Suspension Rod',	42.81, 1),
('W10841140', 'Silicone Adhesive', 6.77, 4),
('WPY055980', 'High Temperature Adhesive', 13.94, 3)

--03. Update
UPDATE Jobs
SET MechanicId = 3, [Status] = 'In Progress'
WHERE [Status] = 'Pending'

--04. Delete
DELETE FROM OrderParts
WHERE OrderId = 19

DELETE FROM Orders
WHERE OrderId = 19

--05. Mechanic Assignments
SELECT
	CONCAT(m.FirstName, ' ', m.LastName) AS Mechanic,
	j.Status,
	j.IssueDate
FROM Mechanics AS m
JOIN Jobs AS j ON j.MechanicId = m.MechanicId
ORDER BY m.MechanicId, j.IssueDate, j.JobId

--06. Current Clients
SELECT 
	CONCAT(c.FirstName, ' ', c.LastName) AS Client,
	CONVERT(int,DATEDIFF(HH, j.IssueDate, '2017-04-24') / 24) AS [Days going],
	j.Status
FROM Clients AS c
LEFT JOIN Jobs AS j ON c.ClientId = j.ClientId
WHERE j.Status = 'In Progress' OR J.Status = 'Pending'
ORDER BY [Days going] DESC, c.ClientId ASC

--07. Mechanic Performance
SELECT
	CONCAT(M.FirstName, ' ', m.LastName) AS Mechanic,
	AVG(DATEDIFF(DAY, j.IssueDate, j.FinishDate)) AS [Average Days]
FROM Mechanics AS m
LEFT JOIN Jobs AS j ON m.MechanicId = j.MechanicId
GROUP BY m.FirstName, m.LastName, m.MechanicId
ORDER BY m.MechanicId ASC

--08. Available Mechanics
SELECT
	CONCAT(m.FirstName, ' ', m.LastName) AS Available
FROM Mechanics AS m
LEFT JOIN Jobs AS j ON m.MechanicId = j.MechanicId
WHERE j.[Status] LIKE 'Finished' OR j.[Status] IS NULL
GROUP BY m.MechanicId, m.FirstName, m.LastName
ORDER BY m.MechanicId

--09. Past Expenses
SELECT 
	j.JobId,
	ISNULL(SUM(op.Quantity * p.Price), 0) AS Total
FROM Jobs AS j
LEFT JOIN Orders AS o ON o.JobId = j.JobId
LEFT JOIN OrderParts AS op ON op.OrderId = o.OrderId
LEFT JOIN Parts AS p ON op.PartId = p.PartId
WHERE j.[Status] = 'Finished'
GROUP BY j.JobId
ORDER BY Total DESC, j.JobId ASC

--10. Missing Parts
WITH CTE_ActiveJobsPartsQty (PartId, Quantity)
AS
(
    SELECT pn.PartId, SUM(pn.Quantity)
        FROM Jobs AS j
        JOIN PartsNeeded AS pn ON j.JobId = pn.JobId
        --JOIN Parts AS p ON pn.PartId = p.PartId
        WHERE j.[Status] NOT LIKE 'Finished'
        GROUP BY pn.PartId
),
 
CTE_PendingOrdersQty (PartId, Quantity)
AS
(
    SELECT p.PartId, SUM(op.Quantity)
        FROM Parts AS p
        JOIN OrderParts AS op ON p.PartId = op.PartId
        JOIN Orders AS o ON op.OrderId = o.OrderId
        WHERE o.Delivered = 0
        GROUP BY p.PartId
)
 
SELECT p.PartId, p.[Description], ajp.Quantity AS [Required], p.StockQty AS [In Stock], 
    ISNULL(poq.Quantity, 0) AS Ordered
        FROM CTE_ActiveJobsPartsQty AS ajp
        JOIN Parts AS p ON ajp.PartId = p.PartId
        LEFT JOIN CTE_PendingOrdersQty AS poq ON p.PartId = poq.PartId
        WHERE ajp.Quantity > p.StockQty + ISNULL(poq.Quantity, 0) 

-- Task 11 Place Order
CREATE PROCEDURE usp_PlaceOrder(@JobId int, @SerialNumber varchar(50), @Quantity int)
AS
    DECLARE @JobStatus VARCHAR(MAX) = (SELECT [Status]
                                        FROM Jobs
                                        WHERE JobId = @JobId)
    DECLARE @JobExists BIT = (SELECT COUNT(JobId)
                                FROM Jobs
                                WHERE JobId = @JobId)
 
    DECLARE @PartExists BIT = (SELECT COUNT(SerialNumber)
                                FROM Parts
                                WHERE SerialNumber = @SerialNumber)
 
    IF (@Quantity <= 0)
        THROW 50012, 'Part quantity must be more than zero!', 1;
 
    IF (@JobStatus = 'Finished')
        THROW 50011, 'This job is not active!', 1;
 
    IF (@JobExists = 0)
        THROW 50013, 'Job not found!', 1;
 
    IF (@PartExists = 0)
        THROW 50014, 'Part not found!', 1;
 
    DECLARE @OrderForJobExists INT = (SELECT COUNT(o.OrderId)
                                        FROM Orders AS o
                                        WHERE o.JobId = @JobId AND o.IssueDate IS NULL)
    IF (@OrderForJobExists = 0)
        INSERT INTO Orders
            VALUES
                (@JobId, NULL, 0);
 
    DECLARE @OrderId INT = (SELECT o.OrderId
                            FROM Orders AS o
                            WHERE o.JobId = @JobId AND o.IssueDate IS NULL);
 
    IF (@OrderId > 0 AND @PartExists = 0 AND @Quantity > 0)
        
        DECLARE @PartId INT = (SELECT PartId
                                FROM Parts
                                WHERE SerialNumber = @SerialNumber);
        DECLARE @PartExistsInOrder INT = (SELECT COUNT(*)
                                            FROM OrderParts
                                            WHERE OrderId = @OrderId AND PartId = @PartId);
        IF (@PartExistsInOrder > 0)
            UPDATE OrderParts
            SET Quantity += @Quantity
            WHERE OrderId = @OrderId AND PartId = @PartId
        ELSE
        INSERT INTO OrderParts
            VALUES
                (@OrderId, @PartId, @Quantity);
GO

 Task 12 Cost of Order
CREATE FUNCTION udf_GetCost(@JobId INT) 
RETURNS DECIMAL(16, 2) AS
BEGIN
    DECLARE @Total DECIMAL(16, 2)
    SELECT @Total = SUM(PartsPrice) FROM
    (
        SELECT ISNULL(SUM(p.Price * op.Quantity), 0) AS PartsPrice FROM Orders AS o
        JOIN OrderParts AS op
        ON o.OrderId = op.OrderId
        JOIN Parts AS p
        ON op.PartId = p.PartId
        WHERE o.JobId = @JobId
    ) AS t
    RETURN @Total
END
