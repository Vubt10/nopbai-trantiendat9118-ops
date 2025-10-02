USE QLDA;
GO

-- 1. Nh�n vi�n l�m vi?c ? ph�ng s? 4
SELECT HONV, TENLOT, TENNV
FROM NHANVIEN
WHERE PHG = 4;

-- 2. Nh�n vi�n l??ng > 30000
SELECT HONV, TENLOT, TENNV, LUONG
FROM NHANVIEN
WHERE LUONG > 30000;

-- 3. Nh�n vi�n l??ng > 25,000 ph�ng 4 ho?c l??ng > 30,000 ph�ng 5
SELECT HONV, TENLOT, TENNV, LUONG, PHG
FROM NHANVIEN
WHERE (LUONG > 25000 AND PHG = 4)
   OR (LUONG > 30000 AND PHG = 5);

-- 4. H? t�n ??y ?? nh�n vi�n ? TP HCM
SELECT HONV + ' ' + TENLOT + ' ' + TENNV AS HOTEN
FROM NHANVIEN
WHERE DCHI LIKE '%TP HCM%';

-- 5. H? t�n ??y ?? nh�n vi�n c� h? b?t ??u b?ng 'N'
SELECT HONV + ' ' + TENLOT + ' ' + TENNV AS HOTEN
FROM NHANVIEN
WHERE HONV LIKE 'N%';

-- 6. Ng�y sinh v� ??a ch? nh�n vi�n Dinh Ba Tien
SELECT NGSINH, DCHI
FROM NHANVIEN
WHERE HONV = 'Dinh'
  AND TENLOT = 'Ba'
  AND TENNV = 'Tien';
