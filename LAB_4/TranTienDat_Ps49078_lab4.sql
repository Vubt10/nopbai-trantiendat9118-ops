-- ==============================================
-- Lab 4 – Điều kiện & Vòng lặp
-- ==============================================

-- BÀI 1: IF…ELSE và CASE
-- 1. Xem xét tăng lương
SELECT HONV + ' ' + TENLOT + ' ' + TENNV AS TenNV,
       CASE
           WHEN LUONG < (SELECT AVG(LUONG) FROM NHANVIEN N2 WHERE N2.PHG = NV.PHG)
               THEN 'TangLuong'
           ELSE 'KhongTangLuong'
       END AS KetQua
FROM NHANVIEN NV;
GO

-- 2. Phân loại nhân viên
SELECT HONV + ' ' + TENLOT + ' ' + TENNV AS TenNV,
       CASE
           WHEN LUONG < (SELECT AVG(LUONG) FROM NHANVIEN N2 WHERE N2.PHG = NV.PHG)
               THEN 'nhanvien'
           ELSE 'truongphong'
       END AS XepLoai
FROM NHANVIEN NV;
GO

-- 3. Hiển thị TenNV theo phái
SELECT CASE PHAI
           WHEN 'Nam' THEN 'Mr. ' + TENNV
           WHEN 'Nu'  THEN 'Ms. ' + TENNV
       END AS TenNV
FROM NHANVIEN;
GO

-- 4. Tính thuế thu nhập
SELECT HONV + ' ' + TENLOT + ' ' + TENNV AS TenNV,
       LUONG,
       CASE
           WHEN LUONG < 25000 THEN LUONG * 0.1
           WHEN LUONG BETWEEN 25000 AND 30000 THEN LUONG * 0.12
           WHEN LUONG BETWEEN 30000 AND 40000 THEN LUONG * 0.15
           WHEN LUONG BETWEEN 40000 AND 50000 THEN LUONG * 0.20
           ELSE LUONG * 0.25
       END AS ThuePhaiDong
FROM NHANVIEN;
GO


-- BÀI 2: Vòng lặp
-- 1. Nhân viên có MaNV chẵn
DECLARE @i INT = 1, @max INT;
SELECT @max = MAX(MANV) FROM NHANVIEN;

WHILE @i <= @max
BEGIN
    IF @i % 2 = 0
        SELECT HONV, TENLOT, TENNV FROM NHANVIEN WHERE MANV = @i;
    SET @i = @i + 1;
END
GO

-- 2. Nhân viên có MaNV chẵn nhưng bỏ qua MaNV=4
DECLARE @j INT = 1, @max2 INT;
SELECT @max2 = MAX(MANV) FROM NHANVIEN;

WHILE @j <= @max2
BEGIN
    IF @j % 2 = 0 AND @j <> 4
        SELECT HONV, TENLOT, TENNV FROM NHANVIEN WHERE MANV = @j;
    SET @j = @j + 1;
END
GO


-- BÀI 3: Quản lý lỗi
-- 1. Chèn dữ liệu đúng
BEGIN TRY
    INSERT INTO PHONGBAN(MAPHG, TENPHG, TRPHG, NG_NHANCHUC)
    VALUES (10, N'PhongMoi', NULL, GETDATE());
    PRINT N'Them du lieu thanh cong';
END TRY
BEGIN CATCH
    PRINT N'Them du lieu that bai';
END CATCH;
GO

-- 2. Chèn dữ liệu sai kiểu
BEGIN TRY
    INSERT INTO PHONGBAN(MAPHG, TENPHG, TRPHG, NG_NHANCHUC)
    VALUES ('SAI_KIEU', N'PhongLoi', NULL, GETDATE());
    PRINT N'Them du lieu thanh cong';
END TRY
BEGIN CATCH
    PRINT N'Them du lieu that bai';
END CATCH;
GO

-- 3. RAISERROR khi chia cho 0
DECLARE @chia INT = 10, @mau INT = 0;

BEGIN TRY
    IF @mau = 0
        RAISERROR('Loi: Khong the chia cho 0',16,1);
    ELSE
        PRINT @chia / @mau;
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH;
GO
