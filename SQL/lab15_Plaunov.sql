USE DB13_1

DROP TABLE IF EXISTS Workers

CREATE TABLE Workers(
    WorkersId INT PRIMARY KEY NOT NULL,
    Name VARCHAR(60) NOT NULL,
    Salary FLOAT NOT NULL,
    Bonus INT NOT NULL,
    CompanyId INT NOT NULL
)

GO

USE DB13_2

DROP TABLE IF EXISTS Company

CREATE TABLE Company(
    id INT PRIMARY KEY NOT NULL,
    Name VARCHAR(60) NOT NULL,
    Adress VARCHAR(60) NOT NULL UNIQUE,
)

GO

DROP VIEW IF EXISTS CompanyWorkersView
GO

CREATE VIEW CompanyWorkersView AS
    SELECT 
	com.id,
	com.Name AS CompanyName,
	com.Adress,
	wor.WorkersId,
	wor.Name AS WorkersName,
	wor.Bonus,
	wor.Salary
    FROM DB13_2.dbo.Company AS com, DB13_1.dbo.Workers AS wor WHERE com.id = wor.CompanyId
GO

USE DB13_1

DROP TRIGGER IF EXISTS onWorkersInsert
GO

CREATE TRIGGER onWorkersInsert ON Workers
INSTEAD OF INSERT
AS
BEGIN
    IF (EXISTS (
				SELECT CompanyId 
						FROM inserted 
						WHERE CompanyId 
						NOT IN (
								SELECT id 
								FROM DB13_2.dbo.Company
						)
			)
	)
	BEGIN
        RAISERROR('Wrong CompanyId', -1, 20)
    END
	ELSE
		BEGIN
		INSERT INTO Workers SELECT * FROM inserted
		END
END
GO

DROP TRIGGER IF EXISTS onWorkersDelete
GO
CREATE TRIGGER onWorkersDelete ON Workers
INSTEAD OF DELETE
AS
BEGIN
    DELETE wor 
		FROM Workers AS wor 
		INNER JOIN deleted 
		ON deleted.WorkersId = wor.WorkersId 
END
GO

DROP TRIGGER IF EXISTS onWorkersUpdate
GO

CREATE TRIGGER onWorkersUpdate ON Workers
INSTEAD OF UPDATE
AS
BEGIN
    IF (UPDATE(WorkersId))
		BEGIN
			RAISERROR('Cannot update WorkersId', -1, 20)
		END
	ELSE
    IF (UPDATE(CompanyId) AND 
		EXISTS (
				SELECT CompanyId 
					FROM inserted 
					WHERE CompanyId 
					NOT IN (
							SELECT id 
							FROM DB13_2.dbo.Company
					)
		)
	)
		BEGIN
			RAISERROR('Wrong CompanyId', -1, 20)
        END
    ELSE
	UPDATE Workers SET Name = ins.Name,
					   Bonus = ins.Bonus,
					   Salary = ins.Salary,
					   CompanyId = ins.CompanyId 
		FROM Workers AS wor 
		INNER JOIN inserted AS ins
		ON ins.WorkersId = wor.WorkersId
END
GO

USE DB13_2

GO

DROP TRIGGER IF EXISTS onCompanyInsert
GO

CREATE TRIGGER onCompanyInsert ON Company
INSTEAD OF INSERT
AS
BEGIN
    IF (EXISTS (SELECT id 
					FROM inserted 
					WHERE id in (SELECT id FROM Company)
		)
	) 
		BEGIN
			RAISERROR('CompanyId already exist', -1, 20)
		END
    ELSE
	IF (EXISTS (SELECT Adress 
					FROM inserted 
					WHERE Adress in (SELECT Adress FROM Company)
		)
	) 
		BEGIN
			RAISERROR('Adress must be unique', -1, 20)
		END
    ELSE
		INSERT INTO Company SELECT * FROM inserted
END
GO

DROP TRIGGER IF EXISTS onCompanyDelete
GO

CREATE TRIGGER onCompanyDelete ON Company
INSTEAD OF DELETE
AS
BEGIN
    DELETE FROM DB13_1.dbo.Workers 
		WHERE CompanyId IN (SELECT id FROM deleted) 
    DELETE com FROM Company AS com INNER JOIN deleted ON deleted.id = com.id 
END
GO

DROP TRIGGER IF EXISTS onCompanyUpdate
GO

CREATE TRIGGER onCompanyUpdate ON Company
INSTEAD OF UPDATE
AS
BEGIN
    IF (UPDATE(id))
		BEGIN
			RAISERROR('Cannot update CompanyId', -1, 20)
		END
	ELSE
		UPDATE Company SET Name = ins.Name,
						   Adress = ins.Adress
			FROM Company AS com INNER JOIN inserted AS ins 
			ON com.id = ins.id
END
GO

INSERT INTO Company VALUES  (1,'Krok','Moscow'),
							(2,'Google','San Jose')

INSERT INTO DB13_1.dbo.Workers VALUES	(1,'Steve', 999, 3, 2),
										(2,'Anna', 9990, 15, 2),
										(3,'Alex', 9393, 9, 1)


SELECT * FROM CompanyWorkersView
SELECT * FROM DB13_1.dbo.Workers
SELECT * FROM DB13_2.dbo.Company

DELETE FROM Company WHERE Company.id=2
UPDATE DB13_1.dbo.Workers SET CompanyId = 4 WHERE Name = 'Alex' -- wrong companyId
SELECT * FROM CompanyWorkersView

INSERT INTO Company VALUES  (3, 'Yandex', 'Moscow, h. 99')
UPDATE DB13_1.dbo.Workers SET CompanyId = 3 WHERE Name = 'Alex'

SELECT * FROM CompanyWorkersView
SELECT * FROM DB13_1.dbo.Workers
SELECT * FROM DB13_2.dbo.Company