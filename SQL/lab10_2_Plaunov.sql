USE Lab
GO


BEGIN TRANSACTION
	SELECT * FROM Workers
	SELECT * FROM sys.dm_tran_locks
COMMIT TRANSACTION
GO


BEGIN TRANSACTION
	SELECT * FROM Workers
	UPDATE Workers SET bonus += 1 WHERE WorkerId = 1
    WAITFOR DELAY '00:00:10'
	SELECT * FROM Workers
	SELECT * FROM sys.dm_tran_locks
COMMIT TRANSACTION
GO


BEGIN TRANSACTION
    INSERT INTO Workers (Experience, Salary, Bonus) VALUES (2.0, 9000, 3)
	--UPDATE Workers SET bonus += 1 WHERE WorkerId = 1 --Транзакция вызвала взаимоблокировку ресурсов блокировка с другим процессом и стала жертвой взаимоблокировки. Запустите транзакцию повторно.
	
    SELECT * FROM sys.dm_tran_locks
COMMIT TRANSACTION
go


BEGIN TRANSACTION
    INSERT INTO Workers (Experience, Salary, Bonus) VALUES (2.0, 6000.0, 300)
    SELECT resource_type, resource_subtype, request_mode FROM sys.dm_tran_locks
COMMIT TRANSACTION
GO
