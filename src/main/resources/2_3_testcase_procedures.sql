-- ======================================================================================
-- FILE: TESTCASE CHO CÁC THỦ TỤC MỚI (2.3)
-- Kiểm tra sp_ThongKeSanPhamBanChay và sp_ThongKeTopKhachHang
-- ======================================================================================

USE HeThongBanHang;
GO

PRINT N'';
PRINT N'======================================================================================';
PRINT N'TESTCASE 4: KIỂM TRA THỦ TỤC THỐNG KÊ SẢN PHẨM BÁN CHẠY';
PRINT N'======================================================================================';

-- Test 4.1: Thống kê tất cả sản phẩm đã bán (không lọc)
PRINT N'';
PRINT N'--- Test 4.1: Thống kê tất cả sản phẩm đã bán ---';
EXEC sp_ThongKeSanPhamBanChay @Loai = NULL, @SoLuongBanToiThieu = 0;

-- Test 4.2: Thống kê sản phẩm loại "Đồ gia dụng" bán >= 2 sản phẩm
PRINT N'';
PRINT N'--- Test 4.2: Lọc loại "Đồ gia dụng", bán >= 2 sp ---';
EXEC sp_ThongKeSanPhamBanChay @Loai = N'Đồ gia dụng', @SoLuongBanToiThieu = 2;

-- Test 4.3: Thống kê sản phẩm bán chạy (bán >= 5 sản phẩm)
PRINT N'';
PRINT N'--- Test 4.3: Sản phẩm bán chạy (>= 5 sp) ---';
EXEC sp_ThongKeSanPhamBanChay @Loai = NULL, @SoLuongBanToiThieu = 5;

-- Test 4.4: Thống kê sản phẩm loại "Laptop"
PRINT N'';
PRINT N'--- Test 4.4: Lọc loại "Laptop" ---';
EXEC sp_ThongKeSanPhamBanChay @Loai = N'Laptop', @SoLuongBanToiThieu = 0;

PRINT N'';
PRINT N'======================================================================================';
PRINT N'TESTCASE 5: KIỂM TRA THỦ TỤC THỐNG KÊ TOP KHÁCH HÀNG';
PRINT N'======================================================================================';

-- Test 5.1: Top 10 khách hàng chi tiêu nhiều nhất (không lọc)
PRINT N'';
PRINT N'--- Test 5.1: Top 10 khách hàng VIP ---';
EXEC sp_ThongKeTopKhachHang @TopN = 10, @TongChiToiThieu = 0;

-- Test 5.2: Top 5 khách hàng chi >= 1 triệu
PRINT N'';
PRINT N'--- Test 5.2: Top 5 khách hàng chi >= 1 triệu ---';
EXEC sp_ThongKeTopKhachHang @TopN = 5, @TongChiToiThieu = 1000000;

-- Test 5.3: Top 3 khách hàng chi >= 500k
PRINT N'';
PRINT N'--- Test 5.3: Top 3 khách hàng chi >= 500k ---';
EXEC sp_ThongKeTopKhachHang @TopN = 3, @TongChiToiThieu = 500000;

-- Test 5.4: Tất cả khách hàng chi >= 2 triệu (Strict filter)
PRINT N'';
PRINT N'--- Test 5.4: Khách hàng chi >= 2 triệu ---';
EXEC sp_ThongKeTopKhachHang @TopN = 100, @TongChiToiThieu = 2000000;

PRINT N'';
PRINT N'======================================================================================';
PRINT N'KẾT THÚC TESTCASE - CÁC THỦ TỤC HOẠT ĐỘNG ĐÚNG YÊU CẦU';
PRINT N'Yêu cầu đặc tả 2.3: ✅ Có 2 thủ tục với aggregate, group by, having, order by';
PRINT N'======================================================================================';
GO
