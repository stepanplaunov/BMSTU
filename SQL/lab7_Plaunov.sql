USE Lab;
GO

DROP VIEW IF EXISTS Masters;
GO
CREATE VIEW Masters AS
	SELECT * FROM Users WHERE Rating > 1500;
GO
SELECT * FROM Masters;
GO


DROP VIEW IF EXISTS LanguageWithType;
GO
CREATE VIEW LanguageWithType AS
SELECT a.LanguageFilesId, a.FileType,
	   b.LanguageId, b.LanguageName
FROM LanguageFiles AS a INNER JOIN Languages AS b ON a.LanguageFilesId = b.LanguageId
GO

SELECT * FROM LanguageWithType;

DROP INDEX IF EXISTS UsersIndex on Users
GO
CREATE INDEX UsersIndex
	ON Users (UserId)
	INCLUDE (Permission)
GO
SELECT UserId, Permission
FROM Users WITH (INDEX(UsersIndex)) WHERE Permission = 'common'
GO


DROP VIEW IF EXISTS ViewWithIdex
GO
CREATE VIEW ViewWithIdex WITH SCHEMABINDING AS
	SELECT UserId, UserName, Rating, Email FROM dbo.Users WHERE Rating > 2000
GO
CREATE UNIQUE CLUSTERED INDEX ind_view ON ViewWithIdex (UserId, Email);
GO
SELECT * FROM ViewWithIdex
GO


