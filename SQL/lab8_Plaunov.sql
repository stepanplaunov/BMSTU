USE Lab;
GO

DROP TABLE IF EXISTS Workers;
GO
CREATE TABLE Workers (
	WorkerId INT IDENTITY PRIMARY KEY NOT NULL,
	Experience FLOAT NOT NULL,
	Salary FLOAT NOT NULL,
	Bonus INT NOT NULL
);

INSERT INTO Workers 
	VALUES (2.0, 6000.0, 20), 
		   (2.3, 8000.0, 5),
		   (1.7, 3500.0, 13),
		   (3.0, 2700.0, 3),
		   (8.0, 7300.0, 7),
		   (4.0, 15000.0, 9),
		   (6.5, 20000.0, 13),
		   (8.0, 23000.0, 17);
GO

DROP FUNCTION IF EXISTS dbo.getTotalSalary
GO
CREATE FUNCTION getTotalSalary(@salary FLOAT, @bonus INT) RETURNS FLOAT
AS BEGIN
	RETURN @salary * (100 + @bonus) * 87 / 10000;
END;
GO

DROP FUNCTION IF EXISTS  dbo.getLevel
GO
CREATE FUNCTION getLevel(@exp FLOAT) RETURNS CHAR(20)
AS BEGIN
	DECLARE @level CHAR(20)
	IF @exp < 2.0 
		SET @level = 'junior';
	ELSE IF @exp < 4.0 
		SET @level = 'middle';
	ELSE
		SET @level = 'senior';
	RETURN @level;
END;
GO


DROP PROCEDURE IF EXISTS  dbo.getHighSalaryCursor
GO
CREATE PROCEDURE getHighSalaryCursor
	@cur CURSOR VARYING OUTPUT
AS
	SET @cur = CURSOR SCROLL STATIC FOR
	SELECT WorkerId, Experience, Bonus FROM Workers 
	WHERE Salary > 10000
	OPEN @cur
GO

DROP PROCEDURE IF EXISTS dbo.getTotalSalaryCursor
GO
CREATE PROCEDURE getTotalSalaryCursor
	@cur CURSOR VARYING OUTPUT
AS
	SET @cur = CURSOR SCROLL STATIC FOR
	SELECT WorkerId, Experience, dbo.getTotalSalary(Salary, Bonus) FROM Workers
	OPEN @cur
GO

DROP PROCEDURE IF EXISTS dbo.printMiddle
GO
CREATE PROCEDURE printMiddle
AS
	PRINT 'printMiddle (3):'; 
	DECLARE @cursor CURSOR;
	EXEC getTotalSalaryCursor @cur = @cursor OUTPUT;
	DECLARE  @exp FLOAT, @id INT, @totalsalary FLOAT;
	FETCH NEXT FROM @cursor INTO @id, @exp, @totalsalary;
	WHILE (@@FETCH_STATUS = 0)
		BEGIN;
			IF (dbo.getLevel(@exp) = 'middle')
				BEGIN;
					PRINT 'Id:' + CAST(@id AS CHAR) + 'Experience:' + CAST(@exp AS CHAR) + 'Salary:'+ CAST(@totalsalary AS CHAR);  
			
				END;
			FETCH NEXT FROM @cursor INTO @id, @exp, @totalsalary;
		END;
	CLOSE @cursor; 
	DEALLOCATE @cursor;
GO

EXEC printMiddle

DROP FUNCTION IF EXISTS dbo.getTable
GO
CREATE FUNCTION getTable() RETURNS TABLE
AS RETURN SELECT WorkerId, Experience, Salary, Bonus FROM Workers;
GO
CREATE FUNCTION getTable2() 
RETURNS @workers TABLE (
	WorkerId INT IDENTITY PRIMARY KEY NOT NULL,
	Experience FLOAT NOT NULL,
	Salary FLOAT NOT NULL,
	Bonus INT NOT NULL
)
AS
	BEGIN
		INSERT @workers
		SELECT WorkerId, Experience, Salary, Bonus 
		FROM Workers
		RETURN
	END;
GO

DROP PROCEDURE IF EXISTS dbo.getTableCursor
GO
CREATE PROCEDURE getTableCursor
	@result CURSOR VARYING OUTPUT
AS
	SET @result = CURSOR SCROLL STATIC FOR
	SELECT WorkerId, Experience, dbo.getTotalSalary(Salary, Bonus) FROM dbo.getTable() 
	OPEN @result
GO

DROP PROCEDURE IF EXISTS dbo.printAllWithTotal
GO
CREATE PROCEDURE printAllWithTotal
AS
	PRINT 'printAllWithTotal (4):'; 
	DECLARE @cursor CURSOR;
	EXEC dbo.getTableCursor @result = @cursor OUTPUT;
	DECLARE  @id INT, @salary FLOAT, @exp FLOAT;

	FETCH NEXT FROM @cursor INTO @id,@exp, @salary;
	WHILE (@@FETCH_STATUS = 0)
	BEGIN;
		PRINT 'Id:' + CAST(@id AS CHAR) + 'Experience:' + CAST(@exp AS CHAR) + 'Salary:'+ CAST(@salary AS CHAR);
		FETCH NEXT FROM @cursor INTO @id, @exp, @salary;
	END;
	CLOSE @cursor; 
	DEALLOCATE @cursor;
GO

EXEC printAllWithTotal