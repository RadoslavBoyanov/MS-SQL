CREATE TABLE Users(
[Id] BIGINT NOT NULL IDENTITY PRIMARY KEY,
[Username] VARCHAR(30) NOT NULL,
[Password] VARCHAR(26) NOT NULL,
[ProfilePicture] VARBINARY(MAX),
CHECK (DATALENGTH([ProfilePicture]) <= 921600),
[LastLoginTime] DATETIME NOT NULL,
[IsDeleted] BIT NOT NULL
)

INSERT Users(Username, Password, ProfilePicture, LastLoginTime, IsDeleted)
VALUES
('Rado', '12345', NULL, '2020-08-24 15:40:10', 0),
('Vlado', '09876', NULL, '2021-06-27 22:02:11', 0),
('Gosho', '0000', NULL, '2022-11-15 01:17:12', 1),
('Yotov', '5555', NULL, '2010-12-08 02:36:13', 0),
('Domimitrichko', '1234567890', NULL, '2005-01-02 12:55:14', -1)
