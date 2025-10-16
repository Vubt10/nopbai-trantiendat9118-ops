-- LAB 5 - STORED PROCEDURES
-- =============================================

USE QLDA
GO

-- BÀI 1: CÁC STORED PROCEDURE CƠ BẢN
-- =============================================

-- 1.1. In lời chào với tên Tiếng Việt
CREATE OR ALTER PROC sp_ChaoTen
    @ten NVARCHAR(50)
AS
BEGIN
    PRINT N'Xin chào ' + @ten
END
GO

-- 1.2. Tính tổng 2 số
CREATE OR ALTER PROC sp_TongHaiSo
    @s1 INT,
    @s2 INT
AS
BEGIN
    DECLARE @tg INT
    SET @tg = @s1 + @s2
    PRINT N'Tổng là: ' + CAST(@tg AS NVARCHAR(10))
END
GO

-- 1.3. Tính tổng các số chẵn từ 1 đến @n
CREATE OR ALTER PROC sp_TongChan
    @n INT
AS
BEGIN
    DECLARE @i INT = 1, @tong INT = 0
    WHILE @i <= @n
    BEGIN
        IF @i % 2 = 0
            SET @tong = @tong + @i
        SET @i = @i + 1
    END
    PRINT N'Tổng các số chẵn từ 1 đến ' + CAST(@n AS NVARCHAR(10)) + ' là: ' + CAST(@tong AS NVARCHAR(10))
END
GO

-- 1.4. Tìm ước chung lớn nhất (UCLN)
CREATE OR ALTER PROC sp_UCLN
    @a INT,
    @b INT
AS
BEGIN
    DECLARE @x INT = ABS(@a), @y INT = ABS(@b)
    WHILE @y > 0
    BEGIN
        DECLARE @temp INT = @y
        SET @y = @x % @y
        SET @x = @temp
    END
    PRINT N'UCLN của ' + CAST(@a AS NVARCHAR(10)) + ' và ' + CAST(@b AS NVARCHAR(10)) + ' là: ' + CAST(@x AS NVARCHAR(10))
END
GO

-- BÀI 2: THAO TÁC VỚI CƠ SỞ DỮ LIỆU QLDA
-- =============================================

-- 2.1. Xuất thông tin nhân viên theo số lượng
CREATE OR ALTER PROC sp_NhanVienTheoSoLuong
    @Many INT
AS
BEGIN
    SELECT TOP(@Many) *
    FROM NHANVIEN
END
GO

-- 2.2. Đếm số nhân viên tham gia đề án
CREATE OR ALTER PROC sp_SoNVThamGiaDA
    @MaDa INT
AS
BEGIN
    SELECT COUNT(DISTINCT MA_NVIEN) AS SoLuongNV
    FROM PHANCONG
    WHERE MADA = @MaDa
END
GO

-- 2.3. Đếm số nhân viên tham gia đề án tại địa điểm
CREATE OR ALTER PROC sp_SoNVThamGiaDA_DiaDiem
    @MaDa INT,
    @Ddiem_DA NVARCHAR(50)
AS
BEGIN
    SELECT COUNT(DISTINCT PC.MA_NVIEN) AS SoLuongNV
    FROM PHANCONG PC
    JOIN DEAN DA ON PC.MADA = DA.MADA
    WHERE PC.MADA = @MaDa AND DA.DDIEM_DA = @Ddiem_DA
END
GO

-- 2.4. Xuất thông tin nhân viên theo trưởng phòng và không có thân nhân
CREATE OR ALTER PROC sp_NVTheoTrphg_KhongThanNhan
    @Trphg NVARCHAR(10)
AS
BEGIN
    SELECT NV.*
    FROM NHANVIEN NV
    LEFT JOIN THANNHAN TN ON NV.MANV = TN.MA_NVIEN
    WHERE NV.MA_NQL = @Trphg AND TN.MA_NVIEN IS NULL
END
GO

-- 2.5. Kiểm tra nhân viên có thuộc phòng ban không
CREATE OR ALTER PROC sp_KT_NVThuocPhong
    @Many NVARCHAR(10),
    @Mapb INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM NHANVIEN WHERE MANV = @Many AND PHG = @Mapb)
        PRINT N'Nhân viên thuộc phòng ban này'
    ELSE
        PRINT N'Nhân viên KHÔNG thuộc phòng ban này'
END
GO

-- BÀI 3: THÊM VÀ CẬP NHẬT DỮ LIỆU
-- =============================================

-- 3.1. Thêm phòng ban CNTT (kiểm tra trùng)
CREATE OR ALTER PROC sp_ThemPhongCNTT
    @MaPhg INT,
    @TenPhg NVARCHAR(50)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM PHONGBAN WHERE MAPHG = @MaPhg)
        PRINT N'Thêm thất bại: Trùng mã phòng'
    ELSE
    BEGIN
        INSERT INTO PHONGBAN (TENPHG, MAPHG)
        VALUES (@TenPhg, @MaPhg)
        PRINT N'Thêm phòng CNTT thành công'
    END
END
GO

-- 3.2. Cập nhật tên phòng thành IT
CREATE OR ALTER PROC sp_CapNhatTenPhongIT
    @MaPhg INT
AS
BEGIN
    UPDATE PHONGBAN
    SET TENPHG = N'IT'
    WHERE MAPHG = @MaPhg
    PRINT N'Cập nhật thành công'
END
GO

-- 3.3. Thêm nhân viên mới với điều kiện
CREATE OR ALTER PROC sp_ThemNhanVienMoi
    @MaNV NVARCHAR(10),
    @TenNV NVARCHAR(50),
    @Phai NVARCHAR(5),
    @NgaySinh DATE,
    @DiaChi NVARCHAR(100),
    @Luong DECIMAL(10,2),
    @MaPB INT
AS
BEGIN
    DECLARE @Tuoi INT = DATEDIFF(YEAR, @NgaySinh, GETDATE())
    DECLARE @MaNQL NVARCHAR(10)

    -- Kiểm tra tuổi
    IF (@Phai = N'Nam' AND (@Tuoi < 18 OR @Tuoi > 65)) OR
       (@Phai = N'Nữ' AND (@Tuoi < 18 OR @Tuoi > 60))
    BEGIN
        PRINT N'Tuổi không hợp lệ'
        RETURN
    END

    -- Chọn người quản lý theo lương
    IF @Luong < 25000
        SET @MaNQL = '009'
    ELSE
        SET @MaNQL = '005'

    -- Thêm nhân viên
    INSERT INTO NHANVIEN (MANV, TENNV, PHAI, NGSINH, DCHI, LUONG, PHG, MA_NQL)
    VALUES (@MaNV, @TenNV, @Phai, @NgaySinh, @DiaChi, @Luong, @MaPB, @MaNQL)

    PRINT N'Thêm nhân viên thành công'
END
GO

-- PHẦN THỰC THI CÁC STORED PROCEDURE
-- =============================================

-- Thực thi Bài 1
PRINT N'=== BÀI 1: THỰC THI CÁC PROCEDURE CƠ BẢN ==='
EXEC sp_ChaoTen N'Nguyễn Văn A'
EXEC sp_TongHaiSo 10, 20
EXEC sp_TongChan 10
EXEC sp_UCLN 56, 98

-- Thực thi Bài 2
PRINT N'=== BÀI 2: THỰC THI CÁC PROCEDURE TRÊN CSDL QLDA ==='
EXEC sp_NhanVienTheoSoLuong 3
EXEC sp_SoNVThamGiaDA 1
EXEC sp_SoNVThamGiaDA_DiaDiem 1, N'Hà Nội'
EXEC sp_NVTheoTrphg_KhongThanNhan '004'
EXEC sp_KT_NVThuocPhong '001', 4

-- Thực thi Bài 3
PRINT N'=== BÀI 3: THỰC THI THÊM VÀ CẬP NHẬT DỮ LIỆU ==='
EXEC sp_ThemPhongCNTT 6, N'CNTT'
EXEC sp_CapNhatTenPhongIT 6

-- Thêm nhân viên mới (cần điều chỉnh tham số phù hợp)
/*
EXEC sp_ThemNhanVienMoi 
    @MaNV = '020',
    @TenNV = N'Nguyễn Thị B',
    @Phai = N'Nữ',
    @NgaySinh = '1995-05-15',
    @DiaChi = N'Hà Nội',
    @Luong = 30000,
    @MaPB = 6
*/

PRINT N'=== HOÀN THÀNH LAB 5 ==='