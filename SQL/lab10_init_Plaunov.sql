USE Lab
GO
DROP TABLE IF EXISTS BankAccount
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
	VALUES (2.0, 6000.0, 0), 
		   (2.3, 8000.0, 5),
		   (1.7, 3500.0, 13),
		   (3.0, 2700.0, 3),
		   (8.0, 7300.0, 7),
		   (4.0, 15000.0, 9),
		   (6.5, 20000.0, 13),
		   (8.0, 23000.0, 17);
GO