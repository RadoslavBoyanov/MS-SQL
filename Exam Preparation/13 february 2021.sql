CREATE DATABASE Bitbucket

--01. DDL
CREATE TABLE Users
(
	Id INT PRIMARY KEY IDENTITY,
	Username VARCHAR(30) NOT NULL,
	[Password] VARCHAR(30) NOT NULL,
	Email VARCHAR(50) NOT NULL
)

CREATE TABLE Repositories
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE RepositoriesContributors
(
	RepositoryId INT FOREIGN KEY REFERENCES Repositories(Id),
	ContributorId INT FOREIGN KEY REFERENCES Users(Id),
	PRIMARY KEY(RepositoryId, ContributorId)
)

CREATE TABLE Issues
(
	Id INT PRIMARY KEY IDENTITY,
	Title VARCHAR(255) NOT NULL,
	IssueStatus VARCHAR(6) NOT NULL,
	RepositoryId INT NOT NULL FOREIGN KEY REFERENCES Repositories(Id),
	AssigneeId INT NOT NULL FOREIGN KEY REFERENCES Users(Id)
)

CREATE TABLE Commits
(
	Id INT PRIMARY KEY IDENTITY,
	[Message] VARCHAR(255) NOT NULL,
	IssueId INT FOREIGN KEY REFERENCES Issues(Id),
	RepositoryId INT NOT NULL FOREIGN KEY REFERENCES Repositories(Id),
	ContributorId INT NOT NULL FOREIGN KEY REFERENCES Users(Id)
)

CREATE TABLE Files
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(100) NOT NULL,
	Size DECIMAL(18,2) NOT NULL,
	ParentId INT FOREIGN KEY REFERENCES Files(Id),
	CommitId INT NOT NULL FOREIGN KEY REFERENCES Commits(Id)
)

INSERT INTO Files(Name, Size, ParentId, CommitId)
VALUES
('Trade.idk', 2598.0, 1, 1),
('menu.net', 9238.31, 2, 2),
('Administrate.soshy', 1246.93,	3, 3),
('Controller.php', 7353.15,	4, 4),
('Find.java', 9957.86, 5, 5),
('Controller.json',	14034.87, 3, 6),
('Operate.xix',	7662.92, 7,	7)

INSERT INTO Issues(Title, IssueStatus, RepositoryId, AssigneeId)
VALUES
('Critical Problem with HomeController.cs file', 'open', 1,	4),
('Typo fix in Judge.html', 'open',	4, 3),
('Implement documentation for UsersService.cs',	'closed', 8, 2),
('Unreachable code in Index.cs', 'open', 9,	8)

--03. Update
UPDATE Issues
SET IssueStatus = 'closed'
WHERE AssigneeId = 6

--04. Delete
DELETE FROM RepositoriesContributors
WHERE RepositoryId = 3

DELETE FROM Issues
WHERE RepositoryId = 3

--05. Commits
SELECT
	Id,
	Message,
	RepositoryId,
	ContributorId
FROM Commits
ORDER BY Id ASC, 
		Message ASC, 
		RepositoryId ASC, 
		ContributorId ASC

--06. Front-end
SELECT
	Id,
	[Name],
	Size
FROM Files
WHERE [Name] LIKE '%html%'
AND Size > 1000
ORDER BY Size DESC, Id ASC, [Name] ASC

--07. Issue Assignment
SELECT
	i.Id,
	CONCAT(u.Username, ' ', ':', ' ', i.Title) AS IssueAssignee
FROM Issues AS i
JOIN Users AS u ON i.AssigneeId = u.Id
ORDER BY i.Id DESC, IssueAssignee ASC

--08. Single Files
SELECT
	f1.Id,
	f1.[Name],
	CONCAT(f1.Size, 'KB') AS Size
FROM Files AS f1
WHERE NOT EXISTS (SELECT f1.ParentId
                  FROM Files AS f2
				  WHERE f2.ParentId = f1.Id)
ORDER BY Id ASC, [Name] ASC, Size DESC

--09. Commits in Repositories
SELECT TOP(5)
	r.Id,
	r.Name,
	COUNT(*) AS Commits
FROM Repositories AS r
JOIN RepositoriesContributors AS rc ON  r.Id = rc.RepositoryId
JOIN Commits AS c ON r.Id = c.RepositoryId
GROUP BY r.Id, r.Name
ORDER BY Commits DESC, r.Id ASC, r.Name ASC

--10. Average Size
SELECT
	u.Username,
	AVG(f.Size) AS Size
FROM Users AS u
JOIN Commits AS c ON u.Id = c.ContributorId
JOIN Files AS f ON c.Id = CommitId
GROUP BY U.Username
ORDER BY Size DESC, u.Username ASC

--11. All User Commits
CREATE FUNCTION udf_AllUserCommits(@username VARCHAR(30))
RETURNS INT 
AS 
BEGIN
	DECLARE @countOfCommitsOfUser INT =
	(
		SELECT
			COUNT(*)
		FROM Users AS u 
		JOIN Commits AS c ON u.Id = c.ContributorId
		WHERE u.Username = @username
	)
	RETURN @countOfCommitsOfUser
END

----12. Search for Files
CREATE PROC usp_SearchForFiles(@fileExtension VARCHAR(30))
AS
SELECT
	Id,
	Name,
	CONCAT(Size, 'KB') AS Size
FROM Files
WHERE Name LIKE (CONCAT('%', @fileExtension))
ORDER BY Id ASC, Name ASC, Size DESC