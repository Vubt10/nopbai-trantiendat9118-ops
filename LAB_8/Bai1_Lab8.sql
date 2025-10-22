-- Bước 3.2 Thực hiện Full Backup
BACKUP DATABASE AP
TO DISK = 'D:\SQL\BackupCSDL\APFull.bak'
WITH FORMAT,
NAME = 'Full Backup of AP';
-- Bước 4: Thêm bảng mới Test để kiểm tra:
USE AP;
CREATE TABLE Test (
    ID INT PRIMARY KEY,
    Name NVARCHAR(50)
);
-- Bước 5: Phục hồi lại CSDL từ bản Full Backup:
USE master;
RESTORE DATABASE AP
FROM DISK = 'D:\SQL\BackupCSDL\APFull.bak'
WITH REPLACE;

 -- Bước 6: Kiểm tra lại — bảng Test không còn tồn tại  phục hồi thành công.
USE AP;
SELECT * 
FROM sys.tables
WHERE name = 'Test';

