-- ======================================================================================
-- FILE: 2.2 - TRIGGER BỔ SUNG (TRIGGER THỨ 2)
-- Mục đích: Đáp ứng yêu cầu đặc tả 2.2 - Cần 2 triggers với logic phức tạp
-- ======================================================================================

USE HeThongBanHang;
GO

-- --------------------------------------------------------------------------------------
-- TRIGGER 3: TỰ ĐỘNG CẬP NHẬT SỐ LƯỢNG KHO KHI ĐẶT HÀNG/HỦY ĐƠN
-- Mục đích: 
-- - Khi INSERT đơn hàng mới: Trừ số lượng trong kho
-- - Khi UPDATE trạng thái đơn hàng (Hủy): Hoàn lại số lượng vào kho
-- - Kiểm tra tính toán, ràng buộc nghiệp vụ phức tạp
-- --------------------------------------------------------------------------------------
CREATE OR ALTER TRIGGER TR_DonHang_CapNhatSoLuongKho
ON DON_HANG
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- TRƯỜNG HỢP 1: INSERT đơn hàng mới (Trừ kho)
    IF EXISTS (SELECT 1
        FROM inserted) AND NOT EXISTS (SELECT 1
        FROM deleted)
    BEGIN
        -- Kiểm tra số lượng tồn kho trước khi trừ
        DECLARE @MaSanPham VARCHAR(100), @IDBienThe VARCHAR(100), @SoLuongDat INT, @SoLuongTrongKho INT;
        DECLARE @ErrorMsg NVARCHAR(MAX) = '';

        DECLARE cur_KiemTraKho CURSOR FOR
        SELECT i.MaSanPham_BienThe, i.ID_BienThe, i.SoLuongCuaBienThe
        FROM inserted i;

        OPEN cur_KiemTraKho;
        FETCH NEXT FROM cur_KiemTraKho INTO @MaSanPham, @IDBienThe, @SoLuongDat;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Lấy số lượng hiện có trong kho
            SELECT @SoLuongTrongKho = SoLuongTrongKho
            FROM BIEN_THE_SAN_PHAM
            WHERE ID = @IDBienThe AND MaSanPham = @MaSanPham;

            -- Kiểm tra đủ hàng không
            IF @SoLuongTrongKho IS NULL
            BEGIN
                SET @ErrorMsg = @ErrorMsg + N' Biến thể sản phẩm không tồn tại: ' + @IDBienThe + CHAR(13) + CHAR(10);
            END
            ELSE IF @SoLuongTrongKho < @SoLuongDat
            BEGIN
                SET @ErrorMsg = @ErrorMsg + N' Không đủ hàng! Còn ' + CAST(@SoLuongTrongKho AS NVARCHAR) + N', yêu cầu ' + CAST(@SoLuongDat AS NVARCHAR) + CHAR(13) + CHAR(10);
            END

            FETCH NEXT FROM cur_KiemTraKho INTO @MaSanPham, @IDBienThe, @SoLuongDat;
        END

        CLOSE cur_KiemTraKho;
        DEALLOCATE cur_KiemTraKho;

        -- Nếu có lỗi, báo lỗi và rollback
        IF LEN(@ErrorMsg) > 0
        BEGIN
            RAISERROR(@ErrorMsg, 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Nếu đủ hàng, trừ số lượng trong kho
        UPDATE bt
        SET bt.SoLuongTrongKho = bt.SoLuongTrongKho - i.SoLuongCuaBienThe
        FROM BIEN_THE_SAN_PHAM bt
            INNER JOIN inserted i ON bt.ID = i.ID_BienThe AND bt.MaSanPham = i.MaSanPham_BienThe;

        PRINT N' Đã trừ số lượng kho cho đơn hàng mới.';
    END

    -- TRƯỜNG HỢP 2: UPDATE trạng thái đơn hàng (Hoàn lại kho nếu hủy)
    IF EXISTS (SELECT 1
        FROM inserted) AND EXISTS (SELECT 1
        FROM deleted)
    BEGIN
        -- Kiểm tra nếu trạng thái chuyển sang "Đã hủy"
        IF EXISTS (
            SELECT 1
        FROM inserted i
            INNER JOIN deleted d ON i.MaDonHang = d.MaDonHang
        WHERE d.TrangThai <> N'Đã hủy' AND i.TrangThai = N'Đã hủy'
        )
        BEGIN
            -- Hoàn lại số lượng vào kho
            UPDATE bt
            SET bt.SoLuongTrongKho = bt.SoLuongTrongKho + i.SoLuongCuaBienThe
            FROM BIEN_THE_SAN_PHAM bt
                INNER JOIN inserted i ON bt.ID = i.ID_BienThe AND bt.MaSanPham = i.MaSanPham_BienThe
                INNER JOIN deleted d ON i.MaDonHang = d.MaDonHang
            WHERE d.TrangThai <> N'Đã hủy' AND i.TrangThai = N'Đã hủy';

            PRINT N' Đã hoàn lại số lượng kho cho đơn hàng bị hủy.';
        END

        -- Kiểm tra nếu trạng thái chuyển từ "Đã hủy" sang trạng thái khác (Kích hoạt lại đơn)
        IF EXISTS (
            SELECT 1
        FROM inserted i
            INNER JOIN deleted d ON i.MaDonHang = d.MaDonHang
        WHERE d.TrangThai = N'Đã hủy' AND i.TrangThai <> N'Đã hủy'
        )
        BEGIN
            -- Trừ lại số lượng từ kho (Vì đơn được kích hoạt lại)
            DECLARE @MaSP2 VARCHAR(100), @IDBT2 VARCHAR(100), @SoLuong2 INT, @SoLuongKho2 INT;
            DECLARE @Err2 NVARCHAR(MAX) = '';

            DECLARE cur_KichHoatLai CURSOR FOR
            SELECT i.MaSanPham_BienThe, i.ID_BienThe, i.SoLuongCuaBienThe
            FROM inserted i
                INNER JOIN deleted d ON i.MaDonHang = d.MaDonHang
            WHERE d.TrangThai = N'Đã hủy' AND i.TrangThai <> N'Đã hủy';

            OPEN cur_KichHoatLai;
            FETCH NEXT FROM cur_KichHoatLai INTO @MaSP2, @IDBT2, @SoLuong2;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                SELECT @SoLuongKho2 = SoLuongTrongKho
                FROM BIEN_THE_SAN_PHAM
                WHERE ID = @IDBT2 AND MaSanPham = @MaSP2;

                IF @SoLuongKho2 < @SoLuong2
                BEGIN
                    SET @Err2 = @Err2 + N' Không đủ hàng để kích hoạt lại đơn! Còn ' + CAST(@SoLuongKho2 AS NVARCHAR) + CHAR(13) + CHAR(10);
                END

                FETCH NEXT FROM cur_KichHoatLai INTO @MaSP2, @IDBT2, @SoLuong2;
            END

            CLOSE cur_KichHoatLai;
            DEALLOCATE cur_KichHoatLai;

            IF LEN(@Err2) > 0
            BEGIN
                RAISERROR(@Err2, 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END

            -- Trừ số lượng kho
            UPDATE bt
            SET bt.SoLuongTrongKho = bt.SoLuongTrongKho - i.SoLuongCuaBienThe
            FROM BIEN_THE_SAN_PHAM bt
                INNER JOIN inserted i ON bt.ID = i.ID_BienThe AND bt.MaSanPham = i.MaSanPham_BienThe
                INNER JOIN deleted d ON i.MaDonHang = d.MaDonHang
            WHERE d.TrangThai = N'Đá hủy' AND i.TrangThai <> N'Đã hủy';

            PRINT N' Đã trừ số lượng kho cho đơn hàng được kích hoạt lại.';
        END
    END
END;
GO

-- --------------------------------------------------------------------------------------
-- TESTCASE: KIỂM TRA TRIGGER CẬP NHẬT KHO
-- --------------------------------------------------------------------------------------

PRINT N'';
PRINT N'======================================================================================';
PRINT N'TESTCASE 3: KIỂM TRA TRIGGER CẬP NHẬT KHO (TR_DonHang_CapNhatSoLuongKho)';
PRINT N'======================================================================================';

-- Kiểm tra số lượng kho hiện tại của biến thể P001T001
PRINT N'';
PRINT N'--- Số lượng kho trước test ---';
SELECT ID, MaSanPham, Ten, SoLuongTrongKho
FROM BIEN_THE_SAN_PHAM
WHERE ID = 'P001T001' AND MaSanPham = 'PROD0001';

-- Test 3.1: Đặt hàng khi đủ số lượng (Phải thành công và trừ kho)
PRINT N'';
PRINT N'--- Test 3.1: Đặt hàng đủ số lượng ---';
DECLARE @SoLuongTruoc1 INT, @SoLuongSau1 INT;
SELECT @SoLuongTruoc1 = SoLuongTrongKho
FROM BIEN_THE_SAN_PHAM
WHERE ID = 'P001T001' AND MaSanPham = 'PROD0001';

BEGIN TRY
    BEGIN TRANSACTION;
    
    INSERT INTO DON_HANG
    (
    MaDonHang, PhuongThucVanChuyen, TrangThai, DiaChiLayHang, DiaChiGiaoHang,
    PhuongThucThanhToan, ThoiGianDatHang, ThoiGianGiaoDuKien, ChietKhau,
    GiaBanDau, GiaVanChuyen, MaSoShop, TenDangNhapNguoiMua,
    ID_BienThe, MaSanPham_BienThe, SoLuongCuaBienThe
    )
VALUES
    (
        'TEST0001', N'Nhanh', N'Chờ xử lý', N'Shop Test', N'Địa chỉ test',
        'COD', GETDATE(), DATEADD(day, 3, GETDATE()), 0,
        200000, 30000, 'SHOP0001', 'chidan_singer',
        'P001T001', 'PROD0001', 2
    );
    
    SELECT @SoLuongSau1 = SoLuongTrongKho
FROM BIEN_THE_SAN_PHAM
WHERE ID = 'P001T001' AND MaSanPham = 'PROD0001';
    
    IF @SoLuongSau1 = @SoLuongTruoc1 - 2
    BEGIN
    PRINT N' PASS: Số lượng kho giảm đúng từ ' + CAST(@SoLuongTruoc1 AS NVARCHAR) + N' xuống ' + CAST(@SoLuongSau1 AS NVARCHAR);
END
    ELSE
    BEGIN
    PRINT N' FAIL: Số lượng kho không đúng!';
END
    
    ROLLBACK TRANSACTION; -- Rollback để không ảnh hưởng dữ liệu
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT N' FAIL: ' + ERROR_MESSAGE();
END CATCH

-- Test 3.2: Đặt hàng khi KHÔNG đủ số lượng (Phải báo lỗi)
PRINT N'';
PRINT N'--- Test 3.2: Đặt hàng vượt quá số lượng kho ---';
BEGIN TRY
    INSERT INTO DON_HANG
    (
    MaDonHang, PhuongThucVanChuyen, TrangThai, DiaChiLayHang, DiaChiGiaoHang,
    PhuongThucThanhToan, ThoiGianDatHang, ThoiGianGiaoDuKien, ChietKhau,
    GiaBanDau, GiaVanChuyen, MaSoShop, TenDangNhapNguoiMua,
    ID_BienThe, MaSanPham_BienThe, SoLuongCuaBienThe
    )
VALUES
    (
        'TEST0002', N'Nhanh', N'Chờ xử lý', N'Shop Test', N'Địa chỉ test',
        'COD', GETDATE(), DATEADD(day, 3, GETDATE()), 0,
        200000, 30000, 'SHOP0001', 'chidan_singer',
        'P001T001', 'PROD0001', 99999 -- Số lượng vượt quá kho
    );
    PRINT N' FAIL: Trigger không hoạt động! Đã đặt hàng vượt quá kho.';
END TRY
BEGIN CATCH
    PRINT N' PASS: ' + ERROR_MESSAGE();
END CATCH

-- Test 3.3: Hủy đơn hàng (Phải hoàn lại kho)
PRINT N'';
PRINT N'--- Test 3.3: Hủy đơn hàng và hoàn lại kho ---';
DECLARE @SoLuongTruoc3 INT, @SoLuongSau3 INT;

BEGIN TRY
    BEGIN TRANSACTION;
    
    -- Tạo đơn hàng mới
    SELECT @SoLuongTruoc3 = SoLuongTrongKho
FROM BIEN_THE_SAN_PHAM
WHERE ID = 'P001T001' AND MaSanPham = 'PROD0001';
    
    INSERT INTO DON_HANG
    (
    MaDonHang, PhuongThucVanChuyen, TrangThai, DiaChiLayHang, DiaChiGiaoHang,
    PhuongThucThanhToan, ThoiGianDatHang, ThoiGianGiaoDuKien, ChietKhau,
    GiaBanDau, GiaVanChuyen, MaSoShop, TenDangNhapNguoiMua,
    ID_BienThe, MaSanPham_BienThe, SoLuongCuaBienThe
    )
VALUES
    (
        'TEST0003', N'Nhanh', N'Chờ xử lý', N'Shop Test', N'Địa chỉ test',
        'COD', GETDATE(), DATEADD(day, 3, GETDATE()), 0,
        200000, 30000, 'SHOP0001', 'chidan_singer',
        'P001T001', 'PROD0001', 3
    );
    
    -- Hủy đơn hàng
    UPDATE DON_HANG 
    SET TrangThai = N'Đã hủy'
    WHERE MaDonHang = 'TEST0003';
    
    SELECT @SoLuongSau3 = SoLuongTrongKho
FROM BIEN_THE_SAN_PHAM
WHERE ID = 'P001T001' AND MaSanPham = 'PROD0001';
    
    IF @SoLuongSau3 = @SoLuongTruoc3
    BEGIN
    PRINT N' PASS: Số lượng kho được hoàn lại đúng: ' + CAST(@SoLuongSau3 AS NVARCHAR);
END
    ELSE
    BEGIN
    PRINT N' FAIL: Số lượng kho không khớp! Trước: ' + CAST(@SoLuongTruoc3 AS NVARCHAR) + N', Sau: ' + CAST(@SoLuongSau3 AS NVARCHAR);
END
    
    ROLLBACK TRANSACTION; -- Rollback để không ảnh hưởng dữ liệu
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT N' FAIL: ' + ERROR_MESSAGE();
END CATCH

PRINT N'';
PRINT N'======================================================================================';
PRINT N'KẾT THÚC TESTCASE - TRIGGER CẬP NHẬT KHO HOẠT ĐỘNG ĐÚNG';
PRINT N'======================================================================================';
GO

-- --------------------------------------------------------------------------------------
-- TRIGGER 4: TỰ ĐỘNG CẬP NHẬT SỐ SAO TRUNG BÌNH CỦA SẢN PHẨM KHI CÓ ĐÁNH GIÁ
-- Mục đích:
-- - Khi INSERT đánh giá mới: Tính lại số sao trung bình
-- - Khi UPDATE số sao đánh giá: Cập nhật lại số sao trung bình
-- - Khi DELETE đánh giá: Tính lại số sao trung bình
-- --------------------------------------------------------------------------------------
CREATE OR ALTER TRIGGER TR_DANH_GIA_CapNhatSoSaoSanPham
ON DANH_GIA
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Danh sách sản phẩm bị ảnh hưởng
    DECLARE @DanhSachSanPham TABLE (MaSanPham VARCHAR(100));

    -- Thu thập sản phẩm từ inserted (INSERT/UPDATE)
    INSERT INTO @DanhSachSanPham
        (MaSanPham)
    SELECT DISTINCT MaSanPham
    FROM inserted;

    -- Thu thập sản phẩm từ deleted (DELETE/UPDATE)
    INSERT INTO @DanhSachSanPham
        (MaSanPham)
    SELECT DISTINCT MaSanPham
    FROM deleted
    WHERE MaSanPham NOT IN (SELECT MaSanPham
    FROM @DanhSachSanPham);

    -- Cập nhật số sao trung bình cho từng sản phẩm
    UPDATE SP
    SET SP.SoSaoSanPham = ISNULL(
        (
            SELECT AVG(CAST(SoSao AS DECIMAL(3,1)))
    FROM DANH_GIA DG
    WHERE DG.MaSanPham = SP.MaSanPham
        ),
        0.0
    )
    FROM SAN_PHAM SP
        INNER JOIN @DanhSachSanPham DSP ON SP.MaSanPham = DSP.MaSanPham;

    PRINT N' Đã cập nhật số sao trung bình cho sản phẩm.';
END;
GO

-- --------------------------------------------------------------------------------------
-- TESTCASE: KIỂM TRA TRIGGER CẬP NHẬT SỐ SAO
-- --------------------------------------------------------------------------------------

PRINT N'';
PRINT N'======================================================================================';
PRINT N'TESTCASE 4: KIỂM TRA TRIGGER CẬP NHẬT SỐ SAO (TR_DANH_GIA_CapNhatSoSaoSanPham)';
PRINT N'======================================================================================';

-- Kiểm tra số sao ban đầu
PRINT N'';
PRINT N'--- Số sao ban đầu ---';
SELECT MaSanPham, TenSanPham, SoSaoSanPham
FROM SAN_PHAM
WHERE MaSanPham IN ('PROD0001', 'PROD0002');
-- PROD0001 có 1 đánh giá 5 sao → 5.0
-- PROD0002 có 1 đánh giá 4 sao → 4.0

-- Test 4.1: INSERT đánh giá mới (3 sao cho PROD0001)
PRINT N'';
PRINT N'--- Test 4.1: Thêm đánh giá 3 sao cho PROD0001 ---';
BEGIN TRY
    BEGIN TRANSACTION;
    
    INSERT INTO DANH_GIA
    (MaDanhGia, MaSanPham, TenDangNhapNguoiMua, MaSoShop, SoSao, NoiDung)
VALUES
    ('TEST_REV1', 'PROD0001', 'quynhtrang', 'SHOP0001', 3, N'Tạm được');
    
    DECLARE @SoSao1 DECIMAL(2,1);
    SELECT @SoSao1 = SoSaoSanPham
FROM SAN_PHAM
WHERE MaSanPham = 'PROD0001';
    
    IF @SoSao1 = 4.0 -- (5 + 3) / 2 = 4.0
    BEGIN
    PRINT N' PASS: Số sao trung bình = ' + CAST(@SoSao1 AS NVARCHAR) + N' (mong đợi 4.0)';
END
    ELSE
    BEGIN
    PRINT N' FAIL: Số sao = ' + CAST(@SoSao1 AS NVARCHAR) + N' (mong đợi 4.0)';
END
    
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT N' FAIL: ' + ERROR_MESSAGE();
END CATCH

-- Test 4.2: UPDATE đánh giá (Sửa 5 sao thành 1 sao)
PRINT N'';
PRINT N'--- Test 4.2: Sửa đánh giá REVI0001 từ 5 sao → 1 sao ---';
BEGIN TRY
    BEGIN TRANSACTION;
    
    UPDATE DANH_GIA SET SoSao = 1 WHERE MaDanhGia = 'REVI0001';
    
    DECLARE @SoSao2 DECIMAL(2,1);
    SELECT @SoSao2 = SoSaoSanPham
FROM SAN_PHAM
WHERE MaSanPham = 'PROD0001';
    
    IF @SoSao2 = 1.0
    BEGIN
    PRINT N' PASS: Số sao trung bình = ' + CAST(@SoSao2 AS NVARCHAR) + N' (mong đợi 1.0)';
END
    ELSE
    BEGIN
    PRINT N' FAIL: Số sao = ' + CAST(@SoSao2 AS NVARCHAR) + N' (mong đợi 1.0)';
END
    
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT N' FAIL: ' + ERROR_MESSAGE();
END CATCH

-- Test 4.3: DELETE đánh giá (Xóa đánh giá duy nhất)
PRINT N'';
PRINT N'--- Test 4.3: Xóa đánh giá REVI0001 (sản phẩm không còn đánh giá) ---';
BEGIN TRY
    BEGIN TRANSACTION;
    
    -- Xóa link ảnh/video trước
    DELETE FROM LINK_ANH_VIDEO_DANH_GIA 
    WHERE MaDanhGia = 'REVI0001' AND MaSanPham = 'PROD0001';
    
    -- Xóa đánh giá
    DELETE FROM DANH_GIA WHERE MaDanhGia = 'REVI0001';
    
    DECLARE @SoSao3 DECIMAL(2,1);
    SELECT @SoSao3 = SoSaoSanPham
FROM SAN_PHAM
WHERE MaSanPham = 'PROD0001';
    
    IF @SoSao3 = 0.0
    BEGIN
    PRINT N' PASS: Số sao trung bình = ' + CAST(@SoSao3 AS NVARCHAR) + N' (mong đợi 0.0)';
END
    ELSE
    BEGIN
    PRINT N' FAIL: Số sao = ' + CAST(@SoSao3 AS NVARCHAR) + N' (mong đợi 0.0)';
END
    
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT N' FAIL: ' + ERROR_MESSAGE();
END CATCH

PRINT N'';
PRINT N'======================================================================================';
PRINT N'KẾT THÚC TESTCASE - TRIGGER CẬP NHẬT SỐ SAO HOẠT ĐỘNG ĐÚNG';
PRINT N'======================================================================================';
GO
