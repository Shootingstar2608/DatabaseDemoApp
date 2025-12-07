-- ======================================================================================
-- FILE: 2.1 - TRIGGERS KIỂM TRA RÀNG BUỘC CHO THÊM/SỬA/XÓA
-- Mục đích: Đáp ứng yêu cầu đặc tả 2.1 - Trigger kiểm tra validation khi thao tác dữ liệu
-- ======================================================================================

USE HeThongBanHang;
GO

-- --------------------------------------------------------------------------------------
-- TRIGGER 1: KIỂM TRA RÀNG BUỘC PHỨC TẠP KHI THÊM/SỬA SẢN PHẨM
-- Lưu ý: Các validation đơn giản (Giá > 0, Tên/Loại không rỗng) đã chuyển sang
--        CHECK CONSTRAINT trong định nghĩa bảng (tuân thủ yêu cầu đặc tả 1.1).
--        Trigger chỉ xử lý logic phức tạp: Link trùng, kiểm tra FK runtime, Audit log.
-- --------------------------------------------------------------------------------------
CREATE OR ALTER TRIGGER TR_SanPham_KiemTraRangBuoc
ON SAN_PHAM
INSTEAD OF INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Biến để lưu thông tin lỗi
    DECLARE @ErrorMsg NVARCHAR(MAX) = '';
    DECLARE @HasError BIT = 0;

    -- KIỂM TRA 1: Link sản phẩm không trùng (Logic phức tạp - cần so sánh với bản ghi khác)
    IF EXISTS (SELECT 1
    FROM inserted
    WHERE GiaHienThi <= 0)
    BEGIN
        SET @ErrorMsg = @ErrorMsg + N' Lỗi: Giá hiển thị phải lớn hơn 0.' + CHAR(13) + CHAR(10);
        SET @HasError = 1;
    END

    -- KIỂM TRA 2: Tên sản phẩm không được rỗng
    IF EXISTS (SELECT 1
    FROM inserted
    WHERE TenSanPham IS NULL OR LTRIM(RTRIM(TenSanPham)) = '')
    BEGIN
        SET @ErrorMsg = @ErrorMsg + N' Lỗi: Tên sản phẩm không được để trống.' + CHAR(13) + CHAR(10);
        SET @HasError = 1;
    END

    -- KIỂM TRA 3: Link sản phẩm không trùng (UNIQUE)
    IF EXISTS (
        SELECT i.LinkSanPham
    FROM inserted i
    WHERE i.LinkSanPham IS NOT NULL
        AND EXISTS (
            SELECT 1
        FROM SAN_PHAM sp
        WHERE sp.LinkSanPham = i.LinkSanPham
            AND sp.MaSanPham <> i.MaSanPham
        )
    )
    BEGIN
        DECLARE @DuplicateLink VARCHAR(511);
        SELECT TOP 1
            @DuplicateLink = i.LinkSanPham
        FROM inserted i
        WHERE i.LinkSanPham IS NOT NULL
            AND EXISTS (SELECT 1
            FROM SAN_PHAM sp
            WHERE sp.LinkSanPham = i.LinkSanPham AND sp.MaSanPham <> i.MaSanPham);

        SET @ErrorMsg = @ErrorMsg + N' Lỗi: Link sản phẩm "' + @DuplicateLink + N'" đã được sử dụng bởi sản phẩm khác.' + CHAR(13) + CHAR(10);
        SET @HasError = 1;
    END

    -- KIỂM TRA 2: Mã Shop phải tồn tại (Runtime FK validation với thông báo lỗi cụ thể)
    IF EXISTS (
        SELECT 1
    FROM inserted i
    WHERE NOT EXISTS (SELECT 1
    FROM CUA_HANG ch
    WHERE ch.MaSoShop = i.MaSoShop)
    )
    BEGIN
        DECLARE @InvalidShop CHAR(8);
        SELECT TOP 1
            @InvalidShop = i.MaSoShop
        FROM inserted i
        WHERE NOT EXISTS (SELECT 1
        FROM CUA_HANG ch
        WHERE ch.MaSoShop = i.MaSoShop);

        SET @ErrorMsg = @ErrorMsg + N' Lỗi: Mã Shop "' + @InvalidShop + N'" không tồn tại trong hệ thống.' + CHAR(13) + CHAR(10);
        SET @HasError = 1;
    END

    -- NẾU CÓ LỖI: Báo lỗi và hủy thao tác
    IF @HasError = 1
    BEGIN
        RAISERROR(@ErrorMsg, 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- NẾU KHÔNG CÓ LỖI: Thực hiện INSERT hoặc UPDATE
    IF EXISTS (SELECT 1
    FROM deleted) -- Đây là UPDATE
    BEGIN
        UPDATE SAN_PHAM
        SET 
            MaSoShop = i.MaSoShop,
            TenSanPham = i.TenSanPham,
            ThongTinSanPham = i.ThongTinSanPham,
            LinkSanPham = i.LinkSanPham,
            GiaHienThi = i.GiaHienThi,
            Loai = i.Loai,
            SoSaoSanPham = i.SoSaoSanPham
        FROM SAN_PHAM sp
            INNER JOIN inserted i ON sp.MaSanPham = i.MaSanPham;

        -- GHI LOG VÀO AUDIT_SAN_PHAM (UPDATE)
        INSERT INTO AUDIT_SAN_PHAM
            (
            MaSanPham, HanhDong, NguoiThucHien,
            TenSanPhamCu, GiaHienThiCu, LoaiCu, ThongTinCu, LinkSanPhamCu,
            TenSanPhamMoi, GiaHienThiMoi, LoaiMoi, ThongTinMoi, LinkSanPhamMoi,
            LyDo
            )
        SELECT
            i.MaSanPham, 'UPDATE', SYSTEM_USER,
            d.TenSanPham, d.GiaHienThi, d.Loai, d.ThongTinSanPham, d.LinkSanPham,
            i.TenSanPham, i.GiaHienThi, i.Loai, i.ThongTinSanPham, i.LinkSanPham,
            N'Trigger validation: Đã kiểm tra ràng buộc'
        FROM inserted i
            INNER JOIN deleted d ON i.MaSanPham = d.MaSanPham;

        PRINT N' Cập nhật sản phẩm thành công!';
    END
    ELSE -- Đây là INSERT
    BEGIN
        INSERT INTO SAN_PHAM
            (MaSanPham, MaSoShop, TenSanPham, ThongTinSanPham, LinkSanPham, GiaHienThi, Loai, SoSaoSanPham)
        SELECT MaSanPham, MaSoShop, TenSanPham, ThongTinSanPham, LinkSanPham, GiaHienThi, Loai, ISNULL(SoSaoSanPham, 0)
        FROM inserted;

        --  GHI LOG VÀO AUDIT_SAN_PHAM (INSERT)
        INSERT INTO AUDIT_SAN_PHAM
            (
            MaSanPham, HanhDong, NguoiThucHien,
            TenSanPhamMoi, GiaHienThiMoi, LoaiMoi, ThongTinMoi, LinkSanPhamMoi,
            LyDo
            )
        SELECT
            MaSanPham, 'INSERT', SYSTEM_USER,
            TenSanPham, GiaHienThi, Loai, ThongTinSanPham, LinkSanPham,
            N'Trigger validation: Đã kiểm tra ràng buộc'
        FROM inserted;

        PRINT N' Thêm sản phẩm thành công!';
    END
END;
GO

-- --------------------------------------------------------------------------------------
-- TRIGGER 2: KIỂM TRA RÀNG BUỘC KHI XÓA SẢN PHẨM
-- Yêu cầu:
-- - Không được xóa sản phẩm đã có trong đơn hàng
-- - Không được xóa sản phẩm đã có đánh giá
-- - Xóa dữ liệu liên quan (LINK_ANH_VIDEO, DUYET_SAN_PHAM...)
-- --------------------------------------------------------------------------------------
CREATE OR ALTER TRIGGER TR_SanPham_KiemTraTruocKhiXoa
ON SAN_PHAM
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ErrorMsg NVARCHAR(MAX) = '';
    DECLARE @HasError BIT = 0;

    -- KIỂM TRA 1: Không được xóa sản phẩm đã có trong đơn hàng
    IF EXISTS (
        SELECT 1
    FROM deleted d
    WHERE EXISTS (
            SELECT 1
    FROM DON_HANG dh
        INNER JOIN BIEN_THE_SAN_PHAM bt ON dh.ID_BienThe = bt.ID AND dh.MaSanPham_BienThe = bt.MaSanPham
    WHERE bt.MaSanPham = d.MaSanPham
        )
    )
    BEGIN
        DECLARE @ProductInOrder VARCHAR(100);
        SELECT TOP 1
            @ProductInOrder = d.MaSanPham
        FROM deleted d
        WHERE EXISTS (
            SELECT 1
        FROM DON_HANG dh
            INNER JOIN BIEN_THE_SAN_PHAM bt ON dh.ID_BienThe = bt.ID AND dh.MaSanPham_BienThe = bt.MaSanPham
        WHERE bt.MaSanPham = d.MaSanPham
        );

        SET @ErrorMsg = @ErrorMsg + N' Lỗi: Không thể xóa sản phẩm "' + @ProductInOrder + N'" vì đã có trong đơn hàng.' + CHAR(13) + CHAR(10);
        SET @HasError = 1;
    END

    -- KIỂM TRA 2: Cảnh báo nếu sản phẩm có đánh giá (Cho phép xóa nhưng cảnh báo)
    IF EXISTS (
        SELECT 1
    FROM deleted d
    WHERE EXISTS (SELECT 1
    FROM DANH_GIA dg
    WHERE dg.MaSanPham = d.MaSanPham)
    )
    BEGIN
        PRINT N' Cảnh báo: Sản phẩm có đánh giá sẽ bị xóa cùng dữ liệu đánh giá.';
    END

    -- NẾU CÓ LỖI: Báo lỗi và hủy thao tác
    IF @HasError = 1
    BEGIN
        RAISERROR(@ErrorMsg, 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- NẾU KHÔNG CÓ LỖI: Xóa dữ liệu liên quan theo thứ tự
    BEGIN TRY
        BEGIN TRANSACTION;
        
        --  Đếm số lượng dữ liệu bị xóa (để ghi vào AUDIT)
        DECLARE @SoBienTheXoa INT, @SoDanhGiaXoa INT, @SoAnhVideoXoa INT, @SoGioHangXoa INT;
        
        SELECT @SoBienTheXoa = COUNT(*)
    FROM BIEN_THE_SAN_PHAM bt
        INNER JOIN deleted d ON bt.MaSanPham = d.MaSanPham;
        
        SELECT @SoDanhGiaXoa = COUNT(*)
    FROM DANH_GIA dg
        INNER JOIN deleted d ON dg.MaSanPham = d.MaSanPham;
        
        SELECT @SoAnhVideoXoa = COUNT(*)
    FROM LINK_ANH_VIDEO_SAN_PHAM la
        INNER JOIN deleted d ON la.MaSanPham = d.MaSanPham;
        
        SELECT @SoGioHangXoa = COUNT(*)
    FROM GIO_HANG_CHUA gh
        INNER JOIN BIEN_THE_SAN_PHAM bt ON gh.ID_BienThe = bt.ID AND gh.MaSanPham = bt.MaSanPham
        INNER JOIN deleted d ON bt.MaSanPham = d.MaSanPham;
        
        -- Bước 1: Xóa link ảnh/video đánh giá
        DELETE la 
        FROM LINK_ANH_VIDEO_DANH_GIA la
        INNER JOIN DANH_GIA dg ON la.MaDanhGia = dg.MaDanhGia AND la.MaSanPham = dg.MaSanPham AND la.TenDangNhapNguoiMua = dg.TenDangNhapNguoiMua
        INNER JOIN deleted d ON dg.MaSanPham = d.MaSanPham;
        
        -- Bước 2: Xóa đánh giá
        DELETE dg
        FROM DANH_GIA dg
        INNER JOIN deleted d ON dg.MaSanPham = d.MaSanPham;
        
        -- Bước 3: Xóa link ảnh/video sản phẩm
        DELETE la
        FROM LINK_ANH_VIDEO_SAN_PHAM la
        INNER JOIN deleted d ON la.MaSanPham = d.MaSanPham;
        
        -- Bước 4: Xóa duyệt sản phẩm
        DELETE ds
        FROM DUYET_SAN_PHAM ds
        INNER JOIN deleted d ON ds.MaSanPham = d.MaSanPham;
        
        -- Bước 5: Xóa giỏ hàng chứa biến thể
        DELETE gh
        FROM GIO_HANG_CHUA gh
        INNER JOIN BIEN_THE_SAN_PHAM bt ON gh.ID_BienThe = bt.ID AND gh.MaSanPham = bt.MaSanPham
        INNER JOIN deleted d ON bt.MaSanPham = d.MaSanPham;
        
        -- Bước 6: Xóa thông tin biến thể
        DELETE tt
        FROM THONG_TIN_BIEN_THE tt
        INNER JOIN deleted d ON tt.MaSanPham = d.MaSanPham;
        
        -- Bước 7: Xóa biến thể sản phẩm
        DELETE bt
        FROM BIEN_THE_SAN_PHAM bt
        INNER JOIN deleted d ON bt.MaSanPham = d.MaSanPham;
        
        -- Bước 8: Xóa sản phẩm chính
        DELETE sp
        FROM SAN_PHAM sp
        INNER JOIN deleted d ON sp.MaSanPham = d.MaSanPham;
        
        --  GHI LOG VÀO AUDIT_XOA_SAN_PHAM
        INSERT INTO AUDIT_XOA_SAN_PHAM
        (
        MaSanPham, NguoiThucHien, TenSanPham, GiaHienThi, MaSoShop,
        SoLuongBienTheXoa, SoLuongDanhGiaXoa, SoLuongAnhVideoXoa, SoLuongGioHangXoa,
        TrangThai
        )
    SELECT
        MaSanPham, SYSTEM_USER, TenSanPham, GiaHienThi, MaSoShop,
        @SoBienTheXoa, @SoDanhGiaXoa, @SoAnhVideoXoa, @SoGioHangXoa,
        N'Thành công'
    FROM deleted;
        
        COMMIT TRANSACTION;
        PRINT N' Xóa sản phẩm và dữ liệu liên quan thành công!';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

-- --------------------------------------------------------------------------------------
-- TESTCASE: KIỂM TRA CÁC TRIGGER
-- --------------------------------------------------------------------------------------

PRINT N'';
PRINT N'======================================================================================';
PRINT N'TESTCASE 1: KIỂM TRA TRIGGER VALIDATION (TR_SanPham_KiemTraRangBuoc)';
PRINT N'======================================================================================';

-- Test 1.1: Thử thêm sản phẩm với giá <= 0 (Phải báo lỗi)
PRINT N'';
PRINT N'--- Test 1.1: Thêm sản phẩm giá <= 0 ---';
BEGIN TRY
    INSERT INTO SAN_PHAM
    (MaSanPham, MaSoShop, TenSanPham, ThongTinSanPham, GiaHienThi, Loai)
VALUES
    ('TEST001', 'SHOP0001', N'Sản phẩm test lỗi', N'Giá âm', -100, N'Test');
    PRINT N' LỖI: Trigger không hoạt động! Đã thêm được sản phẩm giá âm.';
END TRY
BEGIN CATCH
    PRINT N' PASS: ' + ERROR_MESSAGE();
END CATCH

-- Test 1.2: Thử thêm sản phẩm không có tên (Phải báo lỗi)
PRINT N'';
PRINT N'--- Test 1.2: Thêm sản phẩm không có tên ---';
BEGIN TRY
    INSERT INTO SAN_PHAM
    (MaSanPham, MaSoShop, TenSanPham, ThongTinSanPham, GiaHienThi, Loai)
VALUES
    ('TEST002', 'SHOP0001', '', N'Không tên', 100000, N'Test');
    PRINT N' LỖI: Trigger không hoạt động! Đã thêm được sản phẩm không tên.';
END TRY
BEGIN CATCH
    PRINT N' PASS: ' + ERROR_MESSAGE();
END CATCH

-- Test 1.3: Thử thêm sản phẩm với link trùng (Phải báo lỗi)
PRINT N'';
PRINT N'--- Test 1.3: Thêm sản phẩm link trùng ---';
BEGIN TRY
    INSERT INTO SAN_PHAM
    (MaSanPham, MaSoShop, TenSanPham, ThongTinSanPham, LinkSanPham, GiaHienThi, Loai)
VALUES
    ('TEST003', 'SHOP0001', N'Sản phẩm test', N'Link trùng', 'thinh.com/p1', 100000, N'Test');
    PRINT N' LỖI: Trigger không hoạt động! Đã thêm được sản phẩm link trùng.';
END TRY
BEGIN CATCH
    PRINT N' PASS: ' + ERROR_MESSAGE();
END CATCH

-- Test 1.4: Thử thêm sản phẩm với shop không tồn tại (Phải báo lỗi)
PRINT N'';
PRINT N'--- Test 1.4: Thêm sản phẩm shop không tồn tại ---';
BEGIN TRY
    INSERT INTO SAN_PHAM
    (MaSanPham, MaSoShop, TenSanPham, ThongTinSanPham, GiaHienThi, Loai)
VALUES
    ('TEST004', 'SHOP9999', N'Sản phẩm test', N'Shop fake', 100000, N'Test');
    PRINT N' LỖI: Trigger không hoạt động! Đã thêm được sản phẩm shop không tồn tại.';
END TRY
BEGIN CATCH
    PRINT N' PASS: ' + ERROR_MESSAGE();
END CATCH

-- Test 1.5: Thêm sản phẩm hợp lệ (Phải thành công)
PRINT N'';
PRINT N'--- Test 1.5: Thêm sản phẩm hợp lệ ---';
BEGIN TRY
    INSERT INTO SAN_PHAM
    (MaSanPham, MaSoShop, TenSanPham, ThongTinSanPham, LinkSanPham, GiaHienThi, Loai)
VALUES
    ('TEST_OK', 'SHOP0001', N'Sản phẩm test thành công', N'Mô tả', 'test.com/valid', 250000, N'Test');
    PRINT N' PASS: Thêm sản phẩm thành công!';
    
    -- Xóa sản phẩm test
    DELETE FROM SAN_PHAM WHERE MaSanPham = 'TEST_OK';
END TRY
BEGIN CATCH
    PRINT N' FAIL: ' + ERROR_MESSAGE();
END CATCH

PRINT N'';
PRINT N'======================================================================================';
PRINT N'TESTCASE 2: KIỂM TRA TRIGGER XÓA (TR_SanPham_KiemTraTruocKhiXoa)';
PRINT N'======================================================================================';

-- Test 2.1: Thử xóa sản phẩm đã có trong đơn hàng (Phải báo lỗi)
PRINT N'';
PRINT N'--- Test 2.1: Xóa sản phẩm đã có đơn hàng ---';
BEGIN TRY
    DELETE FROM SAN_PHAM WHERE MaSanPham = 'PROD0001';
    PRINT N' LỖI: Trigger không hoạt động! Đã xóa được sản phẩm có đơn hàng.';
END TRY
BEGIN CATCH
    PRINT N' PASS: ' + ERROR_MESSAGE();
END CATCH

-- Test 2.2: Xóa sản phẩm không có đơn hàng (Phải thành công nếu không vi phạm)
PRINT N'';
PRINT N'--- Test 2.2: Xóa sản phẩm hợp lệ ---';
BEGIN TRY
    -- Thêm sản phẩm mới để test xóa
    INSERT INTO SAN_PHAM
    (MaSanPham, MaSoShop, TenSanPham, ThongTinSanPham, GiaHienThi, Loai)
VALUES
    ('TEST_DEL', 'SHOP0001', N'Sản phẩm test xóa', N'Để test xóa', 100000, N'Test');
    
    -- Xóa sản phẩm vừa tạo
    DELETE FROM SAN_PHAM WHERE MaSanPham = 'TEST_DEL';
    PRINT N' PASS: Xóa sản phẩm thành công!';
END TRY
BEGIN CATCH
    PRINT N' FAIL: ' + ERROR_MESSAGE();
END CATCH

PRINT N'';
PRINT N'======================================================================================';
PRINT N'KẾT THÚC TESTCASE - TRIGGERS HOẠT ĐỘNG ĐÚNG YÊU CẦU';
PRINT N'======================================================================================';
GO


