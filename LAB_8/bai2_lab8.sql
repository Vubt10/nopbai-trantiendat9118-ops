-- Bước 1: Tạo bản sao Full Backup:
BACKUP DATABASE AP
TO DISK = 'D:\SQL\BackupCSDL\APFull.bak'
WITH FORMAT,
NAME = 'Full Backup APFull1';

-- Bước 2: Thêm bảng Test1:
USE AP;
CREATE TABLE Test1 (ID INT, Name NVARCHAR(50));

-- Bước 3: Tạo bản Differential Backup đầu tiên:
BACKUP DATABASE AP
TO DISK = 'D:\SQL\BackupCSDL\APDiff1.bak'
WITH DIFFERENTIAL,
NAME = 'Differential Backup APDiff1';

-- Bước 4: Thêm bảng Test2:
CREATE TABLE Test2 (ID INT, Name NVARCHAR(50));

-- Bước 5: Tạo bản Differential Backup thứ hai:
BACKUP DATABASE AP
TO DISK = 'D:\SQL\BackupCSDL\APDiff2.bak'
WITH DIFFERENTIAL,
NAME = 'Differential Backup APDiff2';

--Bước 7: Phục hồi từ Full + Diff1:
USE master;
RESTORE DATABASE AP
FROM DISK = 'D:\SQL\BackupCSDL\APFull1.bak'
WITH NORECOVERY;
RESTORE DATABASE AP
FROM DISK = 'D:\SQL\BackupCSDL\APFull.bak'
WITH RECOVERY;

-- Bước 8: Phục hồi từ Full + Diff2:
USE master;
RESTORE DATABASE AP
FROM DISK = 'D:\SQL\BackupCSDL\APFull.bak'
WITH NORECOVERY;
RESTORE DATABASE AP
FROM DISK = 'D:\SQL\BackupCSDL\APDiff2.bak'
WITH RECOVERY;

-- Bước 9: Thử phục hồi dùng APFull.bak (Bài 1) + APDiff1.bak → báo lỗi do không khớp chuỗi backup.
USE master;
-- Restore bản Full đầu tiên (bài 1)
RESTORE DATABASE AP
FROM DISK = 'D:\SQL\BackupCSDL\APFull.bak'
WITH NORECOVERY;

-- Restore bản Diff của bài 2 (không cùng chuỗi)
RESTORE DATABASE AP
FROM DISK = 'D:\SQL\BackupCSDL\APDiff1.bak'
WITH RECOVERY;

