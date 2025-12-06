USE HeThongBanHang;
GO

-- ======================================================================================
-- FILE TỔNG HỢP CÁC FUNCTION VÀ STORED PROCEDURE (UPDATED V2)
-- Cập nhật: Ưu tiên trừ Chiết Khấu (%) của đơn hàng vào Giá Gốc trước khi tính Voucher.
-- ======================================================================================

-- --------------------------------------------------------------------------------------
-- 1. FUNCTION: LẤY DANH SÁCH VOUCHER KHẢ DỤNG (GỢI Ý)
-- --------------------------------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_LayVoucherKhaDung
(
    @MaDonHang CHAR(8),
    @MaVoucherShop CHAR(8) = NULL,
    @MaVoucherAdmin CHAR(8) = NULL,
    @MaVoucherTransport CHAR(8) = NULL
)
RETURNS @KetQua TABLE
(
    STT INT IDENTITY(1,1),
    MaVoucher CHAR(8),
    TenVoucher NVARCHAR(50),
    LoaiVoucher NVARCHAR(20),
    MoTaGiamGia NVARCHAR(255),
    SoTienGiam INT,
    DieuKienApDung NVARCHAR(500),
    TrangThaiApDung NVARCHAR(50),
    GiaApDung DECIMAL(18,2),
    GiaSauGiam DECIMAL(18,2),
    TongDonHangSauVoucher DECIMAL(18,2),
    ChuThich NVARCHAR(500),
    CoTheApDung BIT,
    LyDoKhongApDung NVARCHAR(500)
)
AS
BEGIN
    DECLARE @MaSoShop CHAR(8);
    DECLARE @GiaBanDau INT; -- Giá gốc từ DB
    DECLARE @ChietKhau INT; -- % Chiết khấu từ DB
    DECLARE @GiaSauChietKhau INT; -- Giá sau khi trừ chiết khấu (Dùng để tính Voucher)
    DECLARE @GiaVanChuyen INT;
    DECLARE @MaSanPham VARCHAR(100);
    
    -- 1. LẤY THÔNG TIN ĐƠN HÀNG & CHIẾT KHẤU
    SELECT @MaSoShop = MaSoShop, 
           @GiaBanDau = GiaBanDau, 
           @ChietKhau = ISNULL(ChietKhau, 0), -- Lấy chiết khấu, nếu null thì = 0
           @GiaVanChuyen = GiaVanChuyen,
           @MaSanPham = MaSanPham_BienThe
    FROM DON_HANG 
    WHERE MaDonHang = @MaDonHang;
    
    IF @MaSoShop IS NULL RETURN;
    
    -- 2. ÁP DỤNG CHIẾT KHẤU TRƯỚC TIÊN
    -- Giá dùng để tính voucher = Giá gốc * (100 - %Chiết khấu) / 100
    SET @GiaSauChietKhau = @GiaBanDau * (100 - @ChietKhau) / 100;

    DECLARE @GiaSauShop DECIMAL(18,2) = CAST(@GiaSauChietKhau AS DECIMAL(18,2)); 
    DECLARE @GiaSauAdmin DECIMAL(18,2);
    DECLARE @TongDonHangCuoiCung DECIMAL(18,2);
    
    DECLARE @VoucherID CHAR(8), @TenVC NVARCHAR(50);
    DECLARE @GiamPhanTram DECIMAL(5,2), @GiamTien INT;
    DECLARE @MucGiamMax INT, @MucGiamMin INT;
    DECLARE @SoTienGiam INT;
    
    -- TẦNG 1: SHOP (Tính dựa trên @GiaSauChietKhau)
    IF @MaVoucherShop IS NOT NULL
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM MA_GIAM_GIA WHERE MaVoucher = @MaVoucherShop AND NguoiTao = 'SHOP' AND MaSoShop = @MaSoShop AND LuotSuDungConLai > 0)
        BEGIN
            INSERT INTO @KetQua (MaVoucher, TenVoucher, TrangThaiApDung, ChuThich, CoTheApDung, LyDoKhongApDung)
            VALUES (@MaVoucherShop, N'[Không tìm thấy]', N'Không khả dụng', N'Mã không hợp lệ', 0, N'Mã voucher không tồn tại hoặc hết lượt');
            RETURN;
        END
        
        IF NOT EXISTS (SELECT 1 FROM MAT_HANG_AP_DUNG WHERE MaVoucher = @MaVoucherShop AND MatHangApDung = @MaSanPham)
        BEGIN
            SELECT @TenVC = TenVoucher, @GiamPhanTram = GiamTheoPhanTram, @GiamTien = GiamTheoLuongTien, @MucGiamMax = MucGiamToiDa, @MucGiamMin = MucGiamToiThieu
            FROM MA_GIAM_GIA WHERE MaVoucher = @MaVoucherShop;

            INSERT INTO @KetQua (MaVoucher, TenVoucher, LoaiVoucher, MoTaGiamGia, SoTienGiam, DieuKienApDung, TrangThaiApDung, ChuThich, CoTheApDung, LyDoKhongApDung)
            VALUES (@MaVoucherShop, @TenVC, N'SHOP',
                    CASE WHEN @GiamPhanTram IS NOT NULL THEN N'Giảm ' + CAST(@GiamPhanTram AS NVARCHAR) + N'% (Max ' + FORMAT(@MucGiamMax, 'N0') + N'đ)' ELSE N'Giảm ' + FORMAT(@GiamTien, 'N0') + N'đ' END,
                    CASE WHEN @GiamPhanTram IS NOT NULL THEN LEAST(CAST(@GiaSauChietKhau * @GiamPhanTram / 100 AS INT), ISNULL(@MucGiamMax, 999999999)) ELSE @GiamTien END,
                    N'Đơn tối thiểu ' + FORMAT(@MucGiamMin, 'N0') + N'đ',
                    N'Không khả dụng', N'Không áp dụng sp này', 0, N'Sản phẩm không nằm trong danh sách áp dụng');
            RETURN;
        END
        
        INSERT INTO @KetQua (MaVoucher, TenVoucher, LoaiVoucher, MoTaGiamGia, SoTienGiam, DieuKienApDung, TrangThaiApDung, GiaApDung, GiaSauGiam, ChuThich, CoTheApDung)
        SELECT 
            MaVoucher, TenVoucher, N'SHOP',
            CASE WHEN GiamTheoPhanTram IS NOT NULL THEN N'Giảm ' + CAST(GiamTheoPhanTram AS NVARCHAR) + N'% (Max ' + FORMAT(MucGiamToiDa, 'N0') + N'đ)' ELSE N'Giảm ' + FORMAT(GiamTheoLuongTien, 'N0') + N'đ' END,
            CASE WHEN GiamTheoPhanTram IS NOT NULL THEN LEAST(CAST(@GiaSauChietKhau * GiamTheoPhanTram / 100 AS INT), ISNULL(MucGiamToiDa, 999999999)) ELSE GiamTheoLuongTien END,
            N'Đơn tối thiểu ' + FORMAT(MucGiamToiThieu, 'N0') + N'đ',
            N'Đã chọn', CAST(@GiaSauChietKhau AS DECIMAL(18,2)),
            CAST(@GiaSauChietKhau AS DECIMAL(18,2)) - CASE WHEN GiamTheoPhanTram IS NOT NULL THEN LEAST(CAST(@GiaSauChietKhau * GiamTheoPhanTram / 100 AS INT), ISNULL(MucGiamToiDa, 999999999)) ELSE GiamTheoLuongTien END,
            N'Tầng 1: Đã trừ chiết khấu ' + CAST(@ChietKhau AS NVARCHAR) + N'%', 1
        FROM MA_GIAM_GIA WHERE MaVoucher = @MaVoucherShop;
        
        SELECT @GiaSauShop = GiaSauGiam FROM @KetQua WHERE MaVoucher = @MaVoucherShop;
    END
    ELSE
    BEGIN
        DECLARE cursor_shop CURSOR FOR SELECT MaVoucher, TenVoucher, GiamTheoPhanTram, GiamTheoLuongTien, MucGiamToiDa, MucGiamToiThieu FROM MA_GIAM_GIA WHERE NguoiTao = 'SHOP' AND MaSoShop = @MaSoShop AND LuotSuDungConLai > 0;
        OPEN cursor_shop;
        FETCH NEXT FROM cursor_shop INTO @VoucherID, @TenVC, @GiamPhanTram, @GiamTien, @MucGiamMax, @MucGiamMin;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF @GiamPhanTram IS NOT NULL SET @SoTienGiam = LEAST(CAST(@GiaSauChietKhau * @GiamPhanTram / 100 AS INT), ISNULL(@MucGiamMax, 999999999)); ELSE SET @SoTienGiam = @GiamTien;

            IF NOT EXISTS (SELECT 1 FROM MAT_HANG_AP_DUNG WHERE MaVoucher = @VoucherID AND MatHangApDung = @MaSanPham)
            BEGIN
                INSERT INTO @KetQua (MaVoucher, TenVoucher, LoaiVoucher, MoTaGiamGia, SoTienGiam, DieuKienApDung, TrangThaiApDung, ChuThich, CoTheApDung, LyDoKhongApDung)
                VALUES (@VoucherID, @TenVC, N'SHOP', 
                        CASE WHEN @GiamPhanTram IS NOT NULL THEN N'Giảm ' + CAST(@GiamPhanTram AS NVARCHAR) + N'% (Max ' + FORMAT(@MucGiamMax, 'N0') + N'đ)' ELSE N'Giảm ' + FORMAT(@GiamTien, 'N0') + N'đ' END,
                        @SoTienGiam, N'Đơn tối thiểu ' + FORMAT(@MucGiamMin, 'N0') + N'đ',
                        N'Không khả dụng', N'Sai sản phẩm', 0, N'Sản phẩm không hỗ trợ');
            END
            ELSE IF @GiaSauChietKhau < @MucGiamMin
            BEGIN
                INSERT INTO @KetQua (MaVoucher, TenVoucher, LoaiVoucher, MoTaGiamGia, SoTienGiam, DieuKienApDung, TrangThaiApDung, ChuThich, CoTheApDung, LyDoKhongApDung)
                VALUES (@VoucherID, @TenVC, N'SHOP', 
                        CASE WHEN @GiamPhanTram IS NOT NULL THEN N'Giảm ' + CAST(@GiamPhanTram AS NVARCHAR) + N'% (Max ' + FORMAT(@MucGiamMax, 'N0') + N'đ)' ELSE N'Giảm ' + FORMAT(@GiamTien, 'N0') + N'đ' END,
                        @SoTienGiam, N'Đơn tối thiểu ' + FORMAT(@MucGiamMin, 'N0') + N'đ',
                        N'Không khả dụng', N'Thiếu ' + FORMAT(@MucGiamMin - @GiaSauChietKhau, 'N0') + N'đ', 0, N'Chưa đủ tiền tối thiểu');
            END
            ELSE
            BEGIN
                INSERT INTO @KetQua (MaVoucher, TenVoucher, LoaiVoucher, MoTaGiamGia, SoTienGiam, DieuKienApDung, TrangThaiApDung, GiaApDung, GiaSauGiam, ChuThich, CoTheApDung)
                VALUES (@VoucherID, @TenVC, N'SHOP',
                    CASE WHEN @GiamPhanTram IS NOT NULL THEN N'Giảm ' + CAST(@GiamPhanTram AS NVARCHAR) + N'% (Max ' + FORMAT(@MucGiamMax, 'N0') + N'đ)' ELSE N'Giảm ' + FORMAT(@GiamTien, 'N0') + N'đ' END,
                    @SoTienGiam, N'Đơn tối thiểu ' + FORMAT(@MucGiamMin, 'N0') + N'đ', N'Khả dụng', CAST(@GiaSauChietKhau AS DECIMAL(18,2)), CAST(@GiaSauChietKhau AS DECIMAL(18,2)) - @SoTienGiam, N'Tiết kiệm ' + FORMAT(@SoTienGiam, 'N0') + N'đ', 1);
            END
            FETCH NEXT FROM cursor_shop INTO @VoucherID, @TenVC, @GiamPhanTram, @GiamTien, @MucGiamMax, @MucGiamMin;
        END
        CLOSE cursor_shop; DEALLOCATE cursor_shop;
    END
    
    -- TẦNG 2: ADMIN
    SET @GiaSauAdmin = @GiaSauShop; 
    DECLARE @GiaApDungChoAdmin DECIMAL(18,2) = @GiaSauShop;
    
    IF @MaVoucherAdmin IS NOT NULL
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM MA_GIAM_GIA WHERE MaVoucher = @MaVoucherAdmin AND NguoiTao = 'ADMIN' AND LuotSuDungConLai > 0 AND MaSoShop IS NULL)
        BEGIN
            INSERT INTO @KetQua (MaVoucher, TenVoucher, TrangThaiApDung, ChuThich, CoTheApDung, LyDoKhongApDung)
            VALUES (@MaVoucherAdmin, N'[Lỗi]', N'Không khả dụng', N'Voucher hệ thống lỗi', 0, N'Mã không hợp lệ');
            RETURN;
        END
        
        INSERT INTO @KetQua (MaVoucher, TenVoucher, LoaiVoucher, MoTaGiamGia, SoTienGiam, DieuKienApDung, TrangThaiApDung, GiaApDung, GiaSauGiam, ChuThich, CoTheApDung)
        SELECT 
            MaVoucher, TenVoucher, N'ADMIN',
            CASE WHEN GiamTheoPhanTram IS NOT NULL THEN N'Giảm ' + CAST(GiamTheoPhanTram AS NVARCHAR) + N'%' ELSE N'Giảm ' + FORMAT(GiamTheoLuongTien, 'N0') + N'đ' END,
            CASE WHEN GiamTheoPhanTram IS NOT NULL THEN LEAST(CAST(@GiaApDungChoAdmin * GiamTheoPhanTram / 100 AS INT), ISNULL(MucGiamToiDa, 999999999)) ELSE GiamTheoLuongTien END,
            CASE WHEN @MaVoucherShop IS NOT NULL THEN N'Áp dụng lên giá sau Shop' ELSE N'Áp dụng lên giá gốc' END,
            N'Đã chọn', @GiaApDungChoAdmin,
            @GiaApDungChoAdmin - CASE WHEN GiamTheoPhanTram IS NOT NULL THEN LEAST(CAST(@GiaApDungChoAdmin * GiamTheoPhanTram / 100 AS INT), ISNULL(MucGiamToiDa, 999999999)) ELSE GiamTheoLuongTien END,
            N'Tầng 2: Áp dụng thành công', 1
        FROM MA_GIAM_GIA WHERE MaVoucher = @MaVoucherAdmin;
        
        SELECT @GiaSauAdmin = GiaSauGiam FROM @KetQua WHERE MaVoucher = @MaVoucherAdmin;
    END
    ELSE
    BEGIN
        DECLARE cursor_admin CURSOR FOR SELECT MaVoucher, TenVoucher, GiamTheoPhanTram, GiamTheoLuongTien, MucGiamToiDa, MucGiamToiThieu FROM MA_GIAM_GIA WHERE NguoiTao = 'ADMIN' AND LuotSuDungConLai > 0 AND MaSoShop IS NULL;
        OPEN cursor_admin;
        FETCH NEXT FROM cursor_admin INTO @VoucherID, @TenVC, @GiamPhanTram, @GiamTien, @MucGiamMax, @MucGiamMin;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF @GiamPhanTram IS NOT NULL SET @SoTienGiam = LEAST(CAST(@GiaApDungChoAdmin * @GiamPhanTram / 100 AS INT), ISNULL(@MucGiamMax, 999999999)); ELSE SET @SoTienGiam = @GiamTien;

            IF @GiaApDungChoAdmin < @MucGiamMin
            BEGIN
                INSERT INTO @KetQua (MaVoucher, TenVoucher, LoaiVoucher, MoTaGiamGia, SoTienGiam, DieuKienApDung, TrangThaiApDung, ChuThich, CoTheApDung, LyDoKhongApDung)
                VALUES (@VoucherID, @TenVC, N'ADMIN',
                    CASE WHEN @GiamPhanTram IS NOT NULL THEN N'Giảm ' + CAST(@GiamPhanTram AS NVARCHAR) + N'%' ELSE N'Giảm ' + FORMAT(@GiamTien, 'N0') + N'đ' END,
                    @SoTienGiam, N'Đơn tối thiểu ' + FORMAT(@MucGiamMin, 'N0') + N'đ', 
                    N'Chưa đủ điều kiện', N'Thiếu ' + FORMAT(@MucGiamMin - @GiaApDungChoAdmin, 'N0') + N'đ', 0, N'Giá trị đơn hàng chưa đủ');
            END
            ELSE
            BEGIN
                INSERT INTO @KetQua (MaVoucher, TenVoucher, LoaiVoucher, MoTaGiamGia, SoTienGiam, DieuKienApDung, TrangThaiApDung, GiaApDung, GiaSauGiam, ChuThich, CoTheApDung)
                VALUES (@VoucherID, @TenVC, N'ADMIN',
                    CASE WHEN @GiamPhanTram IS NOT NULL THEN N'Giảm ' + CAST(@GiamPhanTram AS NVARCHAR) + N'%' ELSE N'Giảm ' + FORMAT(@GiamTien, 'N0') + N'đ' END,
                    @SoTienGiam, N'Đơn tối thiểu ' + FORMAT(@MucGiamMin, 'N0') + N'đ', N'Khả dụng', @GiaApDungChoAdmin, @GiaApDungChoAdmin - @SoTienGiam, N'Voucher Sàn khả dụng', 1);
            END
            FETCH NEXT FROM cursor_admin INTO @VoucherID, @TenVC, @GiamPhanTram, @GiamTien, @MucGiamMax, @MucGiamMin;
        END
        CLOSE cursor_admin; DEALLOCATE cursor_admin;
    END

    -- TẦNG 3: TRANSPORT (Không đổi)
    SET @TongDonHangCuoiCung = @GiaSauAdmin;
    
    IF @MaVoucherTransport IS NOT NULL
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM MA_GIAM_GIA WHERE MaVoucher = @MaVoucherTransport AND NguoiTao = 'TRANSPORT' AND LuotSuDungConLai > 0)
        BEGIN
            INSERT INTO @KetQua (MaVoucher, TenVoucher, TrangThaiApDung, ChuThich, CoTheApDung, LyDoKhongApDung)
            VALUES (@MaVoucherTransport, N'[Lỗi]', N'Không hợp lệ', N'Voucher vận chuyển lỗi', 0, N'Mã không hợp lệ');
            RETURN;
        END
        
        DECLARE @DieuKienMinVC INT;
        SELECT @DieuKienMinVC = MucGiamToiThieu FROM MA_GIAM_GIA WHERE MaVoucher = @MaVoucherTransport;
        
        IF @TongDonHangCuoiCung < @DieuKienMinVC
        BEGIN
            SELECT @TenVC = TenVoucher, @GiamPhanTram = GiamTheoPhanTram, @GiamTien = GiamTheoLuongTien, @MucGiamMax = MucGiamToiDa FROM MA_GIAM_GIA WHERE MaVoucher = @MaVoucherTransport;
            IF @GiamPhanTram IS NOT NULL SET @SoTienGiam = LEAST(CAST(@GiaVanChuyen * @GiamPhanTram / 100 AS INT), ISNULL(@MucGiamMax, 999999999)); ELSE SET @SoTienGiam = @GiamTien;

            INSERT INTO @KetQua (MaVoucher, TenVoucher, LoaiVoucher, MoTaGiamGia, SoTienGiam, DieuKienApDung, TrangThaiApDung, ChuThich, CoTheApDung, LyDoKhongApDung, TongDonHangSauVoucher)
            VALUES (@MaVoucherTransport, @TenVC, N'TRANSPORT',
                    CASE WHEN @GiamPhanTram IS NOT NULL THEN N'Giảm ' + CAST(@GiamPhanTram AS NVARCHAR) + N'% ship' ELSE N'Giảm ' + FORMAT(@GiamTien, 'N0') + N'đ ship' END,
                    @SoTienGiam,
                    N'Đơn hàng tối thiểu ' + FORMAT(@DieuKienMinVC, 'N0') + N'đ',
                    N'Chưa đủ điều kiện', N'Thiếu ' + FORMAT(@DieuKienMinVC - @TongDonHangCuoiCung, 'N0') + N'đ', 0, N'Chưa đủ điều kiện FreeShip', @TongDonHangCuoiCung);
        END
        ELSE
        BEGIN
            INSERT INTO @KetQua (MaVoucher, TenVoucher, LoaiVoucher, MoTaGiamGia, SoTienGiam, DieuKienApDung, TrangThaiApDung, GiaApDung, GiaSauGiam, TongDonHangSauVoucher, ChuThich, CoTheApDung)
            SELECT 
                MaVoucher, TenVoucher, N'TRANSPORT',
                CASE WHEN GiamTheoPhanTram IS NOT NULL THEN N'Giảm ' + CAST(GiamTheoPhanTram AS NVARCHAR) + N'% ship' ELSE N'Giảm ' + FORMAT(GiamTheoLuongTien, 'N0') + N'đ ship' END,
                CASE WHEN GiamTheoPhanTram IS NOT NULL THEN LEAST(CAST(@GiaVanChuyen * GiamTheoPhanTram / 100 AS INT), ISNULL(MucGiamToiDa, 999999999)) ELSE GiamTheoLuongTien END,
                N'Đơn hàng tối thiểu từ ' + FORMAT(MucGiamToiThieu, 'N0') + N'đ',
                N'Đã chọn', @GiaVanChuyen,
                @GiaVanChuyen - CASE WHEN GiamTheoPhanTram IS NOT NULL THEN LEAST(CAST(@GiaVanChuyen * GiamTheoPhanTram / 100 AS INT), ISNULL(MucGiamToiDa, 999999999)) ELSE GiamTheoLuongTien END,
                @TongDonHangCuoiCung, N'Tầng 3: Đã áp dụng', 1
            FROM MA_GIAM_GIA WHERE MaVoucher = @MaVoucherTransport;
        END
    END
    ELSE
    BEGIN
        DECLARE cursor_transport CURSOR FOR SELECT MaVoucher, TenVoucher, GiamTheoPhanTram, GiamTheoLuongTien, MucGiamToiDa, MucGiamToiThieu FROM MA_GIAM_GIA WHERE NguoiTao = 'TRANSPORT' AND LuotSuDungConLai > 0;
        OPEN cursor_transport;
        FETCH NEXT FROM cursor_transport INTO @VoucherID, @TenVC, @GiamPhanTram, @GiamTien, @MucGiamMax, @MucGiamMin;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF @GiamPhanTram IS NOT NULL SET @SoTienGiam = LEAST(CAST(@GiaVanChuyen * @GiamPhanTram / 100 AS INT), ISNULL(@MucGiamMax, 999999999)); ELSE SET @SoTienGiam = @GiamTien;

            IF @TongDonHangCuoiCung < @MucGiamMin
            BEGIN
                INSERT INTO @KetQua (MaVoucher, TenVoucher, LoaiVoucher, MoTaGiamGia, SoTienGiam, DieuKienApDung, TrangThaiApDung, GiaApDung, GiaSauGiam, TongDonHangSauVoucher, ChuThich, CoTheApDung, LyDoKhongApDung)
                VALUES (@VoucherID, @TenVC, N'TRANSPORT',
                    CASE WHEN @GiamPhanTram IS NOT NULL THEN N'Giảm ' + CAST(@GiamPhanTram AS NVARCHAR) + N'% ship' ELSE N'Giảm ' + FORMAT(@GiamTien, 'N0') + N'đ ship' END,
                    @SoTienGiam, N'Đơn hàng tối thiểu từ ' + FORMAT(@MucGiamMin, 'N0') + N'đ', 
                    N'Chưa đủ điều kiện', @GiaVanChuyen, @GiaVanChuyen, @TongDonHangCuoiCung, N'Thiếu ' + FORMAT(@MucGiamMin - @TongDonHangCuoiCung, 'N0') + N'đ', 0, N'Chưa đủ điều kiện tối thiểu');
            END
            ELSE
            BEGIN
                INSERT INTO @KetQua (MaVoucher, TenVoucher, LoaiVoucher, MoTaGiamGia, SoTienGiam, DieuKienApDung, TrangThaiApDung, GiaApDung, GiaSauGiam, TongDonHangSauVoucher, ChuThich, CoTheApDung)
                VALUES (@VoucherID, @TenVC, N'TRANSPORT',
                    CASE WHEN @GiamPhanTram IS NOT NULL THEN N'Giảm ' + CAST(@GiamPhanTram AS NVARCHAR) + N'% ship' ELSE N'Giảm ' + FORMAT(@GiamTien, 'N0') + N'đ ship' END,
                    @SoTienGiam, N'Đơn hàng tối thiểu từ ' + FORMAT(@MucGiamMin, 'N0') + N'đ', N'Khả dụng', @GiaVanChuyen, @GiaVanChuyen - @SoTienGiam, @TongDonHangCuoiCung, N'Tầng 3: Khả dụng', 1);
            END
            FETCH NEXT FROM cursor_transport INTO @VoucherID, @TenVC, @GiamPhanTram, @GiamTien, @MucGiamMax, @MucGiamMin;
        END
        CLOSE cursor_transport; DEALLOCATE cursor_transport;
    END
    
    UPDATE @KetQua SET TongDonHangSauVoucher = @TongDonHangCuoiCung WHERE LoaiVoucher IN (N'SHOP', N'ADMIN') AND TongDonHangSauVoucher IS NULL;
    RETURN;
END;
GO

-- --------------------------------------------------------------------------------------
-- 2. FUNCTION: TÍNH CHI TIẾT HÓA ĐƠN (CORE LOGIC)
-- Đã thêm Logic trừ chiết khấu vào @GiaBanDau trước khi tính voucher
-- --------------------------------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_TinhChiTietDonHang
(
    @MaDonHang CHAR(8),
    @MaVoucherShop CHAR(8) = NULL,
    @MaVoucherAdmin CHAR(8) = NULL,
    @MaVoucherTransport CHAR(8) = NULL
)
RETURNS @HoaDon TABLE
(
    MaDonHang CHAR(8),
    GiaNiemYet DECIMAL(18, 2),    -- MỚI
    TienChietKhau DECIMAL(18, 2), -- MỚI
    GiaGoc DECIMAL(18, 2),        -- Giá sau chiết khấu
    PhiVanChuyen DECIMAL(18, 2),
    MaVoucherShop CHAR(8),
    GiamGiaShop DECIMAL(18, 2),
    MaVoucherAdmin CHAR(8),
    GiamGiaAdmin DECIMAL(18, 2),
    MaVoucherShip CHAR(8),
    GiamGiaShip DECIMAL(18, 2),
    TongTienHangSauGiam DECIMAL(18, 2),
    TongTienShipSauGiam DECIMAL(18, 2),
    TONG_THANH_TOAN DECIMAL(18, 2)
)
AS
BEGIN
    DECLARE @MaSoShop CHAR(8), @GiaBanDau DECIMAL(18, 2), @GiaVanChuyen DECIMAL(18, 2), @MaSanPham VARCHAR(100);
    DECLARE @ChietKhau INT; 
    
    SELECT @MaSoShop = MaSoShop, 
           @GiaBanDau = CAST(GiaBanDau AS DECIMAL(18, 2)), 
           @ChietKhau = ISNULL(ChietKhau, 0),
           @GiaVanChuyen = CAST(GiaVanChuyen AS DECIMAL(18, 2)),
           @MaSanPham = MaSanPham_BienThe
    FROM DON_HANG 
    WHERE MaDonHang = @MaDonHang;

    IF @MaSoShop IS NULL RETURN;

    -- TÍNH TOÁN CÁC LOẠI GIÁ
    DECLARE @GiaNiemYet DECIMAL(18,2) = @GiaBanDau; -- Giá gốc ban đầu
    DECLARE @TienChietKhau DECIMAL(18,2) = @GiaBanDau * CAST(@ChietKhau AS DECIMAL(18,2)) / 100.0;
    DECLARE @GiaSauChietKhau DECIMAL(18,2) = @GiaBanDau - @TienChietKhau; -- Giá dùng để tính Voucher

    -- CÁC LOGIC TÍNH VOUCHER (Dựa trên @GiaSauChietKhau)
    DECLARE @GiamShop DECIMAL(18, 2) = 0;
    DECLARE @GiamAdmin DECIMAL(18, 2) = 0;
    DECLARE @GiamShip DECIMAL(18, 2) = 0;
    DECLARE @GiaSauShop DECIMAL(18, 2) = @GiaSauChietKhau;
    DECLARE @GiaSauAdmin DECIMAL(18, 2);
    
    -- (Logic tính toán Voucher Shop/Admin/Ship giữ nguyên như V2, 
    -- chỉ thay biến đầu vào là @GiaSauChietKhau)
    
    -- TẦNG 1: SHOP
    IF @MaVoucherShop IS NOT NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM MA_GIAM_GIA WHERE MaVoucher = @MaVoucherShop AND NguoiTao = 'SHOP' AND MaSoShop = @MaSoShop AND LuotSuDungConLai > 0)
           AND EXISTS (SELECT 1 FROM MAT_HANG_AP_DUNG WHERE MaVoucher = @MaVoucherShop AND MatHangApDung = @MaSanPham)
        BEGIN
            DECLARE @MinShop INT; SELECT @MinShop = MucGiamToiThieu FROM MA_GIAM_GIA WHERE MaVoucher = @MaVoucherShop;
            IF @GiaSauChietKhau >= @MinShop
            BEGIN
                SELECT @GiamShop = CASE WHEN GiamTheoPhanTram IS NOT NULL THEN LEAST(CAST(@GiaSauChietKhau * GiamTheoPhanTram / 100 AS DECIMAL(18,2)), CAST(ISNULL(MucGiamToiDa, 999999999) AS DECIMAL(18,2))) ELSE CAST(GiamTheoLuongTien AS DECIMAL(18,2)) END
                FROM MA_GIAM_GIA WHERE MaVoucher = @MaVoucherShop;
            END
        END
    END
    SET @GiaSauShop = @GiaSauChietKhau - @GiamShop; IF @GiaSauShop < 0 SET @GiaSauShop = 0;

    -- TẦNG 2: ADMIN
    SET @GiaSauAdmin = @GiaSauShop;
    IF @MaVoucherAdmin IS NOT NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM MA_GIAM_GIA WHERE MaVoucher = @MaVoucherAdmin AND NguoiTao = 'ADMIN' AND LuotSuDungConLai > 0 AND MaSoShop IS NULL)
        BEGIN
            DECLARE @MinAdmin INT; SELECT @MinAdmin = MucGiamToiThieu FROM MA_GIAM_GIA WHERE MaVoucher = @MaVoucherAdmin;
            IF @GiaSauShop >= @MinAdmin
            BEGIN
                SELECT @GiamAdmin = CASE WHEN GiamTheoPhanTram IS NOT NULL THEN LEAST(CAST(@GiaSauShop * GiamTheoPhanTram / 100 AS DECIMAL(18,2)), CAST(ISNULL(MucGiamToiDa, 999999999) AS DECIMAL(18,2))) ELSE CAST(GiamTheoLuongTien AS DECIMAL(18,2)) END
                FROM MA_GIAM_GIA WHERE MaVoucher = @MaVoucherAdmin;
            END
        END
    END
    SET @GiaSauAdmin = @GiaSauShop - @GiamAdmin; IF @GiaSauAdmin < 0 SET @GiaSauAdmin = 0;

    -- TẦNG 3: SHIP
    DECLARE @TongTienHangCuoiCung DECIMAL(18, 2) = @GiaSauAdmin;
    IF @MaVoucherTransport IS NOT NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM MA_GIAM_GIA WHERE MaVoucher = @MaVoucherTransport AND NguoiTao = 'TRANSPORT' AND LuotSuDungConLai > 0)
        BEGIN
            DECLARE @MinShip INT; SELECT @MinShip = MucGiamToiThieu FROM MA_GIAM_GIA WHERE MaVoucher = @MaVoucherTransport;
            IF @TongTienHangCuoiCung >= @MinShip
            BEGIN
                SELECT @GiamShip = CASE WHEN GiamTheoPhanTram IS NOT NULL THEN LEAST(CAST(@GiaVanChuyen * GiamTheoPhanTram / 100 AS DECIMAL(18,2)), CAST(ISNULL(MucGiamToiDa, 999999999) AS DECIMAL(18,2))) ELSE CAST(GiamTheoLuongTien AS DECIMAL(18,2)) END
                FROM MA_GIAM_GIA WHERE MaVoucher = @MaVoucherTransport;
            END
        END
    END

    -- TRẢ VỀ KẾT QUẢ CÓ THÊM 2 CỘT MỚI
    INSERT INTO @HoaDon (MaDonHang, GiaNiemYet, TienChietKhau, GiaGoc, PhiVanChuyen, MaVoucherShop, GiamGiaShop, MaVoucherAdmin, GiamGiaAdmin, MaVoucherShip, GiamGiaShip, TongTienHangSauGiam, TongTienShipSauGiam, TONG_THANH_TOAN)
    VALUES (@MaDonHang, @GiaNiemYet, @TienChietKhau, @GiaSauChietKhau, @GiaVanChuyen, @MaVoucherShop, @GiamShop, @MaVoucherAdmin, @GiamAdmin, @MaVoucherTransport, @GiamShip, @TongTienHangCuoiCung, (@GiaVanChuyen - @GiamShip), @TongTienHangCuoiCung + (@GiaVanChuyen - @GiamShip));
    RETURN;
END;
GO

-- --------------------------------------------------------------------------------------
-- 3. STORED PROCEDURE: ĐẶT HÀNG (TRANSACTION)
-- --------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_DatHang
(
    @MaDonHang CHAR(8),
    @MaVoucherShop CHAR(8) = NULL,
    @MaVoucherAdmin CHAR(8) = NULL,
    @MaVoucherTransport CHAR(8) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM DON_HANG WHERE MaDonHang = @MaDonHang)
        BEGIN
            RAISERROR(N'Đơn hàng không tồn tại!', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        DELETE FROM AP_DUNG_MA_GIAM_GIA WHERE MaDonHang = @MaDonHang;

        IF @MaVoucherShop IS NOT NULL AND LEN(@MaVoucherShop) > 0 AND EXISTS (SELECT 1 FROM MA_GIAM_GIA WHERE MaVoucher = @MaVoucherShop)
            INSERT INTO AP_DUNG_MA_GIAM_GIA (MaVoucher, MaDonHang) VALUES (@MaVoucherShop, @MaDonHang);

        IF @MaVoucherAdmin IS NOT NULL AND LEN(@MaVoucherAdmin) > 0 AND EXISTS (SELECT 1 FROM MA_GIAM_GIA WHERE MaVoucher = @MaVoucherAdmin)
            INSERT INTO AP_DUNG_MA_GIAM_GIA (MaVoucher, MaDonHang) VALUES (@MaVoucherAdmin, @MaDonHang);

        IF @MaVoucherTransport IS NOT NULL AND LEN(@MaVoucherTransport) > 0 AND EXISTS (SELECT 1 FROM MA_GIAM_GIA WHERE MaVoucher = @MaVoucherTransport)
            INSERT INTO AP_DUNG_MA_GIAM_GIA (MaVoucher, MaDonHang) VALUES (@MaVoucherTransport, @MaDonHang);

        COMMIT TRANSACTION;
        SELECT 1 AS Status, N'Đặt hàng thành công!' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        SELECT 0 AS Status, @ErrorMessage AS Message;
    END CATCH
END;
GO

-- --------------------------------------------------------------------------------------
-- 4. FUNCTION: LIỆT KÊ ĐƠN HÀNG (CHO SHOP) - CÓ DÙNG CURSOR
-- --------------------------------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_LietKeDonHangCuaShop(@MaSoShop CHAR(8))
RETURNS @KetQua TABLE
(
    STT INT,
    MaDonHang CHAR(8),
    TenSanPhamHienThi NVARCHAR(500),
    TenNguoiMua NVARCHAR(255),
    SoLuong INT,
	DonGia DECIMAL(18,2),    -- [MỚI] Đơn giá (Tính toán từ DB)
    GiaBanDau DECIMAL(18,2), -- Giá gốc (Sau chiết khấu)
    ThanhTien DECIMAL(18,2), -- Khách trả (TONG_THANH_TOAN)
    ThucThu DECIMAL(18,2),   -- Shop nhận (Giá Gốc - Voucher Shop)
    TrangThai NVARCHAR(31),
    NgayDat DATETIME,
    NgayDuKienGiao DATETIME
)
AS
BEGIN
    DECLARE @MaDonHang CHAR(8), @MaSanPham VARCHAR(100), @IDBienThe VARCHAR(100);
    DECLARE @SoLuong INT, @GiaBanDau DECIMAL(18,2), @TrangThai NVARCHAR(31);
    DECLARE @NgayDat DATETIME, @NgayDuKienGiao DATETIME, @TenNguoiMua NVARCHAR(255);
    DECLARE @TenGoc NVARCHAR(255), @TenBienThe NVARCHAR(255), @TenDayDu NVARCHAR(500);
    
    DECLARE @TongThanhToan DECIMAL(18,2); -- Khách trả
    DECLARE @ThucThuCuaShop DECIMAL(18,2); -- Shop nhận
    DECLARE @STT INT = 0;
	DECLARE @DonGia DECIMAL(18,2); -- đơn giá
    -- Biến tạm Voucher
    DECLARE @VoucherShop CHAR(8), @VoucherAdmin CHAR(8), @VoucherTrans CHAR(8);
    
    IF @MaSoShop IS NULL OR @MaSoShop = '' RETURN;
    
    DECLARE cur_DonHang CURSOR FOR 
    SELECT dh.MaDonHang, dh.MaSanPham_BienThe, dh.ID_BienThe, dh.SoLuongCuaBienThe, dh.GiaBanDau, dh.TrangThai, dh.ThoiGianDatHang, dh.ThoiGianGiaoDuKien, nd.HoVaTen
    FROM DON_HANG dh 
    INNER JOIN NGUOI_MUA nm ON dh.TenDangNhapNguoiMua = nm.TenDangNhap
    INNER JOIN NGUOI_DUNG nd ON nm.TenDangNhap = nd.TenDangNhap
    WHERE dh.MaSoShop = @MaSoShop 
    ORDER BY dh.ThoiGianDatHang DESC; 
    
    OPEN cur_DonHang;
    FETCH NEXT FROM cur_DonHang INTO @MaDonHang, @MaSanPham, @IDBienThe, @SoLuong, @GiaBanDau, @TrangThai, @NgayDat, @NgayDuKienGiao, @TenNguoiMua;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @STT = @STT + 1;
        
        -- Xử lý tên
        SELECT @TenGoc = TenSanPham FROM SAN_PHAM WHERE MaSanPham = @MaSanPham;
        IF @IDBienThe IS NOT NULL SELECT @TenBienThe = Ten FROM BIEN_THE_SAN_PHAM WHERE ID = @IDBienThe AND MaSanPham = @MaSanPham;
        IF @TenGoc IS NULL SET @TenGoc = N'Sản phẩm lỗi';
        SET @TenDayDu = CASE WHEN @TenBienThe IS NOT NULL AND @TenBienThe <> N'Mặc định' THEN @TenGoc + N' (' + @TenBienThe + N')' ELSE @TenGoc END;

        -- Lấy Voucher
        SELECT @VoucherShop = a.MaVoucher FROM AP_DUNG_MA_GIAM_GIA a JOIN MA_GIAM_GIA m ON a.MaVoucher = m.MaVoucher WHERE a.MaDonHang = @MaDonHang AND m.NguoiTao = 'SHOP';
        SELECT @VoucherAdmin = a.MaVoucher FROM AP_DUNG_MA_GIAM_GIA a JOIN MA_GIAM_GIA m ON a.MaVoucher = m.MaVoucher WHERE a.MaDonHang = @MaDonHang AND m.NguoiTao = 'ADMIN';
        SELECT @VoucherTrans = a.MaVoucher FROM AP_DUNG_MA_GIAM_GIA a JOIN MA_GIAM_GIA m ON a.MaVoucher = m.MaVoucher WHERE a.MaDonHang = @MaDonHang AND m.NguoiTao = 'TRANSPORT';

        -- TÍNH TOÁN
        -- 1. TONG_THANH_TOAN (Khách trả)
        -- 2. ThucThu = GiaGoc (Đã trừ chiết khấu trong hàm V2) - GiamGiaShop
        SELECT 
            @TongThanhToan = TONG_THANH_TOAN,
            @ThucThuCuaShop = (GiaGoc - GiamGiaShop)
        FROM dbo.fn_TinhChiTietDonHang(@MaDonHang, @VoucherShop, @VoucherAdmin, @VoucherTrans);
        
        IF @TongThanhToan IS NULL SET @TongThanhToan = @GiaBanDau;
        IF @ThucThuCuaShop IS NULL SET @ThucThuCuaShop = @GiaBanDau;
		IF @SoLuong > 0 
            SET @DonGia = @GiaBanDau / @SoLuong;
        ELSE 
            SET @DonGia = 0;

        INSERT INTO @KetQua (STT, MaDonHang, TenSanPhamHienThi, TenNguoiMua, SoLuong, DonGia, GiaBanDau, ThanhTien, ThucThu, TrangThai, NgayDat, NgayDuKienGiao)
        VALUES (@STT, @MaDonHang, @TenDayDu, @TenNguoiMua, @SoLuong, @DonGia, CAST(@GiaBanDau AS DECIMAL(18,2)), @TongThanhToan, @ThucThuCuaShop, @TrangThai, @NgayDat, @NgayDuKienGiao);
        
        FETCH NEXT FROM cur_DonHang INTO @MaDonHang, @MaSanPham, @IDBienThe, @SoLuong, @GiaBanDau, @TrangThai, @NgayDat, @NgayDuKienGiao, @TenNguoiMua;
    END
    CLOSE cur_DonHang; DEALLOCATE cur_DonHang;
    RETURN;
END;
GO

-- TEST THỬ thôi --
USE HeThongBanHang;
GO

PRINT N'=== TEST 1: FUNCTION fn_LietKeDonHangCuaShop (TRƯỚC KHI ÁP VOUCHER) ===';
-- Mục đích: Xem doanh thu và thực thu ban đầu của SHOP0001. 
-- Chú ý cột 'Thành tiền' là tiền đơn hàng sau khi tính toán chiết khấu, voucher... các thứ, đây là tiền người mua phải trả.
-- Còn cột   'Thực thu' nó là tiền mà SHOP đó thực sự nhận được từ đơn hàng đấy, = giá ban đầu qua giảm giá chiết khấu(%) và áp dụng voucher Shop(Nếu có)
SELECT * FROM dbo.fn_LietKeDonHangCuaShop('SHOP0001');
GO

PRINT N'-----------------------------------------------------------------------';
PRINT N'=== TEST 2: FUNCTION fn_LayVoucherKhaDung (KIỂM TRA TÍNH TOÁN) ===';

-- Case 2.1: Test tính toán hợp lệ
-- Đơn hàng: ORDE0001 (Shop 1).
-- Voucher Shop: VCHR0001 (Giảm 10%). Voucher Ship: EXTR0001 (Freeship).
-- Mong đợi: Cột CoTheApDung = 1, tính ra số tiền giảm đúng.
PRINT N'> Case 2.1: Nhập Voucher Shop & Ship hợp lệ cho đơn ORDE0001';
SELECT * FROM dbo.fn_LayVoucherKhaDung('ORDE0001', 'VCHR0001', NULL, 'EXTR0001');

-- Case 2.2: Test tính toán không hợp lệ (Validation)
-- Đơn hàng: ORDE0001 (Shop 1).
-- Voucher Shop: VCHR0002 (Của Shop 2 -> Không được áp dụng cho Shop 1).
-- Mong đợi: Cột CoTheApDung = 0, Lý do: Mã voucher không tồn tại hoặc sai shop.
PRINT N'> Case 2.2: Cố tình nhập Voucher của Shop 2 (VCHR0002) cho đơn hàng Shop 1';
SELECT * FROM dbo.fn_LayVoucherKhaDung('ORDE0001', 'VCHR0002', NULL, NULL);
GO

PRINT N'-----------------------------------------------------------------------';
PRINT N'=== THỰC HIỆN UPDATE DỮ LIỆU (SIMULATE NGƯỜI DÙNG CHỐT ĐƠN) ===';
-- Gọi SP để lưu kết quả Voucher vào bảng AP_DUNG_MA_GIAM_GIA
-- Nếu không chạy bước này, hàm liệt kê đơn hàng sẽ không đổi số liệu.
EXEC dbo.sp_DatHang 
    @MaDonHang = 'ORDE0001', 
    @MaVoucherShop = 'VCHR0001', 
    @MaVoucherAdmin = NULL, 
    @MaVoucherTransport = 'EXTR0001';
PRINT N'Đã áp dụng Voucher VCHR0001 và EXTR0001 vào đơn ORDE0001.';
GO

PRINT N'-----------------------------------------------------------------------';
PRINT N'=== TEST 3: FUNCTION fn_LietKeDonHangCuaShop (SAU KHI ÁP VOUCHER) ===';
-- Mục đích: Kiểm tra lại SHOP0001.
-- Mong đợi: Tại dòng ORDE0001:
-- 1. 'ThanhTien' (Khách trả) giảm xuống do được trừ Voucher.
-- 2. 'ThucThu' (Shop nhận) bị giảm đi tương ứng với Voucher Shop (VCHR0001).
SELECT * FROM dbo.fn_LietKeDonHangCuaShop('SHOP0001');
GO