-- LAB 7 - USER-DEFINED FUNCTIONS & VIEWS (ĐÃ SỬA THEO SCHEMA THỰC TẾ)
-- =============================================

USE QLDA
GO

-- BÀI 1: USER-DEFINED FUNCTIONS
-- =============================================

-- 1.1. Hàm tính tuổi của nhân viên theo MaNV
CREATE OR ALTER FUNCTION fn_TuoiNhanVien
    (@MaNV NVARCHAR(9))
RETURNS INT
AS
BEGIN
    DECLARE @Tuoi INT
    
    SELECT @Tuoi = DATEDIFF(YEAR, NGSINH, GETDATE())
    FROM NHANVIEN
    WHERE MANV = @MaNV
    
    RETURN @Tuoi
END
GO

-- 1.2. Hàm đếm số lượng đề án nhân viên đã tham gia
CREATE OR ALTER FUNCTION fn_SoLuongDeAnThamGia
    (@MaNV NVARCHAR(9))
RETURNS INT
AS
BEGIN
    DECLARE @SoLuong INT
    
    SELECT @SoLuong = COUNT(DISTINCT MADA)
    FROM PHANCONG
    WHERE MA_NVIEN = @MaNV
    
    RETURN ISNULL(@SoLuong, 0)
END
GO

-- 1.3. Hàm đếm số lượng nhân viên theo phái
CREATE OR ALTER FUNCTION fn_SoLuongNVTheoPhai
    (@Phai NVARCHAR(3))
RETURNS INT
AS
BEGIN
    DECLARE @SoLuong INT
    
    SELECT @SoLuong = COUNT(*)
    FROM NHANVIEN
    WHERE PHAI = @Phai
    
    RETURN ISNULL(@SoLuong, 0)
END
GO

-- 1.4. Hàm tính lương trung bình và xuất NV có lương > lương TB của phòng
CREATE OR ALTER FUNCTION fn_NVCoLuongTrenTB
    (@TenPhong NVARCHAR(15))
RETURNS TABLE
AS
RETURN (
    WITH LuongTrungBinh AS (
        SELECT PHG, AVG(LUONG) AS LuongTB
        FROM NHANVIEN
        GROUP BY PHG
    )
    SELECT 
        NV.HONV,
        NV.TENLOT,
        NV.TENNV,
        NV.LUONG,
        LT.LuongTB AS LuongTrungBinhPhong
    FROM NHANVIEN NV
    INNER JOIN PHONGBAN PB ON NV.PHG = PB.MAPHG
    INNER JOIN LuongTrungBinh LT ON NV.PHG = LT.PHG
    WHERE PB.TENPHG = @TenPhong AND NV.LUONG > LT.LuongTB
)
GO

-- 1.5. Hàm thông tin phòng ban, trưởng phòng và số lượng đề án
CREATE OR ALTER FUNCTION fn_ThongTinPhongBan
    (@MaPhong INT)
RETURNS TABLE
AS
RETURN (
    SELECT 
        PB.TENPHG AS TenPhongBan,
        NV.HONV + ' ' + NV.TENLOT + ' ' + NV.TENNV AS HoTenTruongPhong,
        COUNT(DA.MADA) AS SoLuongDeAnChuTri
    FROM PHONGBAN PB
    LEFT JOIN NHANVIEN NV ON PB.TRPHG = NV.MANV
    LEFT JOIN DEAN DA ON PB.MAPHG = DA.PHONG
    WHERE PB.MAPHG = @MaPhong
    GROUP BY PB.TENPHG, NV.HONV, NV.TENLOT, NV.TENNV
)
GO

-- BÀI 2: VIEWS
-- =============================================

-- 2.1. View hiển thị thông tin nhân viên và phòng ban (SỬA LẠI)
CREATE OR ALTER VIEW vw_ThongTinNhanVienPhongBan
AS
SELECT 
    NV.HONV,
    NV.TENNV,
    PB.TENPHG,
    (SELECT TOP 1 DIADIEM FROM DIADIEM_PHG WHERE MAPHG = PB.MAPHG) AS DiaDiemPhong
FROM NHANVIEN NV
INNER JOIN PHONGBAN PB ON NV.PHG = PB.MAPHG
GO

-- 2.2. View hiển thị tên nhân viên, lương, tuổi
CREATE OR ALTER VIEW vw_NhanVienLuongTuoi
AS
SELECT 
    NV.HONV + ' ' + NV.TENLOT + ' ' + NV.TENNV AS HoTenNhanVien,
    NV.LUONG AS Luong,
    DATEDIFF(YEAR, NV.NGSINH, GETDATE()) AS Tuoi
FROM NHANVIEN NV
GO

-- 2.3. View hiển thị phòng ban đông nhân viên nhất và trưởng phòng
CREATE OR ALTER VIEW vw_PhongBanDongNhat
AS
WITH SoNhanVienPhong AS (
    SELECT 
        PHG,
        COUNT(*) AS SoNhanVien
    FROM NHANVIEN
    GROUP BY PHG
),
PhongBanDongNhat AS (
    SELECT TOP 1 WITH TIES
        PHG,
        SoNhanVien
    FROM SoNhanVienPhong
    ORDER BY SoNhanVien DESC
)
SELECT 
    PB.TENPHG AS TenPhongBan,
    NV.HONV + ' ' + NV.TENLOT + ' ' + NV.TENNV AS HoTenTruongPhong,
    PBDN.SoNhanVien AS SoLuongNhanVien
FROM PhongBanDongNhat PBDN
INNER JOIN PHONGBAN PB ON PBDN.PHG = PB.MAPHG
LEFT JOIN NHANVIEN NV ON PB.TRPHG = NV.MANV
GO

-- BÀI 3: BỔ SUNG (2 điểm)
-- =============================================

-- 3.1. View hiển thị thông tin nhân viên và số đề án đang tham gia
CREATE OR ALTER VIEW vw_NhanVienVaDeAn
AS
SELECT 
    NV.MANV,
    NV.HONV + ' ' + NV.TENLOT + ' ' + NV.TENNV AS HoTenNhanVien,
    NV.PHAI,
    NV.NGSINH,
    PB.TENPHG AS TenPhongBan,
    dbo.fn_SoLuongDeAnThamGia(NV.MANV) AS SoDeAnThamGia
FROM NHANVIEN NV
INNER JOIN PHONGBAN PB ON NV.PHG = PB.MAPHG
GO

-- 3.2. Hàm tính tổng lương của phòng ban
CREATE OR ALTER FUNCTION fn_TongLuongPhongBan
    (@MaPhong INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @TongLuong DECIMAL(10,2)
    
    SELECT @TongLuong = SUM(LUONG)
    FROM NHANVIEN
    WHERE PHG = @MaPhong
    
    RETURN ISNULL(@TongLuong, 0)
END
GO

-- 3.3. View hiển thị thông tin đề án và số lượng công việc (ĐÃ SỬA)
CREATE OR ALTER VIEW vw_ThongTinDeAnCongViec
AS
SELECT 
    DA.MADA,
    DA.TENDEAN,
    DA.DDIEM_DA,
    COUNT(CV.STT) AS SoLuongCongViec
FROM DEAN DA
LEFT JOIN CONGVIEC CV ON DA.MADA = CV.MADA
GROUP BY DA.MADA, DA.TENDEAN, DA.DDIEM_DA
GO

-- 3.4. Hàm tính số thân nhân của nhân viên
CREATE OR ALTER FUNCTION fn_SoThanNhan
    (@MaNV NVARCHAR(9))
RETURNS INT
AS
BEGIN
    DECLARE @SoLuong INT
    
    SELECT @SoLuong = COUNT(*)
    FROM THANNHAN
    WHERE MA_NVIEN = @MaNV
    
    RETURN ISNULL(@SoLuong, 0)
END
GO

-- KIỂM TRA CÁC HÀM VÀ VIEW
-- =============================================

PRINT N'=== KIỂM TRA BÀI 1: USER-DEFINED FUNCTIONS ==='

-- Test 1.1: Tính tuổi nhân viên
PRINT N'1.1. Tuổi của nhân viên 001:'
SELECT dbo.fn_TuoiNhanVien('001') AS TuoiNhanVien

-- Test 1.2: Số lượng đề án tham gia
PRINT N'1.2. Số đề án nhân viên 001 tham gia:'
SELECT dbo.fn_SoLuongDeAnThamGia('001') AS SoDeAnThamGia

-- Test 1.3: Số lượng nhân viên theo phái
PRINT N'1.3. Số lượng nhân viên:'
SELECT 
    dbo.fn_SoLuongNVTheoPhai(N'Nam') AS SoNVNam,
    dbo.fn_SoLuongNVTheoPhai(N'Nữ') AS SoNVNu

-- Test 1.4: Nhân viên có lương > lương TB phòng
PRINT N'1.4. Nhân viên có lương > lương TB phòng Nghiên cứu:'
SELECT * FROM dbo.fn_NVCoLuongTrenTB(N'Nghiên cứu')

-- Test 1.5: Thông tin phòng ban
PRINT N'1.5. Thông tin phòng ban mã 1:'
SELECT * FROM dbo.fn_ThongTinPhongBan(1)

PRINT N'=== KIỂM TRA BÀI 2: VIEWS ==='

-- Test 2.1: View thông tin nhân viên và phòng ban
PRINT N'2.1. Thông tin nhân viên và phòng ban:'
SELECT TOP 5 * FROM vw_ThongTinNhanVienPhongBan

-- Test 2.2: View nhân viên, lương, tuổi
PRINT N'2.2. Thông tin lương và tuổi nhân viên:'
SELECT TOP 5 * FROM vw_NhanVienLuongTuoi

-- Test 2.3: View phòng ban đông nhất
PRINT N'2.3. Phòng ban đông nhân viên nhất:'
SELECT * FROM vw_PhongBanDongNhat

PRINT N'=== KIỂM TRA BÀI 3: BỔ SUNG ==='

-- Test 3.1: View nhân viên và đề án
PRINT N'3.1. Thông tin nhân viên và số đề án:'
SELECT TOP 5 * FROM vw_NhanVienVaDeAn

-- Test 3.2: Hàm tổng lương phòng ban
PRINT N'3.2. Tổng lương phòng ban 1:'
SELECT dbo.fn_TongLuongPhongBan(1) AS TongLuongPhongBan

-- Test 3.3: View thông tin đề án và công việc
PRINT N'3.3. Thông tin đề án và công việc:'
SELECT TOP 5 * FROM vw_ThongTinDeAnCongViec

-- Test 3.4: Hàm số thân nhân
PRINT N'3.4. Số thân nhân của nhân viên 001:'
SELECT dbo.fn_SoThanNhan('001') AS SoThanNhan

PRINT N'=== THỐNG KÊ TỔNG HỢP ==='

-- Thống kê tổng hợp sử dụng các hàm và view đã tạo
PRINT N'Thống kê tổng hợp:'
SELECT 
    (SELECT COUNT(*) FROM NHANVIEN) AS TongSoNhanVien,
    (SELECT dbo.fn_SoLuongNVTheoPhai(N'Nam')) AS SoNVNam,
    (SELECT dbo.fn_SoLuongNVTheoPhai(N'Nữ')) AS SoNVNu,
    (SELECT COUNT(*) FROM DEAN) AS TongSoDeAn,
    (SELECT COUNT(*) FROM PHONGBAN) AS TongSoPhongBan,
    (SELECT COUNT(*) FROM THANNHAN) AS TongSoThanNhan

PRINT N'=== HOÀN THÀNH LAB 7 - FUNCTIONS & VIEWS ==='

-- XÓA CÁC FUNCTION VÀ VIEW (NẾU CẦN)
/*
DROP FUNCTION IF EXISTS fn_TuoiNhanVien
DROP FUNCTION IF EXISTS fn_SoLuongDeAnThamGia
DROP FUNCTION IF EXISTS fn_SoLuongNVTheoPhai
DROP FUNCTION IF EXISTS fn_NVCoLuongTrenTB
DROP FUNCTION IF EXISTS fn_ThongTinPhongBan
DROP FUNCTION IF EXISTS fn_TongLuongPhongBan
DROP FUNCTION IF EXISTS fn_SoThanNhan
DROP VIEW IF EXISTS vw_ThongTinNhanVienPhongBan
DROP VIEW IF EXISTS vw_NhanVienLuongTuoi
DROP VIEW IF EXISTS vw_PhongBanDongNhat
DROP VIEW IF EXISTS vw_NhanVienVaDeAn
DROP VIEW IF EXISTS vw_ThongTinDeAnCongViec
*/