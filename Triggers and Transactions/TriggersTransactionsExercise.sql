--01. Create Table Logs
CREATE TABLE Logs
(
	LogId INT NOT NULL IDENTITY PRIMARY KEY,
	AccountId INT NOT NULL FOREIGN KEY REFERENCES Accounts(Id),
	OldSum MONEY,
	NewSum MONEY
)

CREATE TRIGGER tg_SumAccountChange
ON Accounts FOR UPDATE  AS
BEGIN
INSERT INTO Logs(AccountId, OldSum, NewSum)
SELECT
	i.Id,
	d.Balance,
	i.Balance
FROM inserted AS i
JOIN deleted AS d ON i.Id = d.Id
END

--02. Create Table Emails
CREATE TABLE NotificationEmails
(
	Id INT NOT NULL IDENTITY PRIMARY KEY,
	Recipient INT NOT NULL FOREIGN KEY REFERENCES Accounts(Id),
	[Subject] VARCHAR(50),
	Body TEXT
)

CREATE TRIGGER tr_EmailsNotificationsAfterInsert
ON Logs AFTER INSERT 
AS
BEGIN
INSERT INTO NotificationEmails(Recipient,Subject,Body)
SELECT i.AccountID, 
CONCAT('Balance change for account: ',i.AccountId),
CONCAT('On ',GETDATE(),' your balance was changed from ',i.NewSum,' to ',i.OldSum)
  FROM inserted AS i
END

--03. Deposit Money
CREATE PROCEDURE usp_DepositMoney(@AccountId INT, @MoneyAmount MONEY)
AS
BEGIN TRANSACTION

UPDATE Accounts
SET Balance += @MoneyAmount
WHERE Id = @AccountId

COMMIT

--04. Withdraw Money Procedure
 CREATE PROC usp_WithdrawMoney (@AccountId INT, @MoneyAmount MONEY)
     AS
  BEGIN TRANSACTION
 UPDATE Accounts
    SET Balance -= @MoneyAmount
  WHERE Id = @AccountId
DECLARE @LeftBalance MONEY = (SELECT Balance FROM Accounts WHERE Id = @AccountId)
	 IF(@LeftBalance < 0)
	  BEGIN
	   ROLLBACK
	   RAISERROR('',16,2)
	   RETURN
	  END
COMMIT

--05. Money Transfer
CREATE PROC usp_TransferMoney(@SenderId INT, @ReceiverId INT, @Amount MONEY)
AS
BEGIN TRANSACTION
EXEC usp_DepositMoney @ReceiverId, @Amount
EXEC usp_WithdrawMoney @SenderId, @Amount
COMMIT

--06. *Massive Shopping


--07. Employees with Three Projects
CREATE PROC usp_AssignProject(@EmloyeeId INT , @ProjectID INT)
AS
BEGIN TRANSACTION
DECLARE @ProjectsCount INT;
SET @ProjectsCount = (SELECT COUNT(ProjectID) FROM EmployeesProjects WHERE EmployeeID = @emloyeeId)
IF(@ProjectsCount >= 3)
BEGIN 
 ROLLBACK
 RAISERROR('The employee has too many projects!', 16, 1)
 RETURN
END
INSERT INTO EmployeesProjects
     VALUES
(@EmloyeeId, @ProjectID)
 
 COMMIT

--09. Delete Employees
CREATE TRIGGER tr_DeleteEmployees
  ON Employees
  AFTER DELETE
AS
  BEGIN
    INSERT INTO Deleted_Employees
      SELECT FirstName,LastName,MiddleName,JobTitle,DepartmentID,Salary
      FROM deleted
  END
