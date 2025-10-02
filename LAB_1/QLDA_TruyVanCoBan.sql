USE QLDA;
GO

-- 1. Nhân viên làm vi?c ? phòng s? 4
SELECT HONV, TENLOT, TENNV
FROM NHANVIEN
WHERE PHG = 4;

-- 2. Nhân viên l??ng > 30000
SELECT HONV, TENLOT, TENNV, LUONG
FROM NHANVIEN
WHERE LUONG > 30000;

-- 3. Nhân viên l??ng > 25,000 phòng 4 ho?c l??ng > 30,000 phòng 5
SELECT HONV, TENLOT, TENNV, LUONG, PHG
FROM NHANVIEN
WHERE (LUONG > 25000 AND PHG = 4)
   OR (LUONG > 30000 AND PHG = 5);

-- 4. H? tên ??y ?? nhân viên ? TP HCM
SELECT HONV + ' ' + TENLOT + ' ' + TENNV AS HOTEN
FROM NHANVIEN
WHERE DCHI LIKE '%TP HCM%';

-- 5. H? tên ??y ?? nhân viên có h? b?t ??u b?ng 'N'
SELECT HONV + ' ' + TENLOT + ' ' + TENNV AS HOTEN
FROM NHANVIEN
WHERE HONV LIKE 'N%';

-- 6. Ngày sinh và ??a ch? nhân viên Dinh Ba Tien
SELECT NGSINH, DCHI
FROM NHANVIEN
WHERE HONV = 'Dinh'
  AND TENLOT = 'Ba'
  AND TENNV = 'Tien';
