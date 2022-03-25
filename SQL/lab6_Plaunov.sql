use Lab;
GO

DROP TABLE IF EXISTS Users;
GO

CREATE TABLE Users(
	UserId INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	UserName CHAR(30) NOT NULL,
	Email CHAR(90) UNIQUE CHECK(Email !='') NOT NULL
)

ALTER TABLE Users
ADD Rating INT CHECK (SIGN(Rating) = 1) NOT NULL
GO 

ALTER TABLE Users
ADD Permission CHAR(15) DEFAULT 'common' CHECK (Permission IN ('common', 'admin')) NOT NULL
GO


INSERT INTO Users (UserName, Email, Rating, Permission) VALUES ('Steve',  'common.mail@gmail.com', 1600, 'common')
INSERT INTO Users (UserName, Email, Rating, Permission) VALUES ('Magnus',  'maga.mail@gmail.com', 2855, 'admin')
INSERT INTO Users (UserName, Email, Rating, Permission) VALUES ('Karpov',  'karp.mail@gmail.com', 2755, 'admin')
INSERT INTO Users (UserName, Email, Rating, Permission) VALUES ('funnyuser1',  'fun.mail@gmail.com', 1100, 'common')
GO

SELECT * FROM Users;
GO

DROP TABLE IF EXISTS Grandmasters;
GO
CREATE TABLE Grandmasters (
	GrandmasterId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
	GrandmasterName Char(30) NOT NULL,
	RatingFIDE INT NOT NULL
)
GO

INSERT INTO Grandmasters (GrandmasterName, RatingFIDE) VALUES ('Magnus Carlsen', 2855);
GO

DROP TABLE IF EXISTS Files;
GO
CREATE TABLE Files(
	FileId int PRIMARY KEY NOT NULL,
	FileName CHAR(45) NOT NULL,
	FileType CHAR(15) DEFAULT '.txt' NOT NULL
)
GO

DROP SEQUENCE IF EXISTS Seq1;
GO
CREATE SEQUENCE Seq1
	START WITH 1
	INCREMENT BY 30
	MAXVALUE 3000;
GO

INSERT Files (FileId, FileName, FileType) VALUES (NEXT VALUE FOR Seq1, 'TxtBlockBegining', '.txt');
INSERT Files (FileId, FileName, FileType) VALUES (NEXT VALUE FOR Seq1, 'PyBlockBegining', '.py') ;
INSERT Files (FileId, FileName, FileType) VALUES (NEXT VALUE FOR Seq1, 'JavaBlockBegining', '.java');
INSERT Files (FileId, FileName, FileType) VALUES (NEXT VALUE FOR Seq1, 'CBlockBegining', '.c');
GO

SELECT * FROM Files;
GO

DROP TABLE IF EXISTS LanguageFiles;
GO
CREATE TABLE LanguageFiles(
	LanguageFilesId int PRIMARY KEY,
	FileType CHAR(20)
)
GO

DROP TABLE IF EXISTS Languages;
GO
CREATE TABLE Languages(
	LanguageId INT,
	LanguageName CHAR(20),
	CONSTRAINT const1 FOREIGN KEY (LanguageId) REFERENCES LanguageFiles (LanguageFilesId) ON DELETE NO ACTION
)
GO

INSERT LanguageFiles (LanguageFilesId, FileType) VALUES (1, '.c'), (2, '.java'), (3,'.js'), (4,'.py');
GO
INSERT Languages (LanguageId, LanguageName) VALUES (1, 'c'), (2, 'java'), (3, 'javascript'), (4, 'python');
GO

SELECT * FROM LanguageFiles;
SELECT * FROM Languages;
GO

ALTER TABLE Languages 
DROP CONSTRAINT const1;
GO

ALTER TABLE Languages 
ADD CONSTRAINT const2 FOREIGN KEY (LanguageId) REFERENCES LanguageFiles (LanguageFilesId) ON DELETE CASCADE;
GO

DELETE FROM LanguageFiles WHERE LanguageFilesId = 1; 
SELECT * FROM LanguageFiles;
SELECT * FROM Languages;

ALTER TABLE Languages 
DROP CONSTRAINT const2;
GO

ALTER TABLE Languages 
ADD CONSTRAINT const3 FOREIGN KEY (LanguageId) REFERENCES LanguageFiles (LanguageFilesId) ON DELETE SET NULL;
GO

DELETE FROM LanguageFiles WHERE LanguageFilesId = 2; 
SELECT * FROM LanguageFiles;
SELECT * FROM Languages;

ALTER TABLE Languages 
DROP CONSTRAINT const3;
GO

DROP TABLE Languages;
GO

CREATE TABLE Languages(
	LanguageId INT,
	LanguageName CHAR(20),
	Const INT DEFAULT 1 CONSTRAINT const4 REFERENCES LanguageFiles (LanguageFilesId) ON DELETE SET DEFAULT
)
GO


INSERT LanguageFiles (LanguageFilesId, FileType) VALUES (5, '.go');
INSERT LanguageFiles (LanguageFilesId, FileType) VALUES (1, '.с');
GO

INSERT Languages (LanguageId, LanguageName, Const) VALUES (1, 'go', 5);
GO


DELETE FROM LanguageFiles WHERE LanguageFilesId = 5; 
SELECT * FROM LanguageFiles;
SELECT * FROM Languages;
GO

ALTER TABLE Languages 
DROP CONSTRAINT const4;
GO

--| UPDATE test block
DROP TABLE IF EXISTS LanguageFiles;
GO
CREATE TABLE LanguageFiles(
	LanguageFilesId int PRIMARY KEY,
	FileType CHAR(20)
)
GO
DROP TABLE IF EXISTS Languages;
GO
CREATE TABLE Languages(
	LanguageId INT,
	LanguageName CHAR(20),
	CONSTRAINT const1 FOREIGN KEY (LanguageId) REFERENCES LanguageFiles (LanguageFilesId) ON UPDATE NO ACTION
)
GO
INSERT LanguageFiles (LanguageFilesId, FileType) VALUES (1, '.c'), (2, '.java'), (3,'.js'), (4,'.py');
INSERT Languages (LanguageId, LanguageName) VALUES (1, 'c'), (2, 'java'), (3, 'javascript'), (4, 'python');
GO
SELECT * FROM LanguageFiles;
SELECT * FROM Languages;
GO
ALTER TABLE Languages 
DROP CONSTRAINT const1;
GO
ALTER TABLE Languages 
ADD CONSTRAINT const2 FOREIGN KEY (LanguageId) REFERENCES LanguageFiles (LanguageFilesId) ON UPDATE CASCADE;
GO
UPDATE LanguageFiles
SET 
	LanguageFilesId = 5
WHERE LanguageFilesId = 1; 
SELECT * FROM LanguageFiles;
SELECT * FROM Languages;
GO

ALTER TABLE Languages 
DROP CONSTRAINT const2;
GO

ALTER TABLE Languages 
ADD CONSTRAINT const3 FOREIGN KEY (LanguageId) REFERENCES LanguageFiles (LanguageFilesId) ON UPDATE SET NULL;
GO
UPDATE LanguageFiles
SET 
	LanguageFilesId = 6
WHERE LanguageFilesId = 2; 
SELECT * FROM LanguageFiles;
SELECT * FROM Languages;
GO
 
ALTER TABLE Languages 
DROP CONSTRAINT const3;
GO

ALTER TABLE Languages 
ADD Const INT DEFAULT 3 CONSTRAINT const4 REFERENCES LanguageFiles (LanguageFilesId) ON UPDATE SET DEFAULT
GO

INSERT LanguageFiles (LanguageFilesId, FileType) VALUES (1, '.go');
INSERT Languages (LanguageId, LanguageName, Const) VALUES (1, 'go', 1);
GO
UPDATE LanguageFiles
SET 
	LanguageFilesId = 7
WHERE LanguageFilesId = 1; 
SELECT * FROM LanguageFiles;
SELECT * FROM Languages;
GO

DROP SEQUENCE Seq1;
GO
DROP TABLE Files;
GO
DROP TABLE Grandmasters;
GO
DROP TABLE Users;
GO