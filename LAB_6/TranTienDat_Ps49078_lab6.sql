-- LAB 6 - SQL TRIGGER
-- =============================================

USE QLDA
GO

-- BÀI 1: TRIGGER DML
-- =============================================

-- 1.1. Ràng buộc lương nhân viên > 15000
CREATE OR ALTER TRIGGER tg_CheckLuongNV
ON NHANVIEN
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE LUONG <= 15000)
    BEGIN
        RAISERROR(N'Lương phải > 15000', 16, 1)
        ROLLBACK TRANSACTION
    END
END
GO

-- 1.2. Ràng buộc tuổi nhân viên từ 18-65
CREATE OR ALTER TRIGGER tg_CheckTuoiNV
ON NHANVIEN
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted 
        WHERE DATEDIFF(YEAR, NGSINH, GETDATE()) NOT BETWEEN 18 AND 65
    )
    BEGIN
        RAISERROR(N'Tuổi nhân viên phải từ 18 đến 65', 16, 1)
        ROLLBACK TRANSACTION
    END
END
GO

-- 1.3. Không cho cập nhật nhân viên ở TP HCM
CREATE OR ALTER TRIGGER tg_KhongCapNhatNV_TPHCM
ON NHANVIEN
INSTEAD OF UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE DCHI LIKE N'%TP HCM%' OR DCHI LIKE N'%Hồ Chí Minh%')
    BEGIN
        RAISERROR(N'Không được cập nhật nhân viên ở TP HCM', 16, 1)
        ROLLBACK TRANSACTION
    END
    ELSE
    BEGIN
        UPDATE NV
        SET NV.TENNV = i.TENNV,
            NV.PHAI = i.PHAI,
            NV.NGSINH = i.NGSINH,
            NV.DCHI = i.DCHI,
            NV.LUONG = i.LUONG,
            NV.MA_NQL = i.MA_NQL,
            NV.PHG = i.PHG
        FROM NHANVIEN NV
        INNER JOIN inserted i ON NV.MANV = i.MANV
    END
END
GO

-- BÀI 2: TRIGGER AFTER
-- =============================================

-- 2.1. Hiển thị tổng số NV nam/nữ sau khi thêm mới
CREATE OR ALTER TRIGGER tg_ThongKeGioiTinh_Insert
ON NHANVIEN
AFTER INSERT
AS
BEGIN
    DECLARE @SoNam INT, @SoNu INT
    
    SELECT @SoNam = COUNT(*) FROM NHANVIEN WHERE PHAI = N'Nam'
    SELECT @SoNu = COUNT(*) FROM NHANVIEN WHERE PHAI = N'Nữ'
    
    PRINT N'Sau khi thêm - Tổng số nhân viên nam: ' + CAST(@SoNam AS NVARCHAR(10))
    PRINT N'Sau khi thêm - Tổng số nhân viên nữ: ' + CAST(@SoNu AS NVARCHAR(10))
END
GO

-- 2.2. Hiển thị tổng số NV nam/nữ sau khi cập nhật giới tính
CREATE OR ALTER TRIGGER tg_ThongKeGioiTinh_Update
ON NHANVIEN
AFTER UPDATE
AS
BEGIN
    IF UPDATE(PHAI)
    BEGIN
        DECLARE @SoNam INT, @SoNu INT
        
        SELECT @SoNam = COUNT(*) FROM NHANVIEN WHERE PHAI = N'Nam'
        SELECT @SoNu = COUNT(*) FROM NHANVIEN WHERE PHAI = N'Nữ'
        
        PRINT N'Sau khi cập nhật - Tổng số nhân viên nam: ' + CAST(@SoNam AS NVARCHAR(10))
        PRINT N'Sau khi cập nhật - Tổng số nhân viên nữ: ' + CAST(@SoNu AS NVARCHAR(10))
    END
END
GO

-- 2.3. Hiển thị số lượng đề án mỗi nhân viên sau khi xóa đề án
CREATE OR ALTER TRIGGER tg_ThongKeDA_SauKhiXoa
ON DEAN
AFTER DELETE
AS
BEGIN
    SELECT 
        NV.MANV,
        NV.TENNV,
        COUNT(PC.MADA) AS SoLuongDeAn
    FROM NHANVIEN NV
    LEFT JOIN PHANCONG PC ON NV.MANV = PC.MA_NVIEN
    GROUP BY NV.MANV, NV.TENNV
    ORDER BY NV.MANV
    
    PRINT N'Đã hiển thị số lượng đề án của mỗi nhân viên sau khi xóa đề án'
END
GO

-- BÀI 3: TRIGGER INSTEAD OF
-- =============================================

-- 3.1. Xóa thân nhân khi xóa nhân viên
CREATE OR ALTER TRIGGER tg_XoaThanNhan_InsteadOfDelete
ON NHANVIEN
INSTEAD OF DELETE
AS
BEGIN
    -- Xóa các thân nhân liên quan
    DELETE FROM THANNHAN
    WHERE MA_NVIEN IN (SELECT MANV FROM deleted)
    
    -- Sau đó xóa nhân viên
    DELETE FROM NHANVIEN
    WHERE MANV IN (SELECT MANV FROM deleted)
    
    PRINT N'Đã xóa nhân viên và các thân nhân liên quan'
END
GO

-- 3.2. Tự động phân công đề án 1 khi thêm nhân viên mới
CREATE OR ALTER TRIGGER tg_PhanCongDeAn1_InsteadOfInsert
ON NHANVIEN
INSTEAD OF INSERT
AS
BEGIN
    -- Chèn dữ liệu vào bảng NHANVIEN
    INSERT INTO NHANVIEN (MANV, TENNV, PHAI, NGSINH, DCHI, LUONG, MA_NQL, PHG)
    SELECT MANV, TENNV, PHAI, NGSINH, DCHI, LUONG, MA_NQL, PHG
    FROM inserted
    
    -- Tự động phân công đề án 1 cho nhân viên mới
    INSERT INTO PHANCONG (MA_NVIEN, MADA, THOIGIAN)
    SELECT MANV, 1, GETDATE()
    FROM inserted
    
    PRINT N'Đã thêm nhân viên và tự động phân công đề án 1'
END
GO

-- BÀI 4: TRIGGER BỔ SUNG (1 điểm) - PHIÊN BẢN ĐÃ SỬA
-- =============================================

-- Trigger kiểm tra số nhân viên trong phòng ban không vượt quá 10 người
CREATE OR ALTER TRIGGER tg_KiemTraSoNVPhongBan
ON NHANVIEN
AFTER INSERT, UPDATE
AS
BEGIN
    -- Kiểm tra nếu có thay đổi về phòng ban (PHG)
    IF UPDATE(PHG)
    BEGIN
        DECLARE @MaPhong INT, @SoNV INT
        
        -- Lấy mã phòng và số nhân viên từ bảng inserted
        SELECT @MaPhong = PHG FROM inserted
        
        -- Đếm số nhân viên trong phòng
        SELECT @SoNV = COUNT(*) 
        FROM NHANVIEN 
        WHERE PHG = @MaPhong
        
        -- Kiểm tra nếu số nhân viên vượt quá 10
        IF @SoNV > 10
        BEGIN
            RAISERROR(N'Số nhân viên trong phòng không được vượt quá 10 người', 16, 1)
            ROLLBACK TRANSACTION
        END
        ELSE
        BEGIN
            PRINT N'Số nhân viên trong phòng ' + CAST(@MaPhong AS NVARCHAR(10)) + 
                  N' hiện tại: ' + CAST(@SoNV AS NVARCHAR(10))
        END
    END
END
GO

-- KIỂM TRA CÁC TRIGGER
-- =============================================

PRINT N'=== KIỂM TRA TRIGGER BÀI 1 ==='

-- Test 1.1: Thử thêm nhân viên với lương <= 15000 (sẽ bị lỗi)
/*
PRINT N'Test 1.1 - Thêm NV với lương 14000:'
INSERT INTO NHANVIEN (MANV, TENNV, PHAI, NGSINH, DCHI, LUONG, PHG)
VALUES ('021', N'Nguyễn Văn Test', N'Nam', '1990-01-01', N'Hà Nội', 14000, 1)
*/

-- Test 1.1: Thêm nhân viên với lương hợp lệ
PRINT N'Test 1.1 - Thêm NV với lương 20000:'
INSERT INTO NHANVIEN (MANV, TENNV, PHAI, NGSINH, DCHI, LUONG, PHG)
VALUES ('022', N'Trần Thị Test', N'Nữ', '1995-05-15', N'Hà Nội', 20000, 1)

-- Test 1.2: Thử thêm nhân viên dưới 18 tuổi (sẽ bị lỗi)
/*
PRINT N'Test 1.2 - Thêm NV dưới 18 tuổi:'
INSERT INTO NHANVIEN (MANV, TENNV, PHAI, NGSINH, DCHI, LUONG, PHG)
VALUES ('023', N'Lê Văn Trẻ', N'Nam', '2010-01-01', N'Hà Nội', 20000, 1)
*/

PRINT N'=== KIỂM TRA TRIGGER BÀI 2 ==='

-- Test 2.1: Trigger sẽ tự động chạy khi thêm NV ở trên

-- Test 2.2: Cập nhật giới tính nhân viên
PRINT N'Test 2.2 - Cập nhật giới tính NV:'
UPDATE NHANVIEN 
SET PHAI = N'Nam' 
WHERE MANV = '022'

PRINT N'=== KIỂM TRA TRIGGER BÀI 3 ==='

-- Test 3.1: Xóa nhân viên (sẽ xóa cả thân nhân)
PRINT N'Test 3.1 - Xóa nhân viên:'
-- Thêm thân nhân trước khi test
INSERT INTO THANNHAN (MA_NVIEN, TENTN, PHAI, NGSINH, QUANHE)
VALUES ('022', N'Con của Test', N'Nam', '2020-01-01', N'Con')

-- Kiểm tra trước khi xóa
PRINT N'Trước khi xóa - Số thân nhân của NV 022:'
SELECT COUNT(*) AS SoThanNhan FROM THANNHAN WHERE MA_NVIEN = '022'

-- Thực hiện xóa
DELETE FROM NHANVIEN WHERE MANV = '022'

PRINT N'Sau khi xóa - Số thân nhân của NV 022:'
SELECT COUNT(*) AS SoThanNhan FROM THANNHAN WHERE MA_NVIEN = '022'

PRINT N'=== KIỂM TRA TRIGGER BÀI 4 (ĐÃ SỬA) ==='

-- Test 4.1: Kiểm tra số nhân viên trong phòng ban không vượt quá 10
PRINT N'Test 4.1 - Kiểm tra giới hạn số NV trong phòng:'

-- Đếm số NV hiện tại trong phòng 1
DECLARE @SoNVHienTai INT
SELECT @SoNVHienTai = COUNT(*) FROM NHANVIEN WHERE PHG = 1
PRINT N'Số nhân viên hiện tại trong phòng 1: ' + CAST(@SoNVHienTai AS NVARCHAR(10))

-- Thử thêm nhân viên mới vào phòng 1 (sẽ thành công nếu chưa vượt quá 10)
INSERT INTO NHANVIEN (MANV, TENNV, PHAI, NGSINH, DCHI, LUONG, PHG)
VALUES ('023', N'Phạm Văn Test', N'Nam', '1990-01-01', N'Hà Nội', 25000, 1)

PRINT N'=== HOÀN THÀNH LAB 6 - SQL TRIGGER ==='

-- XÓA CÁC TRIGGER (NẾU CẦN)
/*
DROP TRIGGER IF EXISTS tg_CheckLuongNV
DROP TRIGGER IF EXISTS tg_CheckTuoiNV
DROP TRIGGER IF EXISTS tg_KhongCapNhatNV_TPHCM
DROP TRIGGER IF EXISTS tg_ThongKeGioiTinh_Insert
DROP TRIGGER IF EXISTS tg_ThongKeGioiTinh_Update
DROP TRIGGER IF EXISTS tg_ThongKeDA_SauKhiXoa
DROP TRIGGER IF EXISTS tg_XoaThanNhan_InsteadOfDelete
DROP TRIGGER IF EXISTS tg_PhanCongDeAn1_InsteadOfInsert
DROP TRIGGER IF EXISTS tg_KiemTraSoNVPhongBan
*/