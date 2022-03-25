USE Lab;
GO

ALTER TABLE Languages 
DROP CONSTRAINT IF EXISTS const1;
GO
DROP TABLE IF EXISTS LanguageFiles;
GO
CREATE TABLE LanguageFiles(
	LanguageFilesId INT PRIMARY KEY IDENTITY(1,1),
	FileType CHAR(20)
)
GO

DROP TRIGGER IF EXISTS LF_insert_trigger
GO
CREATE TRIGGER LF_insert_trigger ON LanguageFiles
	AFTER INSERT AS
	IF EXISTS (SELECT FileType FROM inserted WHERE SUBSTRING(FileType, 1, 1) != '.')
		THROW 50001, 'The file type must start with "."', 1
	ELSE 
		PRINT 'LF_insert trigger';
GO


DROP TRIGGER IF EXISTS LF_delete_trigger
GO
CREATE TRIGGER LF_delete_trigger ON LanguageFiles
	AFTER DELETE AS
	PRINT 'LF_delete trigger';
GO

DROP TRIGGER IF EXISTS LF_update_trigger
GO
CREATE TRIGGER LF_update_trigger ON LanguageFiles
	AFTER UPDATE AS 
	IF EXISTS (SELECT FileType FROM inserted WHERE SUBSTRING(FileType, 1, 1) != '.')
		THROW 50001, 'The file type must start with "."', 1
	ELSE 
		PRINT 'LF_update trigger';
GO

INSERT LanguageFiles (FileType) VALUES ('.c'), ('.java'), ('.js'), ('.py');


DELETE FROM LanguageFiles where FileType = '.java'
SELECT * FROM LanguageFiles
GO
UPDATE LanguageFiles SET FileType = '.cpp' WHERE LanguageFilesId = 1;
-- INSERT LanguageFiles (FileType) VALUES ('go');
-- UPDATE LanguageFiles SET FileType = 'cpp' WHERE LanguageFilesId = 1;
SELECT * FROM LanguageFiles
GO

DROP TABLE IF EXISTS Languages;
GO
CREATE TABLE Languages(
	LanguageId INT PRIMARY KEY,
	LanguageName CHAR(20),
	CONSTRAINT const1 FOREIGN KEY (LanguageId) REFERENCES LanguageFiles (LanguageFilesId) ON UPDATE CASCADE ON DELETE CASCADE
)
GO

DROP VIEW IF EXISTS LanguageWithType;
GO
CREATE VIEW LanguageWithType AS
SELECT a.LanguageFilesId, a.FileType,
	   b.LanguageName
FROM LanguageFiles AS a INNER JOIN Languages AS b ON a.LanguageFilesId = b.LanguageId
GO

DROP TRIGGER IF EXISTS LanguageWithTypeDelete
GO
CREATE TRIGGER LanguageWithTypeDelete
ON LanguageWithType
INSTEAD OF DELETE
AS 
DELETE FROM LanguageFiles WHERE LanguageFilesId IN (SELECT LanguageFilesId FROM deleted);
GO


DROP TRIGGER IF EXISTS LanguageWithTypeInsert
GO
CREATE TRIGGER LanguageWithTypeInsert
ON LanguageWithType
INSTEAD OF INSERT
AS 
BEGIN; 
	DECLARE @table TABLE (LanguageFilesId INT, FileType VARCHAR(20))
	INSERT INTO LanguageFiles (FileType)
		OUTPUT inserted.LanguageFilesId, inserted.FileType INTO @table SELECT FileType FROM inserted;
	
	INSERT INTO Languages SELECT t.LanguageFilesId,  inserted.LanguageName
		FROM @table AS t JOIN inserted ON t.FileType = inserted.FileType;
END;
GO

INSERT INTO LanguageWithType (FileType, LanguageName) VALUES
('.cpp','cpp'), 
('.go','go'), 
('.java', 'java')
GO

SELECT * FROM LanguageFiles
SELECT * FROM Languages
SELECT * FROM LanguageWithType

DELETE FROM LanguageWithType WHERE LanguageFilesId = 5;
GO

SELECT * FROM LanguageFiles
SELECT * FROM LanguageWithType;
GO 


DROP TRIGGER IF EXISTS LanguageWithTypeUpdate
GO
CREATE TRIGGER LanguageWithTypeUpdate
ON LanguageWithType
INSTEAD OF UPDATE
AS BEGIN; 
	IF UPDATE(FileType) or UPDATE(LanguageName)
	BEGIN;
		UPDATE LanguageFiles SET FileType = a.FileType
		FROM (SELECT LanguageFilesId,  FileType FROM inserted) AS a 
		WHERE (LanguageFiles.LanguageFilesId = a.LanguageFilesId)

		UPDATE Languages 
		SET LanguageName = (SELECT LanguageName FROM inserted  WHERE Languages.LanguageId = inserted.LanguageFilesId)
		WHERE LanguageId In (SELECT LanguageId FROM inserted WHERE Languages.LanguageId = inserted.LanguageFilesId)
	END;
	ELSE RAISERROR ('You cannot update ID', -1, 1);
END;
GO

INSERT INTO LanguageWithType (LanguageFilesId, FileType, LanguageName) VALUES
(8, '.hs','hask');
GO

UPDATE LanguageWithType SET LanguageName = 'haskell' WHERE LanguageFilesId = 8;
GO
SELECT * FROM LanguageFiles
SELECT * FROM Languages
SELECT * FROM LanguageWithType;
GO




