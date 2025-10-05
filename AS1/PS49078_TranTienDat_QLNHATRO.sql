USE [QLNHATRO_TranTienDat_PS49078];
GO


---------------------------------------------------
-- Y2. INSERT DỮ LIỆU MẪU
---------------------------------------------------

-- LOAINHA
INSERT INTO LOAINHA (TenLoaiNha) VALUES
(N'Căn hộ chung cư'),
(N'Nhà riêng'),
(N'Phòng trọ/Trọ sinh viên'),
(N'Nhà nguyên căn');
GO

-- NGUOIDUNG
INSERT INTO NGUOIDUNG (Ten, GioiTinh, DienThoai, DiaChi, Quan, Email, NgayTao) VALUES
(N'Nguyễn Văn A', N'Nam', N'0901000001', N'123 Lê Lợi', N'Quận 1', N'vana@example.com', GETDATE()),
(N'Trần Thị B', N'Nữ', N'0901000002', N'45 Nguyễn Huệ', N'Quận 1', N'thib@example.com', GETDATE()),
(N'Lê Văn C', N'Nam', N'0901000003', N'67 Lý Tự Trọng', N'Quận 3', N'levanc@example.com', GETDATE()),
(N'Phạm Thị D', N'Nữ', N'0901000004', N'89 Trần Hưng Đạo', N'Quận 5', N'thid@example.com', GETDATE()),
(N'Hoàng Minh E', N'Nam', N'0901000005', N'10 Võ Văn Tần', N'Quận 3', N'minhe@example.com', GETDATE()),
(N'Ngô Thị F', N'Nữ', N'0901000006', N'22 Hai Bà Trưng', N'Quận 1', N'thif@example.com', GETDATE()),
(N'Bùi Văn G', N'Nam', N'0901000007', N'5 Cách Mạng Tháng 8', N'Quận 10', N'vang@example.com', GETDATE()),
(N'Phan Thị H', N'Nữ', N'0901000008', N'100 Trường Chinh', N'Quận Tân Bình', N'phh@example.com', GETDATE()),
(N'Đỗ Văn I', N'Nam', N'0901000009', N'200 Kinh Dương Vương', N'Quận Bình Tân', N'dvi@example.com', GETDATE()),
(N'Võ Thị J', N'Nữ', N'0910123456', N'300 Nguyễn Trãi', N'Quận 5', N'vtj@example.com', GETDATE());
GO

-- NHATRO
INSERT INTO NHATRO (MaLoai, DienTich, Gia, DiaChi, Quan, MoTa, NgayDang, MaNguoiLienHe) VALUES
(3, 20.00, 2500000, N'Phòng trọ 1, hẻm 12 Nguyễn Trãi', N'Quận 5', N'Phòng sạch, có gác, WC trong phòng', '2025-09-01', 4),
(1, 55.00, 7000000, N'Căn hộ 2PN, chung cư X', N'Quận 1', N'2PN, view đẹp', '2025-08-20', 1),
(2, 90.00, 12000000, N'Nhà nguyên căn 3 tầng', N'Quận 3', N'Nhà nguyên căn, có sân', '2025-07-15', 5),
(3, 18.50, 1800000, N'Phòng trọ gần trường', N'Quận Tân Bình', N'Ưu tiên sinh viên', '2025-09-10', 8),
(3, 25.00, 3000000, N'Phòng trọ tiện nghi', N'Quận 10', N'Có máy lạnh', '2025-09-05', 7),
(1, 65.00, 9000000, N'Căn hộ 3PN', N'Quận 3', N'Full nội thất', '2025-06-01', 1),
(2, 100.00, 15000000, N'Nhà 4 PN cho thuê', N'Quận 1', N'Gần chợ, phù hợp gia đình', '2025-05-20', 2),
(3, 12.00, 1200000, N'Phòng nhỏ giá rẻ', N'Quận Bình Tân', N'Giá rẻ, không gác', '2025-04-01', 9),
(3, 30.00, 4500000, N'Phòng 1PN mới xây', N'Quận 5', N'An ninh tốt', '2025-09-15', 6),
(1, 45.00, 6000000, N'Căn hộ 1PN', N'Quận Tân Bình', N'Gần nhà ga', '2025-08-25', 8);
GO

-- DANHGIA
INSERT INTO DANHGIA (MaND, MaNhaTro, TrangThai, NoiDung, NgayDG) VALUES
(2, 1, N'LIKE', N'Phòng sạch, chủ tốt', '2025-09-02'),
(3, 1, N'LIKE', N'Vị trí thuận tiện', '2025-09-03'),
(4, 2, N'LIKE', N'Nhà đẹp, có ban công', '2025-08-21'),
(5, 3, N'DISLIKE', N'Giá hơi cao so với tiện nghi', '2025-07-20'),
(6, 4, N'LIKE', N'Thích hợp sinh viên', '2025-09-11'),
(7, 5, N'DISLIKE', N'Không có chỗ để xe', '2025-09-06'),
(8, 6, N'LIKE', N'Nội thất ok', '2025-06-02'),
(9, 7, N'LIKE', N'Nhà rộng, phù hợp gia đình', '2025-05-22'),
(10, 8, N'DISLIKE', N'Phòng ẩm ướt vào mùa mưa', '2025-04-05'),
(1, 9, N'LIKE', N'An ninh tốt', '2025-09-16'),
(2, 9, N'DISLIKE', N'Giá hơi cao cho diện tích', '2025-09-17'),
(3, 10, N'LIKE', N'Gần tiện ích', '2025-08-26');
GO

---------------------------------------------------
-- Y3. FUNCTION, VIEW, STORED PROCEDURE
---------------------------------------------------

-- Hàm lấy mã người dùng
CREATE OR ALTER FUNCTION fn_GetMaNguoiDung (
    @Ten NVARCHAR(100),
    @GioiTinh NVARCHAR(10),
    @DienThoai NVARCHAR(20),
    @DiaChi NVARCHAR(200),
    @Quan NVARCHAR(100),
    @Email NVARCHAR(100)
)
RETURNS INT
AS
BEGIN
    DECLARE @MaNguoiDung INT;
    SELECT @MaNguoiDung = MaND
    FROM NGUOIDUNG
    WHERE Ten=@Ten AND GioiTinh=@GioiTinh AND DienThoai=@DienThoai 
          AND DiaChi=@DiaChi AND Quan=@Quan AND Email=@Email;
    RETURN @MaNguoiDung;
END;
GO

-- Hàm đếm LIKE/DISLIKE
CREATE OR ALTER FUNCTION fn_CountLikeDislike(@MaNhaTro INT)
RETURNS TABLE
AS
RETURN (
    SELECT 
        SUM(CASE WHEN TrangThai='LIKE' THEN 1 ELSE 0 END) AS TotalLike,
        SUM(CASE WHEN TrangThai='DISLIKE' THEN 1 ELSE 0 END) AS TotalDislike
    FROM DANHGIA
    WHERE MaNhaTro=@MaNhaTro
);
GO

-- View top 10 nhà trọ LIKE nhiều nhất
CREATE OR ALTER VIEW v_Top10NhaTro AS
SELECT TOP 10 NT.MaNhaTro, NT.DiaChi, NT.Quan, NT.Gia, COUNT(DG.TrangThai) AS SoLike
FROM NHATRO NT
JOIN DANHGIA DG ON NT.MaNhaTro=DG.MaNhaTro
WHERE DG.TrangThai='LIKE'
GROUP BY NT.MaNhaTro, NT.DiaChi, NT.Quan, NT.Gia
ORDER BY SoLike DESC;
GO

-- SP xem đánh giá
CREATE OR ALTER PROCEDURE sp_XemDanhGia
    @MaNhaTro INT
AS
BEGIN
    SELECT DG.MaNhaTro, ND.Ten, DG.TrangThai, DG.NoiDung
    FROM DANHGIA DG
    JOIN NGUOIDUNG ND ON DG.MaND = ND.MaND
    WHERE DG.MaNhaTro=@MaNhaTro;
END;
GO

-- SP thêm người dùng
CREATE OR ALTER PROCEDURE sp_ThemNguoiDung
    @Ten NVARCHAR(100),
    @GioiTinh NVARCHAR(10),
    @DienThoai NVARCHAR(20),
    @DiaChi NVARCHAR(200),
    @Quan NVARCHAR(100),
    @Email NVARCHAR(100)
AS
BEGIN
    IF (@Ten IS NULL OR @GioiTinh IS NULL OR @DiaChi IS NULL OR @Quan IS NULL)
    BEGIN
        PRINT N'❌ Thiếu dữ liệu!';
        RETURN;
    END
    INSERT INTO NGUOIDUNG (Ten, GioiTinh, DienThoai, DiaChi, Quan, Email, NgayTao)
    VALUES (@Ten, @GioiTinh, @DienThoai, @DiaChi, @Quan, @Email, GETDATE());
END;
GO

-- SP thêm nhà trọ
CREATE OR ALTER PROCEDURE sp_ThemNhaTro
    @MaLoai INT,
    @DienTich DECIMAL(7,2),
    @Gia DECIMAL(14,0),
    @DiaChi NVARCHAR(250),
    @Quan NVARCHAR(100),
    @MoTa NVARCHAR(1000),
    @MaNguoiLienHe INT
AS
BEGIN
    IF (@MaLoai IS NULL OR @DienTich IS NULL OR @Gia IS NULL OR 
        @DiaChi IS NULL OR @Quan IS NULL OR @MaNguoiLienHe IS NULL)
    BEGIN
        PRINT N'❌ Thiếu dữ liệu!';
        RETURN;
    END
    INSERT INTO NHATRO (MaLoai, DienTich, Gia, DiaChi, Quan, MoTa, NgayDang, MaNguoiLienHe)
    VALUES (@MaLoai, @DienTich, @Gia, @DiaChi, @Quan, @MoTa, GETDATE(), @MaNguoiLienHe);
END;
GO

-- SP thêm đánh giá
CREATE OR ALTER PROCEDURE sp_ThemDanhGia
    @MaND INT,
    @MaNhaTro INT,
    @TrangThai NVARCHAR(10),
    @NoiDung NVARCHAR(1000)
AS
BEGIN
    IF (@MaND IS NULL OR @MaNhaTro IS NULL OR @TrangThai IS NULL)
    BEGIN
        PRINT N'❌ Thiếu dữ liệu!';
        RETURN;
    END
    INSERT INTO DANHGIA (MaND, MaNhaTro, TrangThai, NoiDung, NgayDG)
    VALUES (@MaND, @MaNhaTro, @TrangThai, @NoiDung, GETDATE());
END;
GO

-- SP tìm kiếm nhà trọ
CREATE OR ALTER PROCEDURE sp_TimKiemNhaTro
    @Quan NVARCHAR(100) = NULL,
    @DienTichMin DECIMAL(7,2) = NULL,
    @DienTichMax DECIMAL(7,2) = NULL,
    @GiaMin DECIMAL(14,0) = NULL,
    @GiaMax DECIMAL(14,0) = NULL,
    @Loai INT = NULL,
    @NgayMin DATE = NULL,
    @NgayMax DATE = NULL
AS
BEGIN
    SELECT 
        N'Cho thuê phòng trọ tại ' + NT.DiaChi + N', ' + NT.Quan AS ThongTinPhong,
        FORMAT(NT.DienTich, 'N2') + N' m2' AS DienTich,
        FORMAT(NT.Gia, 'N0') AS Gia,
        NT.MoTa,
        FORMAT(NT.NgayDang, 'dd-MM-yyyy') AS NgayDang,
        CASE ND.GioiTinh 
            WHEN N'Nam' THEN N'A. ' + ND.Ten
            WHEN N'Nữ' THEN N'C. ' + ND.Ten
            ELSE ND.Ten END AS NguoiLienHe,
        ND.DienThoai,
        ND.DiaChi AS DiaChiLienHe
    FROM NHATRO NT
    JOIN NGUOIDUNG ND ON NT.MaNguoiLienHe = ND.MaND
    WHERE (@Quan IS NULL OR NT.Quan=@Quan)
      AND (@Loai IS NULL OR NT.MaLoai=@Loai)
      AND (@DienTichMin IS NULL OR NT.DienTich>=@DienTichMin)
      AND (@DienTichMax IS NULL OR NT.DienTich<=@DienTichMax)
      AND (@GiaMin IS NULL OR NT.Gia>=@GiaMin)
      AND (@GiaMax IS NULL OR NT.Gia<=@GiaMax)
      AND (@NgayMin IS NULL OR NT.NgayDang>=@NgayMin)
      AND (@NgayMax IS NULL OR NT.NgayDang<=@NgayMax);
END;
GO

-- SP xóa nhà trọ theo số dislike
CREATE OR ALTER PROCEDURE sp_XoaNhaTro_Dislike
    @SoDislike INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        DELETE DANHGIA
        WHERE MaNhaTro IN (
            SELECT MaNhaTro FROM DANHGIA
            GROUP BY MaNhaTro
            HAVING SUM(CASE WHEN TrangThai='DISLIKE' THEN 1 ELSE 0 END) > @SoDislike
        );

        DELETE NHATRO
        WHERE MaNhaTro IN (
            SELECT MaNhaTro FROM DANHGIA
            GROUP BY MaNhaTro
            HAVING SUM(CASE WHEN TrangThai='DISLIKE' THEN 1 ELSE 0 END) > @SoDislike
        );

        COMMIT TRANSACTION;
        PRINT N'✅ Xóa thành công!';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT N'❌ Lỗi khi xóa!';
    END CATCH
END;
GO

-- SP xóa nhà trọ theo ngày đăng
CREATE OR ALTER PROCEDURE sp_XoaNhaTro_TheoNgay
    @NgayMin DATE,
    @NgayMax DATE
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        DELETE DANHGIA
        WHERE MaNhaTro IN (
            SELECT MaNhaTro FROM NHATRO
            WHERE NgayDang BETWEEN @NgayMin AND @NgayMax
        );

        DELETE NHATRO
        WHERE NgayDang BETWEEN @NgayMin AND @NgayMax;

        COMMIT TRANSACTION;
        PRINT N'✅ Xóa thành công!';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT N'❌ Lỗi khi xóa!';
    END CATCH
END;
GO

---------------------------------------------------
-- Y4. TẠO NGƯỜI DÙNG & PHÂN QUYỀN
---------------------------------------------------

-- 1.1 Tạo login và user cho Admin
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'QLNHATRO_Admin')
    DROP LOGIN QLNHATRO_Admin;
GO
CREATE LOGIN QLNHATRO_Admin WITH PASSWORD = 'Admin@123';
GO

USE QLNHATRO_TranTienDat_PS49078;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'QLNHATRO_Admin')
    DROP USER QLNHATRO_Admin;
GO
CREATE USER QLNHATRO_Admin FOR LOGIN QLNHATRO_Admin;
ALTER ROLE db_owner ADD MEMBER QLNHATRO_Admin;
GO


-- 1.2 Tạo login và user cho User thường
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'QLNHATRO_User')
    DROP LOGIN QLNHATRO_User;
GO
CREATE LOGIN QLNHATRO_User WITH PASSWORD = 'User@123';
GO

USE QLNHATRO_TranTienDat_PS49078;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'QLNHATRO_User')
    DROP USER QLNHATRO_User;
GO
CREATE USER QLNHATRO_User FOR LOGIN QLNHATRO_User;

-- Cấp quyền CRUD + EXECUTE
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO QLNHATRO_User;
GRANT EXECUTE TO QLNHATRO_User;
GO
