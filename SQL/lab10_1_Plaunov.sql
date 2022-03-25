USE Lab
GO

-- грязное чтение - чтение незафиксированных изменений
-- невоспроизводимое - при повторном чтении в рамках одной транзакции данные меняются
-- фантомное -- при втором чтении можно получить дополнительные строки

-- незавершенное чтение   (read uncommited) нет блока чтения, можно получить доступ к незафиксированным данным
-- завершенное чтение       (read commited) нет грязного чтения, читающая транзакция блокирует читаемые, а пищущая изменяемые данные, приостанавливая соответствующие транзакции (S режимы)
-- воспроизводимое чтение (repeatable read) нет невоиспроизводимого чтения, читаемая таблица блокируется, другие транзакции не могут менять выборку, но могут добавлять строки
-- сериализуемость           (serializable) нет фантомного чтения, полностью изолированные друг от друга транзакции

-- S (общий) = сеансу хранения предоставлен общий доступ к ресурсу.
-- X (эксклюзивная) = сеансу с удержанием предоставляется эксклюзивный доступ к ресурсу.
-- IX (с намерением монопольного доступа) = указывает на намерение поместить блокировки X на некоторые подчиненные ресурсы в иерархии блокировок.
-- IS (намеренный общий) = указывает намерение поместить блокировки S на некоторый подчиненный ресурс в иерархии блокировок.
-- RangeS_S (общий Key-Range и блокировка общего ресурса) = указывает на сериализуемый просмотр диапазона.
-- RangeI_N (вставка Key-Range и блокировка ресурса NULL) = используется для проверки диапазонов перед вставкой нового ключа в индекс.

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRANSACTION
 	SELECT * FROM Workers
 	UPDATE Workers SET bonus += 1 WHERE WorkerId = 1 
 	WAITFOR DELAY '00:00:05'
	SELECT * FROM Workers
	SELECT * FROM sys.dm_tran_locks
COMMIT TRAN
GO 


SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRANSACTION
    SELECT * FROM Workers
    WAITFOR DELAY '00:00:05'
	UPDATE Workers SET bonus += 1 WHERE WorkerId = 1
    SELECT * FROM Workers
    SELECT * FROM sys.dm_tran_locks
COMMIT TRANSACTION;
GO


SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
BEGIN TRANSACTION
    SELECT * FROM Workers  
    WAITFOR DELAY '00:00:05'  
    SELECT * FROM Workers
    SELECT * FROM sys.dm_tran_locks;
COMMIT TRANSACTION
GO


SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
BEGIN TRANSACTION
    SELECT * FROM Workers 
    WAITFOR DELAY '00:00:10'  
    SELECT * FROM Workers
    SELECT * FROM sys.dm_tran_locks
COMMIT TRANSACTION
GO
