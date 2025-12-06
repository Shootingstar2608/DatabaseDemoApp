-- ================= STORED PROCEDURES CHO PROJECT =================
USE HeThongBanHang;
GO

-- ---------------------------------------------------------------------------------------
-- THỦ TỤC 1: TRA CỨU SẢN PHẨM & THÔNG TIN CHỦ SHOP (Dùng cho Giao diện Quản Lý Sản Phẩm)
-- Độ phức tạp: Join 4 bảng (SAN_PHAM -> CUA_HANG -> NGUOI_BAN -> NGUOI_DUNG)
-- Chức năng: Tìm kiếm sản phẩm và hiển thị kèm thông tin người bán.
-- ---------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_TraCuuSanPham
    @MaSP VARCHAR(100) = NULL,
    @TenSP NVARCHAR(255) = NULL,
    @Loai NVARCHAR(100) = NULL,
    @Shop NVARCHAR(100) = NULL,
    @GiaMin DECIMAL(18,2) = NULL,
    @GiaMax DECIMAL(18,2) = NULL,
    @TuKhoa NVARCHAR(255) = NULL
-- Tham số tìm kiếm nhanh (Search All)
AS
BEGIN
    SELECT
        sp.MaSanPham,
        sp.TenSanPham,
        sp.GiaHienThi, -- Cột Giá hiển thị
        sp.Loai,
        sp.MaSoShop, -- Cột Mã Shop
        ch.Ten AS TenShop, -- Tên cửa hàng
        nd.HoVaTen AS TenChuShop, -- Tên chủ shop
        nd.Email AS EmailLienHe
    -- Email liên hệ
    FROM SAN_PHAM sp
        LEFT JOIN CUA_HANG ch ON sp.MaSoShop = ch.MaSoShop
        LEFT JOIN NGUOI_BAN nb ON ch.MaSoShop = nb.MaSoShop
        LEFT JOIN NGUOI_DUNG nd ON nb.TenDangNhap = nd.TenDangNhap
    WHERE 
        -- 1. Các bộ lọc chi tiết (giữ nguyên)
        (@MaSP IS NULL OR sp.MaSanPham LIKE '%' + @MaSP + '%')
        AND (@TenSP IS NULL OR sp.TenSanPham LIKE '%' + @TenSP + '%')
        AND (@Loai IS NULL OR sp.Loai LIKE '%' + @Loai + '%')
        AND (@Shop IS NULL OR (sp.MaSoShop LIKE '%' + @Shop + '%' OR ch.Ten LIKE '%' + @Shop + '%'))
        AND (@GiaMin IS NULL OR sp.GiaHienThi >= @GiaMin)
        AND (@GiaMax IS NULL OR sp.GiaHienThi <= @GiaMax)

        -- 2. Logic Tìm kiếm nhanh (@TuKhoa)
        AND (@TuKhoa IS NULL OR (
            sp.MaSanPham LIKE '%' + @TuKhoa + '%' OR
        sp.TenSanPham LIKE '%' + @TuKhoa + '%' OR
        sp.Loai LIKE '%' + @TuKhoa + '%' OR
        ch.Ten LIKE '%' + @TuKhoa + '%' OR
        -- THÊM MỚI: Tìm trong Giá hiển thị (Chuyển số thành chữ để tìm chuỗi)
        CAST(sp.GiaHienThi AS NVARCHAR(50)) LIKE '%' + @TuKhoa + '%'
        ))
    ORDER BY 
        sp.TenSanPham ASC;
END;
GO
-- Xử lý tham số NULL trong mệnh đề WHERE để tạo chức năng Tìm kiếm động (Dynamic Search). 
-- Người dùng nhập ô nào thì tìm ô đó, bỏ trống thì tìm tất cả, giúp trải nghiệm tìm kiếm linh hoạt hơn.



-- 2. Stored Procedure: Thêm sản phẩm (Trigger xử lý validation)
CREATE OR ALTER PROCEDURE sp_ThemSanPham
    @MaSanPham VARCHAR(100),
    @MaSoShop CHAR(8),
    @TenSanPham NVARCHAR(255),
    @ThongTinSanPham NVARCHAR(MAX),
    @LinkSanPham VARCHAR(500),
    @GiaHienThi DECIMAL(18,2),
    @Loai NVARCHAR(100)
AS
BEGIN
    BEGIN TRY
        -- Trigger TR_SanPham_KiemTraRangBuoc sẽ tự động validate trước khi INSERT
        INSERT INTO SAN_PHAM
        (MaSanPham, MaSoShop, TenSanPham, ThongTinSanPham, LinkSanPham, GiaHienThi, Loai)
    VALUES
        (@MaSanPham, @MaSoShop, @TenSanPham, @ThongTinSanPham, @LinkSanPham, @GiaHienThi, @Loai);

        PRINT N'✅ Thêm sản phẩm thành công!';
    END TRY
    BEGIN CATCH
        -- Trigger sẽ RAISERROR nếu validation thất bại
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

-- 3. Stored Procedure: Cập nhật sản phẩm (Trigger xử lý validation)
CREATE OR ALTER PROCEDURE sp_CapNhatSanPham
    @MaSanPham VARCHAR(100),
    @TenSanPham NVARCHAR(255) = NULL,
    @ThongTinSanPham NVARCHAR(MAX) = NULL,
    @GiaHienThi DECIMAL(18,2) = NULL,
    @Loai NVARCHAR(100) = NULL
AS
BEGIN
    BEGIN TRY
        -- Trigger TR_SanPham_KiemTraRangBuoc sẽ tự động validate trước khi UPDATE
        UPDATE SAN_PHAM
        SET 
            TenSanPham = ISNULL(@TenSanPham, TenSanPham),
            ThongTinSanPham = ISNULL(@ThongTinSanPham, ThongTinSanPham),
            GiaHienThi = ISNULL(@GiaHienThi, GiaHienThi),
            Loai = ISNULL(@Loai, Loai)
        WHERE MaSanPham = @MaSanPham;

        PRINT N'✅ Cập nhật sản phẩm thành công!';
    END TRY
    BEGIN CATCH
        -- Trigger sẽ RAISERROR nếu validation thất bại
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

-- 4. Stored Procedure: Xóa sản phẩm (Trigger xử lý validation & cascading delete)
CREATE OR ALTER PROCEDURE sp_XoaSanPham
    @MaSanPham VARCHAR(100)
AS
BEGIN
    BEGIN TRY
        -- Trigger TR_SanPham_KiemTraTruocKhiXoa sẽ tự động:
        -- 1. Kiểm tra có trong đơn hàng không
        -- 2. Xóa cascading (LINK_ANH, DANH_GIA, BIEN_THE, v.v.)
        DELETE FROM SAN_PHAM WHERE MaSanPham = @MaSanPham;

        PRINT N'✅ Xóa sản phẩm thành công!';
    END TRY
    BEGIN CATCH
        -- Trigger sẽ RAISERROR nếu validation thất bại
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

-- ---------------------------------------------------------------------------------------
-- THỦ TỤC 5: THỐNG KÊ DOANH THU CỦA SHOP (Dùng cho Báo cáo Doanh số)
-- Độ phức tạp: Aggregate (SUM, COUNT), GROUP BY, HAVING, WHERE, ORDER BY + Join 4 bảng
-- Chức năng: Tính tổng doanh thu theo năm của từng Shop, kèm thông tin liên hệ chủ shop.
-- ---------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_ThongKeDoanhThuShop
    @Nam INT,
    -- Tham số lọc theo Năm (WHERE)
    @DoanhThuToiThieu DECIMAL(18,2)
-- Tham số lọc doanh thu sàn (HAVING)
AS
BEGIN
    SELECT
        ch.MaSoShop,
        ch.Ten AS TenShop,
        nd.HoVaTen AS TenChuShop,
        nd.SoDienThoai AS SDT_LienHe,
        COUNT(dh.MaDonHang) AS SoLuongDonHang, -- Đếm tổng đơn
        SUM(dh.GiaBanDau) AS TongDoanhThu
    -- Tính tổng tiền bán (Aggregate Function)
    FROM DON_HANG dh
        -- 1. Join sang Cửa Hàng
        JOIN CUA_HANG ch ON dh.MaSoShop = ch.MaSoShop
        -- 2. Join sang Người Bán (Chủ shop)
        JOIN NGUOI_BAN nb ON ch.MaSoShop = nb.MaSoShop
        -- 3. Join sang Người Dùng (Lấy tên, sđt chủ shop)
        JOIN NGUOI_DUNG nd ON nb.TenDangNhap = nd.TenDangNhap
    WHERE 
        YEAR(dh.ThoiGianDatHang) = @Nam
    -- Lọc theo năm
    GROUP BY 
        ch.MaSoShop, ch.Ten, nd.HoVaTen, nd.SoDienThoai
    HAVING 
        SUM(dh.GiaBanDau) >= @DoanhThuToiThieu
    -- Chỉ lấy shop đạt KPI doanh thu
    ORDER BY 
        TongDoanhThu DESC;
-- Sắp xếp shop nào giàu nhất lên đầu
END;
GO

-- ---------------------------------------------------------------------------------------
-- THỦ TỤC 6: THỐNG KÊ SẢN PHẨM BÁN CHẠY THEO LOẠI (Thủ tục thứ 2 cho 2.3)
-- Độ phức tạp: Aggregate (COUNT, SUM), GROUP BY, HAVING, WHERE, ORDER BY + Join 3 bảng
-- Chức năng: Thống kê sản phẩm bán chạy nhất theo từng loại, lọc theo số lượng bán tối thiểu
-- ---------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_ThongKeSanPhamBanChay
    @Loai NVARCHAR(100) = NULL,
    -- Lọc theo loại sản phẩm (WHERE)
    @SoLuongBanToiThieu INT = 0
-- Lọc sản phẩm bán ít nhất bao nhiêu (HAVING)
AS
BEGIN
    SELECT
        sp.Loai AS LoaiSanPham,
        sp.MaSanPham,
        sp.TenSanPham,
        ch.Ten AS TenShop,
        COUNT(DISTINCT dh.MaDonHang) AS SoDonHang, -- Đếm số đơn hàng
        SUM(dh.SoLuongCuaBienThe) AS TongSoLuongDaBan, -- Tổng số lượng bán
        AVG(sp.GiaHienThi) AS GiaTrungBinh, -- Giá trung bình
        SUM(dh.GiaBanDau) AS TongDoanhThu
    -- Tổng doanh thu (Aggregate)
    FROM SAN_PHAM sp
        -- 1. Join sang Đơn hàng (qua Biến thể)
        LEFT JOIN BIEN_THE_SAN_PHAM bt ON sp.MaSanPham = bt.MaSanPham
        LEFT JOIN DON_HANG dh ON bt.ID = dh.ID_BienThe AND bt.MaSanPham = dh.MaSanPham_BienThe
        -- 2. Join sang Cửa hàng
        LEFT JOIN CUA_HANG ch ON sp.MaSoShop = ch.MaSoShop
    WHERE 
        (@Loai IS NULL OR sp.Loai = @Loai)
    -- Lọc theo loại (WHERE)
    GROUP BY 
        sp.Loai, sp.MaSanPham, sp.TenSanPham, ch.Ten
    HAVING 
        SUM(dh.SoLuongCuaBienThe) >= @SoLuongBanToiThieu
    -- Chỉ lấy sản phẩm bán >= số lượng tối thiểu (HAVING)
    ORDER BY 
        TongSoLuongDaBan DESC, TongDoanhThu DESC;
-- Sắp xếp theo số lượng bán nhiều nhất
END;
GO

-- ---------------------------------------------------------------------------------------
-- THỦ TỤC 7: THỐNG KÊ TOP KHÁCH HÀNG MUA NHIỀU NHẤT (Thủ tục bổ sung)
-- Độ phức tạp: Aggregate (COUNT, SUM, AVG), GROUP BY, HAVING, ORDER BY + Join 2 bảng
-- Chức năng: Xếp hạng khách hàng theo số đơn và tổng chi tiêu, lọc theo tổng chi tối thiểu
-- ---------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_ThongKeTopKhachHang
    @TopN INT = 10,
    -- Lấy Top bao nhiêu khách hàng
    @TongChiToiThieu DECIMAL(18,2) = 0
-- Lọc khách hàng chi ít nhất bao nhiêu (HAVING)
AS
BEGIN
    SELECT TOP (@TopN)
        nm.TenDangNhap,
        nd.HoVaTen,
        nd.Email,
        nd.SoDienThoai,
        COUNT(dh.MaDonHang) AS SoDonHang, -- Đếm tổng đơn
        SUM(dh.GiaBanDau) AS TongChiTieu, -- Tổng tiền chi (Aggregate)
        AVG(dh.GiaBanDau) AS GiaTriDonTrungBinh, -- Giá trị đơn trung bình
        nm.SoXuApp AS DiemTichLuy
    FROM NGUOI_MUA nm
        -- 1. Join sang Người dùng (Lấy thông tin cá nhân)
        INNER JOIN NGUOI_DUNG nd ON nm.TenDangNhap = nd.TenDangNhap
        -- 2. Join sang Đơn hàng
        LEFT JOIN DON_HANG dh ON nm.TenDangNhap = dh.TenDangNhapNguoiMua
    GROUP BY 
        nm.TenDangNhap, nd.HoVaTen, nd.Email, nd.SoDienThoai, nm.SoXuApp
    HAVING 
        SUM(dh.GiaBanDau) >= @TongChiToiThieu
    -- Chỉ lấy khách hàng chi >= số tiền tối thiểu
    ORDER BY 
        TongChiTieu DESC, SoDonHang DESC;
-- Sắp xếp theo tổng chi nhiều nhất
END;
GO

PRINT 'Đã tạo xong các Stored Procedures!';

-- ================= TEST STORED PROCEDURES =================
-- Test 1: Tra cứu sản phẩm Laptop
-- EXEC sp_TraCuuSanPham @Loai = N'Laptop';

-- Test 2: Thống kê Doanh thu các shop trong năm 2025, chỉ hiện shop có doanh thu > 1 triệu
-- EXEC sp_ThongKeDoanhThuShop @Nam = 2025, @DoanhThuToiThieu = 1000000;

-- Test 3: Thống kê sản phẩm bán chạy nhất (bán >= 2 sản phẩm)
-- EXEC sp_ThongKeSanPhamBanChay @Loai = NULL, @SoLuongBanToiThieu = 2;

-- Test 4: Top 5 khách hàng chi tiêu nhiều nhất (chi >= 100k)
-- EXEC sp_ThongKeTopKhachHang @TopN = 5, @TongChiToiThieu = 100000;
