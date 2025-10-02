-- ==============================================
-- Lab 2 - Bài 2: Sử dụng biến trong T-SQL
-- ==============================================

-- PHẦN 1: Tính diện tích, chu vi hình chữ nhật
DECLARE @dai FLOAT, @rong FLOAT, @dientich FLOAT, @chuvi FLOAT;

SET @dai = 10;   -- gán chiều dài
SET @rong = 5;   -- gán chiều rộng

SET @dientich = @dai * @rong;
SET @chuvi = 2 * (@dai + @rong);

PRINT N'Chiều dài = ' + CAST(@dai AS VARCHAR);
PRINT N'Chiều rộng = ' + CAST(@rong AS VARCHAR);
PRINT N'Diện tích = ' + CAST(@dientich AS VARCHAR);
PRINT N'Chu vi = ' + CAST(@chuvi AS VARCHAR);
GO

-- PHẦN 2: Truy vấn CSDL QLDA với biến

-- 1. Nhân viên có lương cao nhất
DECLARE @maxLuong FLOAT;

SELECT @maxLuong = MAX(LUONG) FROM NHANVIEN;

SELECT HONV, TENLOT, TENNV, LUONG
FROM NHANVIEN
WHERE LUONG = @maxLuong;
GO

-- 2. Nhân viên có lương > lương trung bình của phòng "Nghiên cứu"
DECLARE @LuongTB FLOAT;

SELECT @LuongTB = AVG(LUONG)
FROM NHANVIEN NV
JOIN PHONGBAN PB ON NV.PHG = PB.MAPHG
WHERE PB.TENPHG = N'Nghiên cứu';

SELECT HONV, TENLOT, TENNV, LUONG
FROM NHANVIEN
WHERE LUONG > @LuongTB;
GO

-- 3. Phòng ban có lương TB > 30000: in tên phòng ban + số NV
SELECT PB.TENPHG, COUNT(NV.MANV) AS SoLuongNV
FROM NHANVIEN NV
JOIN PHONGBAN PB ON NV.PHG = PB.MAPHG
GROUP BY PB.TENPHG
HAVING AVG(LUONG) > 30000;
GO

-- 4. Mỗi phòng ban: tên phòng ban + số lượng đề án chủ trì
SELECT PB.TENPHG, COUNT(DA.MADA) AS SoLuongDeAn
FROM PHONGBAN PB
LEFT JOIN DEAN DA ON PB.MAPHG = DA.PHONG
GROUP BY PB.TENPHG;
GO
