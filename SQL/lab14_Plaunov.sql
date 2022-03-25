USE DB13_1

DROP TABLE IF EXISTS Workers

CREATE TABLE Workers (
	WorkerId INT PRIMARY KEY NOT NULL,
	--Name VARCHAR(20) NOT NULL,
	Salary FLOAT NOT NULL,
	Bonus INT NOT NULL
);
GO

USE DB13_2

DROP TABLE IF EXISTS Workers

CREATE TABLE Workers (
	WorkerId INT PRIMARY KEY NOT NULL,
	Name VARCHAR(20) NOT NULL,
	--Salary FLOAT NOT NULL,
	--Bonus INT NOT NULL
);
GO

DROP VIEW IF EXISTS WorkersView

GO

CREATE VIEW WorkersView AS
    SELECT d1.WorkerId, d1.Salary, d1.Bonus, 
		   d2.Name 
	FROM DB13_1.dbo.Workers AS d1, DB13_2.dbo.Workers as d2
    WHERE d1.WorkerId = d2.WorkerId
GO

DROP TRIGGER IF EXISTS onInsertTrigger

GO

CREATE TRIGGER onInsertTrigger ON WorkersView
INSTEAD OF INSERT
AS
BEGIN
    IF (EXISTS (SELECT WorkerId FROM DB13_1.dbo.Workers INTERSECT SELECT WorkerId FROM inserted)) 
		BEGIN
        RAISERROR('Workers with this WorkerId already exists',-1, 20)
		END
    ELSE
		BEGIN
		INSERT INTO DB13_1.dbo.Workers 
					SELECT WorkerId, Salary, Bonus FROM inserted
		INSERT INTO DB13_2.dbo.Workers 
					SELECT WorkerId, Name FROM inserted
		END
END
GO

DROP TRIGGER IF EXISTS onDeleteTrigger

GO

CREATE TRIGGER onDeleteTrigger ON WorkersView
INSTEAD OF DELETE
AS
BEGIN
    DELETE a FROM DB13_1.dbo.Workers AS a INNER JOIN deleted AS b ON a.WorkerId=b.WorkerId
    DELETE a FROM DB13_2.dbo.Workers AS a INNER JOIN deleted AS b ON a.WorkerId=b.WorkerId
END
GO

DROP TRIGGER IF EXISTS onUpdateTrigger

GO

CREATE TRIGGER onUpdateTrigger ON WorkersView
INSTEAD OF UPDATE
AS
BEGIN
	IF (UPDATE(WorkerId))
		BEGIN
			RAISERROR('Cannot change id',-1, 20)
		END
	ELSE
		BEGIN
		UPDATE DB13_1.dbo.Workers SET Salary = inserted.Salary, Bonus = inserted.Bonus 
		FROM DB13_1.dbo.Workers as a INNER JOIN inserted ON a.WorkerId = inserted.WorkerId
		UPDATE DB13_2.dbo.Workers SET Name = inserted.Name 
		FROM DB13_2.dbo.Workers as a INNER JOIN inserted ON a.WorkerId = inserted.WorkerId
		END
END
GO

INSERT INTO WorkersView VALUES 
								(1, 990, 3, 'Ivan'),
								(2, 9999, 5, 'Vlad'),
								(3, 99999, 27, 'Alex')

SELECT * FROM WorkersView

DELETE FROM WorkersView WHERE WorkerId=1
SELECT * FROM DB13_1.dbo.Workers
SELECT * FROM DB13_2.dbo.Workers
SELECT * FROM WorkersView

UPDATE WorkersView SET Bonus += 300 WHERE Name='Alex'
UPDATE WorkersView SET Name = 'anna' WHERE Name='Alex'
UPDATE WorkersView SET WorkerId = 10 WHERE Name='anna'
SELECT * FROM DB13_1.dbo.Workers
SELECT * FROM DB13_2.dbo.Workers
SELECT * FROM WorkersView