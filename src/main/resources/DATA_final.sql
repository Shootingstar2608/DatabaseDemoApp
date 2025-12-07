-- ================= PHẦN 1: RESET DATABASE (XÓA CŨ TẠO MỚI) =================
USE master;
GO
IF EXISTS (SELECT name
FROM sys.databases
WHERE name = 'HeThongBanHang')
BEGIN
    ALTER DATABASE HeThongBanHang SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE HeThongBanHang;
END
GO
CREATE DATABASE HeThongBanHang;
GO
USE HeThongBanHang;
GO


CREATE TABLE NGUOI_DUNG
(
    TenDangNhap VARCHAR(100) PRIMARY KEY,
    MatKhau VARCHAR(255) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    SoDienThoai VARCHAR(20) NOT NULL UNIQUE,
    HoVaTen NVARCHAR(255) NOT NULL,
    NgaySinh DATE,
    GioiTinh NVARCHAR(10) CHECK (GioiTinh IN (N'Nam', N'Nữ', N'Khác')),
    LinkAnhDaiDien VARCHAR(255),
    TrangThai VARCHAR(50) NOT NULL DEFAULT 'Active',
    NgayTaoTaiKhoan DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE THEO_DOI
(
    TenDangNhapNguoiTheoDoi VARCHAR(100),
    TenDangNhapNguoiBiTheoDoi VARCHAR(100) NOT NULL,
    PRIMARY KEY (TenDangNhapNguoiTheoDoi, TenDangNhapNguoiBiTheoDoi),
    FOREIGN KEY (TenDangNhapNguoiTheoDoi) REFERENCES NGUOI_DUNG(TenDangNhap),
    FOREIGN KEY (TenDangNhapNguoiBiTheoDoi) REFERENCES NGUOI_DUNG(TenDangNhap)
);

CREATE TABLE TAI_KHOAN_NGAN_HANG
(
    TenDangNhap VARCHAR(100) NOT NULL,
    SoTaiKhoan VARCHAR(15) NOT NULL,
    TenNganHang NVARCHAR(100) NOT NULL,
    LoaiThe VARCHAR(50) NOT NULL,
    PRIMARY KEY (TenDangNhap, SoTaiKhoan, TenNganHang, LoaiThe),
    FOREIGN KEY (TenDangNhap) REFERENCES NGUOI_DUNG(TenDangNhap),
    UNIQUE(TenDangNhap, SoTaiKhoan)
);

CREATE TABLE LIEN_KET_MANG_XA_HOI
(
    TenDangNhap VARCHAR(100) NOT NULL,
    LienKetMangXaHoi VARCHAR(255) NOT NULL,
    PRIMARY KEY (TenDangNhap, LienKetMangXaHoi),
    FOREIGN KEY (TenDangNhap) REFERENCES NGUOI_DUNG(TenDangNhap)
);

CREATE TABLE DIA_CHI
(
    TenDangNhap VARCHAR(100) NOT NULL,
    DiaChi NVARCHAR(255) NOT NULL,
    PRIMARY KEY (TenDangNhap, DiaChi),
    FOREIGN KEY (TenDangNhap) REFERENCES NGUOI_DUNG(TenDangNhap)
);

CREATE TABLE QUAN_TRI_VIEN
(
    TenDangNhap VARCHAR(100) PRIMARY KEY,
    MucQuyenHan VARCHAR(100) NOT NULL,
    LanDangNhapCuoi DATETIME,
    FOREIGN KEY (TenDangNhap) REFERENCES NGUOI_DUNG(TenDangNhap)
);

CREATE TABLE CUA_HANG
(
    MaSoShop CHAR(8) PRIMARY KEY,
    DanhHieu NVARCHAR(31),
    Ten NVARCHAR(63) NOT NULL,
    MoTa NVARCHAR(511),
    LinkAnhDaiDien VARCHAR(1023),
    LinkShop VARCHAR(1023) NOT NULL,
    ThoiGianThamGia DATETIME NOT NULL,
    DiaChiDangKy NVARCHAR(1023) NOT NULL,
    MaSoThue VARCHAR(20) UNIQUE,
    LoaiHinhKinhDoanh NVARCHAR(255) NOT NULL,
    TenDangNhapQuanTriVien VARCHAR(100),
    FOREIGN KEY (TenDangNhapQuanTriVien) REFERENCES QUAN_TRI_VIEN(TenDangNhap)
);

CREATE TABLE SAN_PHAM
(
    MaSanPham VARCHAR(100) PRIMARY KEY,
    MaSoShop CHAR(8) NOT NULL,
    TenSanPham NVARCHAR(255) NOT NULL CHECK (LEN(LTRIM(RTRIM(TenSanPham))) > 0),
    ThongTinSanPham NVARCHAR(511),
    LinkSanPham VARCHAR(511) UNIQUE,
    GiaHienThi DECIMAL(18, 2) NOT NULL CHECK (GiaHienThi > 0),
    Loai NVARCHAR(100) NOT NULL CHECK (LEN(LTRIM(RTRIM(Loai))) > 0),
    SoSaoSanPham DECIMAL(3,2) DEFAULT 0 CHECK (SoSaoSanPham >= 0 AND SoSaoSanPham <= 5),
    FOREIGN KEY (MaSoShop) REFERENCES CUA_HANG(MaSoShop)
);

CREATE TABLE LINK_ANH_VIDEO_SAN_PHAM
(
    MaSanPham VARCHAR(100) NOT NULL,
    LinkAnhVideo VARCHAR(255) NOT NULL,
    PRIMARY KEY (MaSanPham, LinkAnhVideo),
    FOREIGN KEY (MaSanPham) REFERENCES SAN_PHAM(MaSanPham)
);

CREATE TABLE DUYET_SAN_PHAM
(
    QuanTriVien VARCHAR(100) NOT NULL,
    MaSanPham VARCHAR(100) NOT NULL PRIMARY KEY,
    FOREIGN KEY (QuanTriVien) REFERENCES QUAN_TRI_VIEN(TenDangNhap),
    FOREIGN KEY (MaSanPham) REFERENCES SAN_PHAM(MaSanPham)
);

CREATE TABLE NGUOI_BAN
(
    TenDangNhap VARCHAR(100) PRIMARY KEY,
    MaSoShop CHAR(8),
    FOREIGN KEY (TenDangNhap) REFERENCES NGUOI_DUNG(TenDangNhap),
    FOREIGN KEY (MaSoShop) REFERENCES CUA_HANG(MaSoShop)
);

CREATE TABLE CHAN_NGUOI_BAN
(
    QuanTriVien VARCHAR(100) NOT NULL,
    NguoiBan VARCHAR(100) NOT NULL,
    Time_Stamp DATETIME NOT NULL DEFAULT GETDATE(),
    TrangThai NVARCHAR(50) CHECK (TrangThai IN (N'Chặn', N'Gỡ chặn')),
    LyDo NVARCHAR(MAX),
    PRIMARY KEY (QuanTriVien, NguoiBan),
    FOREIGN KEY (QuanTriVien) REFERENCES QUAN_TRI_VIEN(TenDangNhap),
    FOREIGN KEY (NguoiBan) REFERENCES NGUOI_BAN(TenDangNhap)
);

CREATE TABLE NGUOI_MUA
(
    TenDangNhap VARCHAR(100) PRIMARY KEY,
    SoXuApp INT DEFAULT 0,
    FOREIGN KEY (TenDangNhap) REFERENCES NGUOI_DUNG(TenDangNhap)
);

CREATE TABLE CHAN_NGUOI_MUA
(
    QuanTriVien VARCHAR(100) NOT NULL,
    NguoiMua VARCHAR(100) NOT NULL,
    Time_Stamp DATETIME NOT NULL DEFAULT GETDATE(),
    TrangThai NVARCHAR(50) CHECK (TrangThai IN (N'Chặn', N'Gỡ chặn')),
    LyDo NVARCHAR(MAX),
    PRIMARY KEY (QuanTriVien, NguoiMua),
    FOREIGN KEY (QuanTriVien) REFERENCES QUAN_TRI_VIEN(TenDangNhap),
    FOREIGN KEY (NguoiMua) REFERENCES NGUOI_MUA(TenDangNhap)
);

CREATE TABLE NHAN_TIN
(
    NguoiGui VARCHAR(100) NOT NULL,
    NguoiNhan VARCHAR(100) NOT NULL,
    ThoiGianGui DATETIME NOT NULL DEFAULT GETDATE(),
    NoiDungTinNhan NVARCHAR(MAX) NOT NULL,
    PRIMARY KEY (NguoiGui, NguoiNhan, ThoiGianGui),
    FOREIGN KEY (NguoiGui) REFERENCES NGUOI_DUNG(TenDangNhap),
    FOREIGN KEY (NguoiNhan) REFERENCES NGUOI_DUNG(TenDangNhap)
);

CREATE TABLE TO_CAO
(
    MaSoShop CHAR(8) NOT NULL,
    TenDangNhapNguoiMua VARCHAR(100) NOT NULL,
    LyDoToCao NVARCHAR(MAX),
    Time_Stamp DATETIME NOT NULL DEFAULT GETDATE(),
    TrangThaiXuLy NVARCHAR(50) DEFAULT N'Chờ xử lý' CHECK (TrangThaiXuLy IN (N'Chờ xử lý', N'Đã xử lý', N'Từ chối')),
    PRIMARY KEY (MaSoShop, TenDangNhapNguoiMua),
    FOREIGN KEY (MaSoShop) REFERENCES CUA_HANG(MaSoShop),
    FOREIGN KEY (TenDangNhapNguoiMua) REFERENCES NGUOI_MUA(TenDangNhap)
);

-- CREATE TABLE MA_GIAM_GIA
-- (
--     MaVoucher CHAR(8) PRIMARY KEY,
--     TenVoucher VARCHAR(50) NOT NULL,
--     LuotSuDungConLai INT NOT NULL DEFAULT 1,
--     GiamTheoPhanTram DECIMAL(5, 2),
--     GiamTheoLuongTien INT,
--     MucGiamToiDa INT NOT NULL,
--     MucGiamToiThieu INT NOT NULL DEFAULT 0,
--     TenDangNhapQuanTriVien VARCHAR(100) NOT NULL,
--     MaSoShop CHAR(8) NOT NULL,
--     FOREIGN KEY (TenDangNhapQuanTriVien) REFERENCES QUAN_TRI_VIEN(TenDangNhap),
--     FOREIGN KEY (MaSoShop) REFERENCES CUA_HANG(MaSoShop)
-- );

CREATE TABLE MA_GIAM_GIA
(
    MaVoucher CHAR(8) PRIMARY KEY,
    TenVoucher VARCHAR(50) NOT NULL,
    -- Người tạo Voucher
    NguoiTao VARCHAR(20) NOT NULL DEFAULT 'ADMIN',-- ('ADMIN','SHOP','TRANSPORT') thực tế Vận chuyển đa phần là do ADMIN và SHOP, nhưng vẫn cần phân biệt 3 loại voucher
    LuotSuDungConLai INT NOT NULL DEFAULT 1,
    GiamTheoPhanTram DECIMAL(5, 2) NULL,
    GiamTheoLuongTien INT NULL,
    MucGiamToiDa INT NULL,
    MucGiamToiThieu INT NOT NULL DEFAULT 0,
    TenDangNhapQuanTriVien VARCHAR(100) NULL,
    MaSoShop CHAR(8) NULL,-- đây t set cái mã số Shop và quản trị viên về NULL là do có thể mã được tạo bởi admin hoặc bởi shop -> xài constraint kiểm tra
    FOREIGN KEY (TenDangNhapQuanTriVien) REFERENCES QUAN_TRI_VIEN(TenDangNhap),
    FOREIGN KEY (MaSoShop)               REFERENCES CUA_HANG(MaSoShop),
    CONSTRAINT CHK_MGG_NguoiTao          CHECK (NguoiTao IN ('ADMIN','SHOP','TRANSPORT')),
    CONSTRAINT CHK_MGG_Shop_Admin        CHECK (
        (NguoiTao = 'SHOP' AND MaSoShop               IS NOT NULL AND TenDangNhapQuanTriVien IS NULL) OR
        (NguoiTao = 'ADMIN' AND TenDangNhapQuanTriVien IS NOT NULL AND MaSoShop               IS NULL) OR
        (NguoiTao = 'TRANSPORT' AND TenDangNhapQuanTriVien IS NULL AND MaSoShop               IS NULL)-- cho phép SHIPPER không bắt buộc 2 trường kia
    ),
    -- Ràng buộc chế độ giảm: chỉ 1 trong 2 kiểu được dùng
    CONSTRAINT CHK_MGG_DiscountMode CHECK (
        (GiamTheoPhanTram IS NOT NULL AND GiamTheoLuongTien IS NULL)
        OR
        (GiamTheoLuongTien IS NOT NULL AND GiamTheoPhanTram IS NULL AND MucGiamToiDa IS NULL)
    )

);

CREATE TABLE MAT_HANG_AP_DUNG
(
    MaVoucher CHAR(8) NOT NULL,
    MatHangApDung VARCHAR(50) NOT NULL,
    PRIMARY KEY (MaVoucher, MatHangApDung),
    FOREIGN KEY (MaVoucher) REFERENCES MA_GIAM_GIA(MaVoucher)
);

CREATE TABLE DANH_GIA
(
    MaDanhGia VARCHAR(100),
    MaSanPham VARCHAR(100) NOT NULL,
    TenDangNhapNguoiMua VARCHAR(100) NOT NULL,
    MaSoShop CHAR(8) NOT NULL,
    SoSao INT CHECK (SoSao >= 1 AND SoSao <= 5),
    NoiDung NVARCHAR(MAX),
    NgayDanhGia DATETIME NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (MaDanhGia, MaSanPham, TenDangNhapNguoiMua ),
    FOREIGN KEY (MaSanPham) REFERENCES SAN_PHAM(MaSanPham),
    FOREIGN KEY (TenDangNhapNguoiMua) REFERENCES NGUOI_MUA(TenDangNhap),
    FOREIGN KEY (MaSoShop) REFERENCES CUA_HANG(MaSoShop)
);

-- CREATE TABLE LINK_ANH_VIDEO_DANH_GIA
-- (
--     MaDanhGia VARCHAR(100) NOT NULL,
--     LinkAnhVideo VARCHAR(255) NOT NULL,
--     PRIMARY KEY (MaDanhGia, LinkAnhVideo),
--     FOREIGN KEY (MaDanhGia) REFERENCES DANH_GIA(MaDanhGia)
-- );

CREATE TABLE LINK_ANH_VIDEO_DANH_GIA
(
    MaDanhGia VARCHAR(100) NOT NULL,
    MaSanPham VARCHAR(100) NOT NULL,
    -- Thêm cột này
    TenDangNhapNguoiMua VARCHAR(100) NOT NULL,
    -- Thêm cột này
    LinkAnhVideo VARCHAR(255) NOT NULL,
    PRIMARY KEY (MaDanhGia, MaSanPham, TenDangNhapNguoiMua, LinkAnhVideo),
    FOREIGN KEY (MaDanhGia, MaSanPham, TenDangNhapNguoiMua) REFERENCES DANH_GIA(MaDanhGia, MaSanPham, TenDangNhapNguoiMua)
);

CREATE TABLE BIEN_THE_SAN_PHAM
(
    ID VARCHAR(100) NOT NULL,
    MaSanPham VARCHAR(100) NOT NULL,
    SoLuongTrongKho INT DEFAULT 0,
    Ten NVARCHAR(255),
    PRIMARY KEY (ID, MaSanPham),
    FOREIGN KEY (MaSanPham) REFERENCES SAN_PHAM(MaSanPham)
);

CREATE TABLE THONG_TIN_BIEN_THE
(
    ID VARCHAR(100) NOT NULL,
    MaSanPham VARCHAR(100) NOT NULL,
    KichCo NVARCHAR(50) NOT NULL,
    Loai NVARCHAR(50) NOT NULL,
    Gia DECIMAL(18, 2) NOT NULL,
    PRIMARY KEY (ID, MaSanPham, KichCo, Loai, Gia),
    FOREIGN KEY (ID, MaSanPham) REFERENCES BIEN_THE_SAN_PHAM(ID, MaSanPham)
);

CREATE TABLE GIO_HANG
(
    MaSoGioHang CHAR(8) PRIMARY KEY,
    TenDangNhapNguoiMua VARCHAR(100) NOT NULL,
    FOREIGN KEY (TenDangNhapNguoiMua) REFERENCES NGUOI_MUA(TenDangNhap)
);

CREATE TABLE GIO_HANG_CHUA
(
    MaSoGioHang CHAR(8) NOT NULL,
    ID_BienThe VARCHAR(100) NOT NULL,
    MaSanPham VARCHAR(100) NOT NULL,
    SoLuong INT NOT NULL DEFAULT 1 CHECK (SoLuong > 0),
    PRIMARY KEY (MaSoGioHang, ID_BienThe, MaSanPham),
    FOREIGN KEY (MaSoGioHang) REFERENCES GIO_HANG(MaSoGioHang),
    FOREIGN KEY (ID_BienThe, MaSanPham) REFERENCES BIEN_THE_SAN_PHAM(ID, MaSanPham)
);

CREATE TABLE DON_VI_VAN_CHUYEN
(
    TenDonVi VARCHAR(50) NOT NULL,
    MaDonVi CHAR(8) PRIMARY KEY
);

CREATE TABLE PHUONG_THUC_VAN_CHUYEN
(
    MaDonVi CHAR(8) NOT NULL,
    PhuongThucVanChuyen NVARCHAR(50) NOT NULL,
    PRIMARY KEY (MaDonVi, PhuongThucVanChuyen),
    FOREIGN KEY (MaDonVi) REFERENCES DON_VI_VAN_CHUYEN(MaDonVi)
);

CREATE TABLE DON_HANG
(
    MaDonHang CHAR(8) PRIMARY KEY,
    PhuongThucVanChuyen NVARCHAR(63) NOT NULL,
    TrangThai NVARCHAR(31) NOT NULL,
    DiaChiLayHang NVARCHAR(1023) NOT NULL,
    DiaChiGiaoHang NVARCHAR(1023) NOT NULL,
    PhuongThucThanhToan VARCHAR(63) NOT NULL,
    ThoiGianDatHang DATETIME NOT NULL,
    ThoiGianGiaoDuKien DATETIME NOT NULL,
    ThoiGianHoanThanhDon DATETIME,
    ThoiGianThanhToan DATETIME,
    -- GiaKhuyenMai INT NOT NULL,
    ChietKhau INT NOT NULL,
    GiaBanDau INT NOT NULL,
    GiaVanChuyen INT NOT NULL,
    MaSoShop CHAR(8) NOT NULL,
    TenDangNhapNguoiMua VARCHAR(100) NOT NULL,
    ID_BienThe VARCHAR(100) NOT NULL,
    MaSanPham_BienThe VARCHAR(100) NOT NULL,
    SoLuongCuaBienThe INT NOT NULL CHECK (SoLuongCuaBienThe > 0),
    MaDonViVanChuyen CHAR(8),

    FOREIGN KEY (MaSoShop) REFERENCES CUA_HANG(MaSoShop),
    FOREIGN KEY (TenDangNhapNguoiMua) REFERENCES NGUOI_MUA(TenDangNhap),
    FOREIGN KEY (ID_BienThe, MaSanPham_BienThe) REFERENCES BIEN_THE_SAN_PHAM(ID, MaSanPham),
    FOREIGN KEY (MaDonViVanChuyen) REFERENCES DON_VI_VAN_CHUYEN(MaDonVi)
);

CREATE TABLE GIAO_DICH
(
    MaGiaoDich VARCHAR(100) NOT NULL,
    MaDonHang CHAR(8) NOT NULL,
    TenDangNhapNguoiMua VARCHAR(100) NOT NULL,
    TenDangNhapNguoiBan VARCHAR(100) NOT NULL,
    PhuongThucThanhToan NVARCHAR(63) NOT NULL,
    TienGiaoDich DECIMAL(18, 2) NOT NULL,
    ThoiGianGiaoDich DATETIME NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (MaGiaoDich, MaDonHang, TenDangNhapNguoiMua, TenDangNhapNguoiBan),
    FOREIGN KEY (MaDonHang) REFERENCES DON_HANG(MaDonHang),
    FOREIGN KEY (TenDangNhapNguoiMua) REFERENCES NGUOI_MUA(TenDangNhap),
    FOREIGN KEY (TenDangNhapNguoiBan) REFERENCES NGUOI_BAN(TenDangNhap)
);

CREATE TABLE AP_DUNG_MA_GIAM_GIA
(
    MaVoucher CHAR(8) NOT NULL,
    MaDonHang CHAR(8) NOT NULL,
    PRIMARY KEY (MaVoucher, MaDonHang),
    FOREIGN KEY (MaVoucher) REFERENCES MA_GIAM_GIA(MaVoucher),
    FOREIGN KEY (MaDonHang) REFERENCES DON_HANG(MaDonHang)
);

-- ================= PHẦN 3: INSERT DỮ LIỆU (ĐÃ THÊM CHỮ N) =================

INSERT INTO NGUOI_DUNG
    (TenDangNhap, MatKhau, Email, SoDienThoai, HoVaTen, NgaySinh, GioiTinh, LinkAnhDaiDien, TrangThai)
VALUES
    ('phanphucthinh', 'anhdadenyeunuoc@123', 'phanphucthinh_2313306@hcmut.edu.vn', '0900003306', N'PHAN PHÚC THỊNH', '2005-11-17', N'Nam', 'avatar_thinh.jpg', 'Active'),
    ('nguyenngocton', 'dungLamtraitimanhdau@5702', 'nguyenngocton_2313508@hcmut.edu.vn', '0900003508', N'NGUYỄN NGỌC TÔN', '2005-11-18', N'Nam', 'avatar_ton.jpg', 'Active'),
    ('dohongphuc', 'mAimai1tinheo@', 'dohongphuc_2312672@hcmut.edu.vn', '0900002672', N'ĐỖ HỒNG PHÚC', '2005-11-19', N'Nam', 'avatar_phuc.jpg', 'Active'),
    ('letrongtin', 'moonpaRk@36', 'letrongtin_2313452@hcmut.edu.vn', '0900003452', N'LÊ TRỌNG TÍN', '2005-11-20', N'Nam', 'avatar_tin.jpg', 'Active'),
    ('quynhtrang', 'lovisonG@102', 'phanngocquynhtrang_2313518@hcmut.edu.vn', '0900003518', N'PHAN NGỌC QUỲNH TRANG', '2005-11-22', N'Nữ', 'avatar_trang.jpg', 'Active'),
    ('ngominhtri', 'thaynhoDiemMy@11', 'ngominhtri_2313636@hcmut.edu.vn', '0900003636', N'NGÔ MINH TRÍ', '2005-11-10', N'Nam', 'avatar_tri.jpg', 'Active'),
    ('maitrithuc', 'gheminHminHthung09@', 'maitrithuc@gmail.edu.vn', '0949215278', N'MAI TRÍ THỨC', '1995-11-5', N'Nam', 'avatar_tri_thuc.jpg', 'Active'),
    ('phuonghang_dainam', 'daIGiamienTay@oo1', 'phuonghang@hcmut.edu.vn', '0911111111', N'NGUYỄN PHƯƠNG HẰNG', '1971-01-26', N'Nữ', 'avatar_ceo.jpg', 'Active'),
    ('j97_domdom', 'MaifananhJack03@idolcuaem', 'jack_j97@hcmut.edu.vn', '0911111112', N'TRỊNH TRẦN PHƯƠNG TUẤN', '1997-04-12', N'Nam', 'avatar_jack.jpg', 'Active'),
    ('khabanh_miai', 'anhKhadaquaydau@08', 'khabanh@hcmut.edu.vn', '0911111113', N'NGÔ BÁ KHÁ', '1993-11-27', N'Nam', 'avatar_kha.jpg', 'Active'),
    ('mailisa_phan', 'luadaolamtuthIen@2025', 'mailisa@gmail.com', '0922222221', N'PHAN THỊ MAI', '1980-05-10', N'Nữ', 'avatar_mai.jpg', 'Active'),
    ('luongbangquang', 'nucuoItutin@25', 'lbqmusic@gmail.com', '0922222222', N'LƯƠNG BẰNG QUANG', '1982-01-28', N'Nam', 'avatar_lbq.jpg', 'Active'),
    ('thuytien_miss', 'keokerAnlae@24', 'thuytien@gmail.com', '0933333331', N'NGUYỄN THÚC THUỲ TIÊN', '1998-08-12', N'Nữ', 'avatar_tien.jpg', 'Active'),
    ('viethuong_hai', 'danHhaimientaY02@', 'viethuong@gmail.com', '0933333332', N'NGUYỄN VIỆT HƯƠNG', '1976-10-15', N'Nữ', 'avatar_huong.jpg', 'Active'),
    ('chidan_singer', 'DieuanHbiet@04', 'chidan@gmail.com', '0933333333', N'NGUYỄN CHI DÂN', '1989-06-02', N'Nam', 'avatar_chidan.jpg', 'Active'),
    ('ngan98_dj', 'nyanhQuanG@25', 'ngan98@gmail.com', '0933333334', N'VÕ NGỌC NGÂN', '1998-03-06', N'Nữ', 'avatar_ngan.jpg', 'Active');
GO

INSERT INTO THEO_DOI
    (TenDangNhapNguoiTheoDoi, TenDangNhapNguoiBiTheoDoi)
VALUES
    ('dohongphuc', 'phanphucthinh'),
    ('quynhtrang', 'phanphucthinh'),
    ('quynhtrang', 'letrongtin'),
    ('letrongtin', 'nguyenngocton'),
    ('ngominhtri', 'nguyenngocton'),
    ('maitrithuc', 'nguyenngocton'),
    ('phanphucthinh', 'nguyenngocton'),
    ('thuytien_miss', 'mailisa_phan'),
    ('ngan98_dj', 'luongbangquang'),
    ('chidan_singer', 'j97_domdom'),
    ('viethuong_hai', 'phuonghang_dainam'),
    ('dohongphuc', 'ngan98_dj'),
    ('letrongtin', 'thuytien_miss'),
    ('phanphucthinh', 'khabanh_miai'),
    ('nguyenngocton', 'j97_domdom'),
    ('phuonghang_dainam', 'mailisa_phan'),
    ('luongbangquang', 'ngan98_dj');        
GO

INSERT INTO TAI_KHOAN_NGAN_HANG
    (TenDangNhap, SoTaiKhoan, TenNganHang, LoaiThe)
VALUES
    ('phanphucthinh', '12345678', N'Vietcombank', 'Debit'),
    ('nguyenngocton', '23456789', N'ACB', 'Credit'),
    ('dohongphuc', '34567890', N'Technical Bank', 'Debit'),
    ('letrongtin', '45678901', N'BIDV', 'Debit'),
    ('quynhtrang', '56789012', N'SacomBank', 'Credit'),
    ('maitrithuc', '23423423', N'SacomBank', 'Dedit'),
    ('ngominhtri', '3600360063', N'PVBank', 'Credit'),
    ('phuonghang_dainam', '1902847362', N'OCB', 'Credit'),
    ('j97_domdom', '0384728193', N'MBBank', 'Debit'),
    ('khabanh_miai', '4829103847', N'Agribank', 'Debit'),
    ('mailisa_phan', '0071029384', N'Vietcombank', 'Credit'),
    ('luongbangquang', '1903847281', N'Techcombank', 'Debit'),
    ('thuytien_miss', '2837461928', N'TPBank', 'Debit'),
    ('viethuong_hai', '1239485721', N'ACB', 'Credit'),
    ('chidan_singer', '5647382910', N'VPBank', 'Debit'),
    ('ngan98_dj', '7382910485', N'Sacombank', 'Credit');

INSERT INTO LIEN_KET_MANG_XA_HOI
    (TenDangNhap, LienKetMangXaHoi)
VALUES
    ('phanphucthinh', 'facebook.com/thinh'),
    ('nguyenngocton', 'facebook.com/ton'),
    ('dohongphuc', 'facebook.com/phuc'),
    ('letrongtin', 'facebook.com/tin'),
    ('ngominhtri', 'facebook.com/tri'),
    ('maitrithuc', 'facebook.com/thuc'),
    ('quynhtrang', 'facebook.com/trang'),

    ('phuonghang_dainam', 'facebook.com/ceo.phuonghang'),
    ('j97_domdom', 'facebook.com/jack.j97'),
    ('khabanh_miai', 'facebook.com/khabanh.official'),
    ('mailisa_phan', 'facebook.com/thammyvienmailisa'),
    ('luongbangquang', 'facebook.com/luongbangquang'),
    ('thuytien_miss', 'instagram.com/tienng12'),
    ('viethuong_hai', 'facebook.com/viethuonghuonglan'),
    ('chidan_singer', 'tiktok.com/@chidan_singer'),
    ('ngan98_dj', 'facebook.com/djngan98');

INSERT INTO DIA_CHI
    (TenDangNhap, DiaChi)
VALUES
    ('phanphucthinh', N'268 Lê Văn Việt, Thành phố Hồ Chí Minh'),
    ('nguyenngocton', N'456 Ký Túc Xá, Thành phố Hồ Chí Minh'),
    ('dohongphuc', N'789 Ký Túc Xá, Thành phố Hồ Chí Minh'),
    ('letrongtin', N'1945 Thống Nhất, Đồng Tháp'),
    ('ngominhtri', N'1713 Xô Viết - Nghệ Tĩnh ,Tỉnh Thanh Hóa'),
    ('maitrithuc', N'12 Quốc lộ 1, Hóc Môn, Thành phố Hồ Chí Minh'),
    ('quynhtrang', N'202 Điện Biên Phủ, Thành phố Hồ Chí Minh'),
    ('phuonghang_dainam', N'Khu du lịch Đại Nam, Bình Dương'),
    ('j97_domdom', N'Bến Tre, Miền Tây'),
    ('khabanh_miai', N'Từ Sơn, Bắc Ninh'),
    ('mailisa_phan', N'88 Huỳnh Văn Bánh, Phú Nhuận, TP.HCM'),
    ('luongbangquang', N'Chung cư cao cấp Quận 7, TP.HCM'),
    ('thuytien_miss', N'Quận 4, TP.HCM'),
    ('viethuong_hai', N'Quận 10, TP.HCM'),
    ('chidan_singer', N'Quận Tân Bình, TP.HCM'),
    ('ngan98_dj', N'Quận 7, TP.HCM');
GO

INSERT INTO QUAN_TRI_VIEN
    (TenDangNhap, MucQuyenHan, LanDangNhapCuoi)
VALUES
    ('phanphucthinh', 'Admin', '2025-11-20T10:00:00'),
    ('nguyenngocton', 'Admin', '2025-11-20T11:00:00'),
    ('letrongtin', 'Admin', '2025-11-20T12:00:00'),
    ('phuonghang_dainam', 'Admin', '2025-11-20T12:00:00'),
    ('j97_domdom', 'Admin', '2025-11-20T12:00:00'),
    ('khabanh_miai', 'Admin', '2025-11-20T12:00:00');
GO

INSERT INTO CUA_HANG
    (MaSoShop, DanhHieu, Ten, MoTa, LinkAnhDaiDien, LinkShop, ThoiGianThamGia, DiaChiDangKy, MaSoThue, LoaiHinhKinhDoanh, TenDangNhapQuanTriVien)
VALUES
    ('SHOP0001', N'Yêu thích', N'Thịnh Appliances Shop', N'Bán đồ dùng', 'shop_thinh.jpg', 'shopthinh.com', GETDATE(), N'123 Lê Lợi, Thành phố Hồ Chí Minh', 'TAX001', N'Bán lẻ', 'phanphucthinh'),
    ('SHOP0002', N'Mall', N'Nhà thuốc Mai Trí Thức', N'Bán thuốc', 'shop_maitrithuc.jpg', 'maitrithuc.com', GETDATE(), N'18 Tôn Thất Thuyết, Hóc Môn, Thành phố Hồ Chí Minh', 'TAX002', N'Bán lẻ', 'phanphucthinh'),
    ('SHOP0003', NULL, N'Thích mùi sách mới', N'Bán sách', 'shop_ton1.jpg', 'shopton.com', GETDATE(), N'456 Nguyễn Trãi, Thành phố Hồ Chí Minh', 'TAX003', N'Bán lẻ', 'nguyenngocton'),
    ('SHOP0004', N'Yêu thích', N'Điện thoại Minh Trí', N'Bán điện thoại', 'shop_tri.jpg', 'trimobile.com', GETDATE(), N'56 Nguyễn Huệ, Thành phố Hồ Chí Minh', 'TAX004', N'Bán lẻ', 'nguyenngocton'),
    ('SHOP0005', N'Mall', N'Tín Laptop', N'Bán laptop', 'shop_tin.jpg', 'shoptin.com', GETDATE(), N'101 Lê Duẩn, Thành phố Hồ Chí Minh', 'TAX005', N'Bán lẻ', 'letrongtin'),
    ('SHOP0006', NULL, N'Thẩm mỹ viện Mailisa', N'Đến là đẹp', 'shop_mailisa.jpg', 'mailisa.com', GETDATE(), N'88 Huỳnh Văn Bánh, TP.HCM', 'TAX006', N'Bán lẻ', 'phuonghang_dainam'),
    ('SHOP0007', N'Mall', N'LBQ Studio', N'Dạy nhạc và bán thiết bị thu âm', 'shop_lbq.jpg', 'lbqmusic.com', GETDATE(), N'Quận 7, TP.HCM', 'TAX007', N'Bán lẻ', 'j97_domdom');
GO

INSERT INTO NGUOI_MUA
    (TenDangNhap, SoXuApp)
VALUES
    ('chidan_singer', 500),
    --
    ('dohongphuc', 1000),
    --
    ('j97_domdom', 2000),
    --
    ('khabanh_miai', 1500),
    --
    ('letrongtin', 100),
    ('luongbangquang', 3636),
    ('mailisa_phan', 9999),
    ('maitrithuc', 650),
    ('ngan98_dj', 1000),
    ('ngominhtri', 300),
    ('nguyenngocton', 600),
    ('phanphucthinh', 3000),
    ('phuonghang_dainam', 8000),
    ('quynhtrang', 500),
    ('thuytien_miss', 5000),
    ('viethuong_hai', 2000);



GO
INSERT INTO NGUOI_BAN
    (TenDangNhap, MaSoShop)
VALUES
    ('phanphucthinh', 'SHOP0001'),
    ('maitrithuc', 'SHOP0002'),
    ('nguyenngocton', 'SHOP0003'),
    ('ngominhtri', 'SHOP0004'),
    ('letrongtin', 'SHOP0005'),
    ('mailisa_phan', 'SHOP0006'),
    ('luongbangquang', 'SHOP0007');
GO

INSERT INTO SAN_PHAM
    (MaSanPham, MaSoShop, TenSanPham, ThongTinSanPham, LinkSanPham, GiaHienThi, Loai)
VALUES
    -- Shop 1
    ('PROD0001', 'SHOP0001', N'Bộ tháo lắp ốc vít', N'Linh hoạt', 'prod0001.com', 100000, N'Đồ dùng'),
    ('PROD0006', 'SHOP0001', N'Nồi chiên không dầu 5L', N'Air Fryer', 'prod0006.com', 1500000, N'Đồ gia dụng'),
    ('PROD0007', 'SHOP0001', N'Máy pha cà phê mini', N'Pha Espresso', 'prod0007.com', 850000, N'Đồ gia dụng'),
    ('PROD0008', 'SHOP0001', N'Bộ dao làm bếp 6 món', N'Thép không gỉ', 'prod0008.com', 450000, N'Dụng cụ nhà bếp'),
    ('PROD0009', 'SHOP0001', N'Bình đun siêu tốc 1.8L', N'Inox 304', 'prod0009.com', 300000, N'Đồ gia dụng'),
    ('PROD0010', 'SHOP0001', N'Đèn bàn LED chống cận', N'3 chế độ', 'prod0010.com', 250000, N'Đồ dùng'),
    ('PROD0011', 'SHOP0001', N'Máy hút bụi cầm tay', N'600W', 'prod0011.com', 600000, N'Đồ gia dụng'),
    ('PROD0012', 'SHOP0001', N'Cân điện tử nhà bếp', N'Tối đa 5kg', 'prod0012.com', 180000, N'Dụng cụ nhà bếp'),
    ('PROD0013', 'SHOP0001', N'Thùng rác thông minh', N'Cảm biến', 'prod0013.com', 750000, N'Đồ dùng'),
    ('PROD0014', 'SHOP0001', N'Bộ dụng cụ làm vườn', N'3 món', 'prod0014.com', 95000, N'Công cụ'),
    ('PROD0015', 'SHOP0001', N'Quạt điều hòa', N'Hơi nước', 'prod0015.com', 2500000, N'Đồ gia dụng'),
    -- Shop 2
    ('PROD0002', 'SHOP0002', N'Panadol', N'Giảm đau', 'prod0002.com', 150000, N'Thuốc'),
    ('PROD0016', 'SHOP0002', N'Siro ho Ích Nhi', N'Thảo dược', 'prod0016.com', 85000, N'Thuốc'),
    ('PROD0017', 'SHOP0002', N'Omega-3 Fish Oil', N'Bổ mắt', 'prod0017.com', 290000, N'Thực phẩm chức năng'),
    ('PROD0018', 'SHOP0002', N'Bông gòn y tế', N'Tiệt trùng', 'prod0018.com', 20000, N'Vật tư y tế'),
    ('PROD0019', 'SHOP0002', N'Nước súc miệng', N'Diệt khuẩn', 'prod0019.com', 75000, N'Chăm sóc cá nhân'),
    ('PROD0020', 'SHOP0002', N'V.Rohto', N'Nhỏ mắt', 'prod0020.com', 55000, N'Thuốc'),
    ('PROD0021', 'SHOP0002', N'Máy đo đường huyết', N'Accu-Chek', 'prod0021.com', 950000, N'Thiết bị y tế'),
    ('PROD0022', 'SHOP0002', N'Kem chống nắng', N'SPF 50+', 'prod0022.com', 180000, N'Mỹ phẩm'),
    ('PROD0023', 'SHOP0002', N'Viên uống Canxi', N'Hỗ trợ xương', 'prod0023.com', 240000, N'Thực phẩm chức năng'),
    ('PROD0024', 'SHOP0002', N'Gel rửa tay khô', N'Sát khuẩn', 'prod0024.com', 60000, N'Chăm sóc cá nhân'),
    ('PROD0025', 'SHOP0002', N'Phosphalugel', N'Dạ dày', 'prod0025.com', 110000, N'Thuốc'),
    -- Shop 3
    ('PROD0003', 'SHOP0003', N'Đắc Nhân Tâm', N'Sách hay', 'prod0003.com', 200000, N'Sách'),
    ('PROD0026', 'SHOP0003', N'Cà phê sáng với Tony', N'Kỹ năng', 'prod0026.com', 85000, N'Sách'),
    ('PROD0027', 'SHOP0003', N'Sapiens', N'Lược sử loài người', 'prod0027.com', 250000, N'Sách'),
    ('PROD0028', 'SHOP0003', N'Tập tô chữ Hán', N'3 cuốn', 'prod0028.com', 120000, N'Sách'),
    ('PROD0029', 'SHOP0003', N'Casio FX-580VN X', N'Máy tính', 'prod0029.com', 550000, N'Văn phòng phẩm'),
    ('PROD0030', 'SHOP0003', N'Bút máy Hero', N'Cao cấp', 'prod0030.com', 150000, N'Văn phòng phẩm'),
    ('PROD0031', 'SHOP0003', N'Vở ô ly', N'Combo 5', 'prod0031.com', 70000, N'Văn phòng phẩm'),
    ('PROD0032', 'SHOP0003', N'Harry Potter 1', N'Văn học', 'prod0032.com', 190000, N'Sách'),
    ('PROD0033', 'SHOP0003', N'Minna no Nihongo', N'Tiếng Nhật', 'prod0033.com', 170000, N'Sách'),
    ('PROD0034', 'SHOP0003', N'Sổ planner A4', N'Bìa cứng', 'prod0034.com', 95000, N'Văn phòng phẩm'),
    ('PROD0035', 'SHOP0003', N'Sticker trang trí', N'50 miếng', 'prod0035.com', 45000, N'Văn phòng phẩm'),
    -- Shop 4
    ('PROD0004', 'SHOP0004', N'BPhone 3', N'Chất', 'prod0004.com', 5000000, N'Điện thoại'),
    ('PROD0036', 'SHOP0004', N'iPhone 15 Pro Max', N'Titan', 'prod0036.com', 32000000, N'Điện thoại'),
    ('PROD0037', 'SHOP0004', N'Galaxy Z Fold 5', N'Gập', 'prod0037.com', 40000000, N'Điện thoại'),
    ('PROD0038', 'SHOP0004', N'Ốp lưng iPhone 14', N'Trong suốt', 'prod0038.com', 80000, N'Phụ kiện'),
    ('PROD0039', 'SHOP0004', N'Sạc nhanh 65W GaN', N'Nhỏ gọn', 'prod0039.com', 350000, N'Phụ kiện'),
    ('PROD0040', 'SHOP0004', N'Tai nghe Xiaomi', N'TWS', 'prod0040.com', 650000, N'Phụ kiện'),
    ('PROD0041', 'SHOP0004', N'Galaxy A54', N'Tầm trung', 'prod0041.com', 8500000, N'Điện thoại'),
    ('PROD0042', 'SHOP0004', N'Kính cường lực', N'Full màn', 'prod0042.com', 50000, N'Phụ kiện'),
    ('PROD0043', 'SHOP0004', N'Giá đỡ điện thoại', N'Ô tô', 'prod0043.com', 120000, N'Phụ kiện'),
    ('PROD0044', 'SHOP0004', N'Apple Watch S9', N'GPS', 'prod0044.com', 11000000, N'Smartwatch'),
    ('PROD0045', 'SHOP0004', N'OPPO Reno 10', N'Camera đẹp', 'prod0045.com', 9900000, N'Điện thoại'),
    -- Shop 5
    ('PROD0005', 'SHOP0005', N'ASUS ZenBook 13', N'Mỏng nhẹ', 'prod0005.com', 12000000, N'Laptop'),
    ('PROD0046', 'SHOP0005', N'MacBook Air M2', N'Apple Silicon', 'prod0046.com', 28000000, N'Laptop'),
    ('PROD0047', 'SHOP0005', N'Acer Nitro 5', N'Gaming', 'prod0047.com', 19000000, N'Laptop'),
    ('PROD0048', 'SHOP0005', N'RAM Kingston 16GB', N'DDR4', 'prod0048.com', 1200000, N'Linh kiện'),
    ('PROD0049', 'SHOP0005', N'Màn hình Dell Ultrasharp', N'24 inch', 'prod0049.com', 4500000, N'Linh kiện'),
    ('PROD0050', 'SHOP0005', N'Webcam Logitech C920', N'Full HD', 'prod0050.com', 1500000, N'Phụ kiện'),
    ('PROD0051', 'SHOP0005', N'Bàn phím Fuhlen', N'Cơ', 'prod0051.com', 700000, N'Phụ kiện'),
    ('PROD0052', 'SHOP0005', N'SSD Samsung T7', N'1TB', 'prod0052.com', 3500000, N'Lưu trữ'),
    ('PROD0053', 'SHOP0005', N'Đế tản nhiệt', N'3 quạt', 'prod0053.com', 250000, N'Phụ kiện'),
    ('PROD0054', 'SHOP0005', N'Máy in Canon', N'Laser', 'prod0054.com', 4200000, N'Thiết bị'),
    ('PROD0055', 'SHOP0005', N'Máy ảnh Canon EOS R50', N'Chụp hình sắc nét', 'prod0055.com', 19000000, N'Thiết bị'),
    -- Shop 6 (Mailisa - Mới thêm 10 sản phẩm)
    ('PROD0056', 'SHOP0006', N'Chì kẻ mày', N'Chống thấm nước', 'mailisa.com/p1', 900000, N'Mỹ phẩm'),
    ('PROD0057', 'SHOP0006', N'Son môi pha lê', N'Khử thâm tự nhiên', 'mailisa.com/p2', 1200000, N'Mỹ phẩm'),
    ('PROD0058', 'SHOP0006', N'Trị nám Doctor Magic', N'Bộ N3', 'mailisa.com/p3', 3000000, N'Mỹ phẩm'),
    ('PROD0059', 'SHOP0006', N'Sữa rửa mặt tạo bọt', N'Làm sạch sâu', 'mailisa.com/p4', 350000, N'Mỹ phẩm'),
    ('PROD0060', 'SHOP0006', N'Kem dưỡng trắng da', N'Ban đêm', 'mailisa.com/p5', 800000, N'Mỹ phẩm'),
    ('PROD0061', 'SHOP0006', N'Tẩy da chết ngọc trai', N'Thiên nhiên', 'mailisa.com/p6', 250000, N'Mỹ phẩm'),
    ('PROD0062', 'SHOP0006', N'Son môi cao cấp', N'Lì, không chì', 'mailisa.com/p7', 450000, N'Mỹ phẩm'),
    ('PROD0063', 'SHOP0006', N'Phấn nước Cushion', N'Che khuyết điểm', 'mailisa.com/p8', 600000, N'Mỹ phẩm'),
    ('PROD0064', 'SHOP0006', N'Xịt khoáng cấp ẩm', N'Lô hội', 'mailisa.com/p9', 200000, N'Mỹ phẩm'),
    ('PROD0065', 'SHOP0006', N'Kem chống nắng body', N'Không bết rít', 'mailisa.com/p10', 500000, N'Mỹ phẩm'),
    -- Shop 7 (LBQ Studio - Mới thêm 10 sản phẩm)
    ('PROD0066', 'SHOP0007', N'Sách thanh nhạc cơ bản', N'Cơ bản', 'lbq.com/p1', 1000000, N'Sách '),
    ('PROD0067', 'SHOP0007', N'Micro Neumann U87', N'Huyền thoại phòng thu', 'lbq.com/p2', 85000000, N'Thiết bị'),
    ('PROD0068', 'SHOP0007', N'Sound Card Apollo Twin', N'Xử lý âm thanh', 'lbq.com/p3', 25000000, N'Thiết bị'),
    ('PROD0069', 'SHOP0007', N'Tai nghe kiểm âm Ssssony', N'MDR-7506', 'lbq.com/p4', 3000000, N'Thiết bị'),
    ('PROD0070', 'SHOP0007', N'Loa kiểm âm KRK G4', N'Cặp 5 inch', 'lbq.com/p5', 9000000, N'Thiết bị'),
    ('PROD0071', 'SHOP0007', N'Dây tín hiệu XLR', N'Chống nhiễu', 'lbq.com/p6', 300000, N'Phụ kiện'),
    ('PROD0072', 'SHOP0007', N'Màng lọc âm Pop Filter', N'2 lớp', 'lbq.com/p7', 250000, N'Phụ kiện'),
    ('PROD0073', 'SHOP0007', N'Chân kẹp bàn Micro', N'Kim loại', 'lbq.com/p8', 400000, N'Phụ kiện'),
    ('PROD0074', 'SHOP0007', N'Sách thanh nhạc cho DJ', N'Nâng cao', 'lbq.com/p9', 5000000, N'Sách'),
    ('PROD0075', 'SHOP0007', N'Sách dạy Ukulele', N'Cơ bản', 'lbq.com/p10', 140000, N'Sách');

INSERT INTO LINK_ANH_VIDEO_SAN_PHAM
    (MaSanPham, LinkAnhVideo)
VALUES
    -- Shop 1 (Gia dụng - Thịnh)
    ('PROD0001', 'img_prod001.jpg'),
    ('PROD0006', 'img_prod006.jpg'),
    ('PROD0007', 'img_prod007.jpg'),
    ('PROD0008', 'img_prod008.jpg'),
    ('PROD0009', 'img_prod009.jpg'),
    ('PROD0010', 'img_prod010.jpg'),
    ('PROD0011', 'img_prod011.jpg'),
    ('PROD0012', 'img_prod012.jpg'),
    ('PROD0013', 'img_prod013.jpg'),
    ('PROD0014', 'img_prod014.jpg'),
    ('PROD0015', 'video_prod015.mp4'),
    -- Shop 2 (Thuốc - Thức)
    ('PROD0002', 'img_prod002.jpg'),
    ('PROD0016', 'img_prod016.jpg'),
    ('PROD0017', 'img_prod017.jpg'),
    ('PROD0018', 'img_prod018.jpg'),
    ('PROD0019', 'img_prod019.jpg'),
    ('PROD0020', 'img_prod020.jpg'),
    ('PROD0021', 'video_prod021.mp4'),
    ('PROD0022', 'img_prod022.jpg'),
    ('PROD0023', 'img_prod023.jpg'),
    ('PROD0024', 'img_prod024.jpg'),
    ('PROD0025', 'img_prod025.jpg'),
    -- Shop 3 (Sách - Tôn)
    ('PROD0003', 'img_prod003.jpg'),
    ('PROD0026', 'img_prod026.jpg'),
    ('PROD0027', 'img_prod027.jpg'),
    ('PROD0028', 'img_prod028.jpg'),
    ('PROD0029', 'img_prod029.jpg'),
    ('PROD0030', 'img_prod030.jpg'),
    ('PROD0031', 'img_prod031.jpg'),
    ('PROD0032', 'img_prod032.jpg'),
    ('PROD0033', 'img_prod033.jpg'),
    ('PROD0034', 'img_prod034.jpg'),
    ('PROD0035', 'img_prod035.jpg'),
    -- Shop 4 (Điện thoại - Trí)
    ('PROD0004', 'video_prod004.mp4'),
    ('PROD0036', 'img_prod036.jpg'),
    ('PROD0037', 'video_prod037.mp4'),
    ('PROD0038', 'img_prod038.jpg'),
    ('PROD0039', 'img_prod039.jpg'),
    ('PROD0040', 'img_prod040.jpg'),
    ('PROD0041', 'img_prod041.jpg'),
    ('PROD0042', 'img_prod042.jpg'),
    ('PROD0043', 'img_prod043.jpg'),
    ('PROD0044', 'img_prod044.jpg'),
    ('PROD0045', 'img_prod045.jpg'),
    -- Shop 5 (Laptop - Tín)
    ('PROD0005', 'video_prod005.mp4'),
    ('PROD0046', 'img_prod046.jpg'),
    ('PROD0047', 'img_prod047.jpg'),
    ('PROD0048', 'img_prod048.jpg'),
    ('PROD0049', 'img_prod049.jpg'),
    ('PROD0050', 'video_prod050.mp4'),
    ('PROD0051', 'img_prod051.jpg'),
    ('PROD0052', 'img_prod052.jpg'),
    ('PROD0053', 'img_prod053.jpg'),
    ('PROD0054', 'img_prod054.jpg'),
    ('PROD0055', 'img_prod055.jpg'),
    -- Shop 6 (Mailisa - Mai)
    ('PROD0056', 'img_prod056.jpg'),
    ('PROD0057', 'img_prod057.jpg'),
    ('PROD0058', 'img_prod058.jpg'),
    ('PROD0059', 'img_prod059.jpg'),
    ('PROD0060', 'img_prod060.jpg'),
    ('PROD0061', 'img_prod061.jpg'),
    ('PROD0062', 'img_prod062.jpg'),
    ('PROD0063', 'img_prod063.jpg'),
    ('PROD0064', 'img_prod064.jpg'),
    ('PROD0065', 'img_prod065.jpg'),
    -- Shop 7 (LBQ Studio - Quang)
    ('PROD0066', 'video_prod066.mp4'),
    ('PROD0067', 'img_prod067.jpg'),
    ('PROD0068', 'img_prod068.jpg'),
    ('PROD0069', 'img_prod069.jpg'),
    ('PROD0070', 'img_prod070.jpg'),
    ('PROD0071', 'img_prod071.jpg'),
    ('PROD0072', 'img_prod072.jpg'),
    ('PROD0073', 'img_prod073.jpg'),
    ('PROD0074', 'video_prod074.mp4'),
    ('PROD0075', 'img_prod075.jpg');

INSERT INTO DUYET_SAN_PHAM
    (QuanTriVien, MaSanPham)
VALUES
    -- Admin Thịnh duyệt Shop 1 (Đồ gia dụng)
    ('phanphucthinh', 'PROD0001'),
    ('phanphucthinh', 'PROD0006'),
    ('phanphucthinh', 'PROD0007'),
    ('phanphucthinh', 'PROD0008'),
    ('phanphucthinh', 'PROD0009'),
    ('phanphucthinh', 'PROD0010'),
    ('phanphucthinh', 'PROD0011'),
    ('phanphucthinh', 'PROD0012'),
    ('phanphucthinh', 'PROD0013'),
    ('phanphucthinh', 'PROD0014'),
    ('phanphucthinh', 'PROD0015'),
    -- Admin Khá Bảnh duyệt Shop 2 (Thuốc)
    ('khabanh_miai', 'PROD0002'),
    ('khabanh_miai', 'PROD0016'),
    ('khabanh_miai', 'PROD0017'),
    ('khabanh_miai', 'PROD0018'),
    ('khabanh_miai', 'PROD0019'),
    ('khabanh_miai', 'PROD0020'),
    ('khabanh_miai', 'PROD0021'),
    ('khabanh_miai', 'PROD0022'),
    ('khabanh_miai', 'PROD0023'),
    ('khabanh_miai', 'PROD0024'),
    ('khabanh_miai', 'PROD0025'),
    -- Admin Tôn duyệt Shop 3 (Sách) & Shop 4 (Điện thoại)
    ('nguyenngocton', 'PROD0003'),
    ('nguyenngocton', 'PROD0026'),
    ('nguyenngocton', 'PROD0027'),
    ('nguyenngocton', 'PROD0028'),
    ('nguyenngocton', 'PROD0029'),
    ('nguyenngocton', 'PROD0030'),
    ('nguyenngocton', 'PROD0031'),
    ('nguyenngocton', 'PROD0032'),
    ('nguyenngocton', 'PROD0033'),
    ('nguyenngocton', 'PROD0034'),
    ('nguyenngocton', 'PROD0035'),
    ('nguyenngocton', 'PROD0004'),
    ('nguyenngocton', 'PROD0036'),
    ('nguyenngocton', 'PROD0037'),
    ('nguyenngocton', 'PROD0038'),
    ('nguyenngocton', 'PROD0039'),
    ('nguyenngocton', 'PROD0040'),
    ('nguyenngocton', 'PROD0041'),
    ('nguyenngocton', 'PROD0042'),
    ('nguyenngocton', 'PROD0043'),
    ('nguyenngocton', 'PROD0044'),
    ('nguyenngocton', 'PROD0045'),
    -- Admin Tín duyệt Shop 5 (Laptop)
    ('letrongtin', 'PROD0005'),
    ('letrongtin', 'PROD0046'),
    ('letrongtin', 'PROD0047'),
    ('letrongtin', 'PROD0048'),
    ('letrongtin', 'PROD0049'),
    ('letrongtin', 'PROD0050'),
    ('letrongtin', 'PROD0051'),
    ('letrongtin', 'PROD0052'),
    ('letrongtin', 'PROD0053'),
    ('letrongtin', 'PROD0054'),
    ('letrongtin', 'PROD0055'),
    -- Admin Phương Hằng duyệt Shop 6 (Mailisa - Mỹ phẩm)
    ('phuonghang_dainam', 'PROD0056'),
    ('phuonghang_dainam', 'PROD0057'),
    ('phuonghang_dainam', 'PROD0058'),
    ('phuonghang_dainam', 'PROD0059'),
    ('phuonghang_dainam', 'PROD0060'),
    ('phuonghang_dainam', 'PROD0061'),
    ('phuonghang_dainam', 'PROD0062'),
    ('phuonghang_dainam', 'PROD0063'),
    ('phuonghang_dainam', 'PROD0064'),
    ('phuonghang_dainam', 'PROD0065'),
    -- Admin Jack duyệt Shop 7 (LBQ Studio - Âm nhạc)
    ('j97_domdom', 'PROD0066'),
    ('j97_domdom', 'PROD0067'),
    ('j97_domdom', 'PROD0068'),
    ('j97_domdom', 'PROD0069'),
    ('j97_domdom', 'PROD0070'),
    ('j97_domdom', 'PROD0071'),
    ('j97_domdom', 'PROD0072'),
    ('j97_domdom', 'PROD0073'),
    ('j97_domdom', 'PROD0074'),
    ('j97_domdom', 'PROD0075');
GO

INSERT INTO CHAN_NGUOI_BAN
    (QuanTriVien, NguoiBan, Time_Stamp, TrangThai, LyDo)
VALUES
    ('phanphucthinh', 'maitrithuc', GETDATE(), N'Chặn', N'Vi phạm nội quy'),
    ('nguyenngocton', 'ngominhtri', GETDATE(), N'Gỡ chặn', N'Khôi phục quyền'),
    ('phuonghang_dainam', 'luongbangquang', GETDATE(), N'Chặn', N'Sao kê không minh bạch'),
    ('j97_domdom', 'mailisa_phan', GETDATE(), N'Chặn', N'Spam quảng cáo'),
    ('khabanh_miai', 'phanphucthinh', GETDATE(), N'Chặn', N'Bán hàng cấm'),
    ('letrongtin', 'nguyenngocton', GETDATE(), N'Gỡ chặn', N'Đã đóng phạt');
GO

INSERT INTO CHAN_NGUOI_MUA
    (QuanTriVien, NguoiMua, Time_Stamp, TrangThai, LyDo)
VALUES
    ('phanphucthinh', 'dohongphuc', GETDATE(), N'Chặn', N'Boom hàng'),
    ('nguyenngocton', 'quynhtrang', GETDATE(), N'Gỡ chặn', N'Khôi phục quyền'),
    ('phuonghang_dainam', 'ngan98_dj', GETDATE(), N'Chặn', N'Bán hàng cấm'),
    ('khabanh_miai', 'chidan_singer', GETDATE(), N'Chặn', N'Nghi ngờ hack xu'),
    ('j97_domdom', 'thuytien_miss', GETDATE(), N'Gỡ chặn', N'Nhầm lẫn'),
    ('letrongtin', 'viethuong_hai', GETDATE(), N'Chặn', N'Đánh giá tiêu cực spam');
GO

INSERT INTO NHAN_TIN
    (NguoiGui, NguoiNhan, ThoiGianGui, NoiDungTinNhan)
VALUES
    ('dohongphuc', 'phanphucthinh', GETDATE(), N'Xin chào Thịnh!'),
    ('quynhtrang', 'letrongtin', GETDATE(), N'Xin chào Tín!'),
    ('phanphucthinh', 'nguyenngocton', GETDATE(), N'Chào Tôn!'),
    ('nguyenngocton', 'phanphucthinh', GETDATE(), N'Chào Thịnh!'),
    ('letrongtin', 'quynhtrang', GETDATE(), N'Chào Trang!'),
    ('thuytien_miss', 'mailisa_phan', DATEADD(day, -3, GETDATE()), N'Chị Mai ơi tư vấn giúp em bộ trị nám với ạ?'),
    ('mailisa_phan', 'thuytien_miss', DATEADD(day, -5, GETDATE()), N'Chào Tiên, em gửi ảnh da hiện tại cho chị xem nhé.'),
    ('j97_domdom', 'luongbangquang', DATEADD(day, -2, GETDATE()), N'Anh Quang ơi, mic U87 bên anh còn hàng không?'),
    ('luongbangquang', 'j97_domdom', DATEADD(day, -1, GETDATE()), N'Còn nha Jack, qua studio anh test thử thoải mái.'),
    ('khabanh_miai', 'phanphucthinh', DATEADD(day, -1, GETDATE()), N'Bạn ơi đơn hàng của mình đi chưa?'),
    ('phanphucthinh', 'khabanh_miai', DATEADD(day, -1, GETDATE()), N'Dạ bên em giao cho đơn vị vận chuyển rồi ạ.'),
    ('ngan98_dj', 'viethuong_hai', DATEADD(day, -5, GETDATE()), N'Cô Hương ơi nồi chiên này nướng bánh được không cô?'),
    ('viethuong_hai', 'ngan98_dj', DATEADD(day, -4, GETDATE()), N'Hello em!');
GO

INSERT INTO TO_CAO
    (MaSoShop, TenDangNhapNguoiMua, LyDoToCao, Time_Stamp, TrangThaiXuLy)
VALUES
    ('SHOP0001', 'dohongphuc', N'Sản phẩm bị lỗi', GETDATE(), N'Chờ xử lý'),
    ('SHOP0003', 'quynhtrang', N'Giao hàng chậm', GETDATE(), N'Chờ xử lý'),
    ('SHOP0005', 'dohongphuc', N'Giá cao hơn thị trường', GETDATE(), N'Chờ xử lý'),
    ('SHOP0001', 'khabanh_miai', N'Giao sai màu sản phẩm', GETDATE(), N'Chờ xử lý'),
    ('SHOP0002', 'ngan98_dj', N'Thuốc gần hết hạn sử dụng', GETDATE(), N'Đã xử lý'),
    ('SHOP0004', 'dohongphuc', N'Nghi ngờ điện thoại hàng dựng', DATEADD(day, -1, GETDATE()), N'Chờ xử lý'),
    ('SHOP0006', 'viethuong_hai', N'Kem dưỡng gây kích ứng da', DATEADD(day, -2, GETDATE()), N'Từ chối'),
    ('SHOP0007', 'j97_domdom', N'Micro bị rè, không thu tiếng', GETDATE(), N'Chờ xử lý'),
    ('SHOP0003', 'letrongtin', N'Sách bị rách bìa và móp góc', DATEADD(day, -3, GETDATE()), N'Đã xử lý'),
    ('SHOP0005', 'quynhtrang', N'Laptop bị trầy xước nặng', GETDATE(), N'Chờ xử lý'),
    ('SHOP0006', 'chidan_singer', N'Shop trả lời tin nhắn thô lỗ', DATEADD(day, -1, GETDATE()), N'Từ chối');
GO


-- MÃ GIẢM GIÁ (ĐÃ FIX CONSTRAINT: ADMIN -> MaSoShop=NULL; SHOP -> AdminID=NULL)
INSERT INTO MA_GIAM_GIA
    (MaVoucher, TenVoucher, NguoiTao, LuotSuDungConLai, GiamTheoPhanTram, GiamTheoLuongTien, MucGiamToiDa, MucGiamToiThieu, TenDangNhapQuanTriVien, MaSoShop)
VALUES
    ('VCHR0001', 'GIAM10', 'SHOP', 5, 10.0, NULL, 50000, 100000, NULL, 'SHOP0001'),
    ('VCHR0002', 'GIAM15', 'SHOP', 3, 15.0, NULL, 100000, 20000, NULL, 'SHOP0002'),
    ('VCHR0003', 'GIAM50K', 'SHOP', 10, NULL, 50000, NULL, 0, NULL, 'SHOP0003'),
    ('VCHR0004', 'GIAM20', 'ADMIN', 2, 20.0, NULL, 100000, 20000, 'nguyenngocton', NULL),
    ('VCHR0005', 'GIAM100', 'SHOP', 1, NULL, 100000, NULL, 50000, NULL, 'SHOP0005'),
    ('EXTR0001', 'FREESHIP', 'TRANSPORT', 10, 100.0, NULL, NULL, 50000, NULL, NULL),
    ('VCHR00XX', 'SALESAPSAN11.11', 'SHOP', 5, 90, NULL, 5000000, 1000000, NULL, 'SHOP0001'),
    ('VCHR00YY', 'GIAM50', 'ADMIN', 5, 50.0, NULL, 50000, 100000, 'phanphucthinh', NULL),
    ('SALE0005', 'GIAM95', 'SHOP', 1, 95.0, NULL, 100000, 50000, NULL, 'SHOP0005');

-- Nếu Voucher có Mác ADMIN có thể sài hết (Này chưa confirm nhe nhưng trước mắt nhiêu đó voucher sinh mệt rồi)
-- Nếu voucher của shop thì gắn mã voucher đó với SẢN PHẨM của shop đó
INSERT INTO MAT_HANG_AP_DUNG
    (MaVoucher, MatHangApDung)
VALUES
    ('VCHR0001', 'PROD0001'),
    ('VCHR0001', 'PROD0014'),
    ('VCHR0003', 'PROD0003'),
    ('VCHR0005', 'PROD0005'),
    ('VCHR0002', 'PROD0002'),
    ('SALE0005', 'PROD0005'),
    ('VCHR00XX', 'PROD0001');


INSERT INTO DANH_GIA
    (MaDanhGia, MaSanPham, TenDangNhapNguoiMua, MaSoShop, SoSao, NoiDung, NgayDanhGia)
VALUES
    ('REVI0001', 'PROD0001', 'dohongphuc', 'SHOP0001', 5, N'Rất tốt', GETDATE()),
    ('REVI0002', 'PROD0002', 'quynhtrang', 'SHOP0002', 4, N'Hài lòng', GETDATE()),
    ('REVI0003', 'PROD0003', 'dohongphuc', 'SHOP0003', 3, N'Bình thường', GETDATE()),
    ('REVI0004', 'PROD0004', 'quynhtrang', 'SHOP0004', 5, N'Tuyệt vời', GETDATE()),
    ('REVI0005', 'PROD0005', 'dohongphuc', 'SHOP0005', 4, N'Đáng giá', GETDATE()),
    ('REVI0006', 'PROD0006', 'viethuong_hai', 'SHOP0001', 5, N'Nồi chiên dùng rất tốt, gà giòn tan', DATEADD(day, -5, GETDATE())),
    ('REVI0007', 'PROD0016', 'letrongtin', 'SHOP0002', 4, N'Siro ngọt, bé nhà mình rất thích uống', DATEADD(day, -4, GETDATE())),
    ('REVI0008', 'PROD0026', 'dohongphuc', 'SHOP0003', 5, N'Sách hay, bìa đẹp, giao hàng nhanh', DATEADD(day, -3, GETDATE())),
    ('REVI0009', 'PROD0036', 'j97_domdom', 'SHOP0004', 5, N'Điện thoại xịn, titan tự nhiên quá đẹp', DATEADD(day, -2, GETDATE())),
    ('REVI0010', 'PROD0046', 'ngominhtri', 'SHOP0005', 4, N'Máy mỏng nhẹ, pin trâu nhưng hơi nóng', DATEADD(day, -6, GETDATE())),
    ('REVI0011', 'PROD0056', 'thuytien_miss', 'SHOP0006', 5, N'Chì kẻ mày nét mảnh, rất dễ vẽ', DATEADD(day, -1, GETDATE())),
    ('REVI0012', 'PROD0066', 'chidan_singer', 'SHOP0007', 3, N'Sách hơi mỏng so với giá tiền', DATEADD(day, -7, GETDATE())),
    ('REVI0013', 'PROD0070', 'phanphucthinh', 'SHOP0007', 5, N'Loa kiểm âm chất lượng, bass đầm', GETDATE());
GO

INSERT INTO LINK_ANH_VIDEO_DANH_GIA
    (MaDanhGia, MaSanPham, TenDangNhapNguoiMua, LinkAnhVideo)
VALUES
    ('REVI0001', 'PROD0001', 'dohongphuc', 'img_review1.jpg'),
    ('REVI0002', 'PROD0002', 'quynhtrang', 'img_review2.jpg'),
    ('REVI0003', 'PROD0003', 'dohongphuc', 'video_review3.mp4'),
    ('REVI0004', 'PROD0004', 'quynhtrang', 'img_review4.jpg'),
    ('REVI0005', 'PROD0005', 'dohongphuc', 'video_review5.mp4'),
    ('REVI0006', 'PROD0006', 'viethuong_hai', 'img_review6_noi_chien.jpg'),
    ('REVI0007', 'PROD0016', 'letrongtin', 'img_review7_siro.jpg'),
    ('REVI0008', 'PROD0026', 'dohongphuc', 'video_review8_sach.mp4'),
    ('REVI0009', 'PROD0036', 'j97_domdom', 'img_review9_iphone.png'),
    ('REVI0010', 'PROD0046', 'ngominhtri', 'img_review10_macbook.jpg'),
    ('REVI0011', 'PROD0056', 'thuytien_miss', 'video_review11_makeup.mp4'),
    ('REVI0012', 'PROD0066', 'chidan_singer', 'img_review12_sach_nhac.jpg'),
    ('REVI0013', 'PROD0070', 'phanphucthinh', 'img_review13_loa_krk.jpg');
GO

INSERT INTO BIEN_THE_SAN_PHAM
    (ID, MaSanPham, SoLuongTrongKho, Ten)
VALUES
    -- Shop 1 (PROD0001 + PROD0006 -> PROD0015)
    ('P001T001', 'PROD0001', 50, N'Hộp Đỏ'),
    ('P001T002', 'PROD0001', 50, N'Hộp Xanh'),
    ('P001T003', 'PROD0001', 50, N'Hộp Vàng'),
    ('P006T001', 'PROD0006', 50, N'Màu Trắng'),
    ('P006T002', 'PROD0006', 50, N'Màu Đen'),
    ('P006T003', 'PROD0006', 50, N'Màu Xám'),
    ('P007T001', 'PROD0007', 50, N'Bản Mini'),
    ('P007T002', 'PROD0007', 50, N'Bản Thường'),
    ('P007T003', 'PROD0007', 50, N'Bản Pro'),
    ('P008T001', 'PROD0008', 50, N'Cán Gỗ'),
    ('P008T002', 'PROD0008', 50, N'Cán Nhựa'),
    ('P008T003', 'PROD0008', 50, N'Cán Thép'),
    ('P009T001', 'PROD0009', 50, N'1.5 Lít'),
    ('P009T002', 'PROD0009', 50, N'1.8 Lít'),
    ('P009T003', 'PROD0009', 50, N'2.0 Lít'),
    ('P010T001', 'PROD0010', 50, N'Ánh sáng Trắng'),
    ('P010T002', 'PROD0010', 50, N'Ánh sáng Vàng'),
    ('P010T003', 'PROD0010', 50, N'Ánh sáng Tự nhiên'),
    ('P011T001', 'PROD0011', 50, N'Có dây'),
    ('P011T002', 'PROD0011', 50, N'Không dây'),
    ('P011T003', 'PROD0011', 50, N'Robot'),
    ('P012T001', 'PROD0012', 50, N'Màu Hồng'),
    ('P012T002', 'PROD0012', 50, N'Màu Trắng'),
    ('P012T003', 'PROD0012', 50, N'Màu Xanh'),
    ('P013T001', 'PROD0013', 50, N'10 Lít'),
    ('P013T002', 'PROD0013', 50, N'15 Lít'),
    ('P013T003', 'PROD0013', 50, N'20 Lít'),
    ('P014T001', 'PROD0014', 50, N'Bộ 3 món'),
    ('P014T002', 'PROD0014', 50, N'Bộ 5 món'),
    ('P014T003', 'PROD0014', 50, N'Bộ 7 món'),
    ('P015T001', 'PROD0015', 50, N'Cơ'),
    ('P015T002', 'PROD0015', 50, N'Điện tử'),
    ('P015T003', 'PROD0015', 50, N'Cảm ứng'),

    -- Shop 2 (PROD0002 + PROD0016 -> PROD0025)
    ('P002T001', 'PROD0002', 50, N'Vỉ 10 viên'),
    ('P002T002', 'PROD0002', 50, N'Hộp 100 viên'),
    ('P002T003', 'PROD0002', 50, N'Chai 200 viên'),
    ('P016T001', 'PROD0016', 50, N'Chai 90ml'),
    ('P016T002', 'PROD0016', 50, N'Chai 120ml'),
    ('P016T003', 'PROD0016', 50, N'Gói nhỏ'),
    ('P017T001', 'PROD0017', 50, N'Hộp 30 viên'),
    ('P017T002', 'PROD0017', 50, N'Hộp 60 viên'),
    ('P017T003', 'PROD0017', 50, N'Hộp 90 viên'),
    ('P018T001', 'PROD0018', 50, N'Túi 50g'),
    ('P018T002', 'PROD0018', 50, N'Túi 100g'),
    ('P018T003', 'PROD0018', 50, N'Túi 500g'),
    ('P019T001', 'PROD0019', 50, N'Hương Bạc Hà'),
    ('P019T002', 'PROD0019', 50, N'Hương Trà Xanh'),
    ('P019T003', 'PROD0019', 50, N'Hương Cam'),
    ('P020T001', 'PROD0020', 50, N'Xanh (Mát)'),
    ('P020T002', 'PROD0020', 50, N'Vàng (Dịu)'),
    ('P020T003', 'PROD0020', 50, N'Hồng (Vitamin)'),
    ('P021T001', 'PROD0021', 50, N'Máy đơn'),
    ('P021T002', 'PROD0021', 50, N'Combo que thử'),
    ('P021T003', 'PROD0021', 50, N'Full Kit'),
    ('P022T001', 'PROD0022', 50, N'SPF 30'),
    ('P022T002', 'PROD0022', 50, N'SPF 50'),
    ('P022T003', 'PROD0022', 50, N'SPF 80'),
    ('P023T001', 'PROD0023', 50, N'Vị Cam'),
    ('P023T002', 'PROD0023', 50, N'Vị Dâu'),
    ('P023T003', 'PROD0023', 50, N'Không đường'),
    ('P024T001', 'PROD0024', 50, N'Chai 100ml'),
    ('P024T002', 'PROD0024', 50, N'Chai 250ml'),
    ('P024T003', 'PROD0024', 50, N'Chai 500ml'),
    ('P025T001', 'PROD0025', 50, N'Hộp 6 gói'),
    ('P025T002', 'PROD0025', 50, N'Hộp 20 gói'),
    ('P025T003', 'PROD0025', 50, N'Chai hỗn dịch'),

    -- Shop 3 (PROD0003 + PROD0026 -> PROD0035)
    ('P003T001', 'PROD0003', 50, N'Bìa mềm'),
    ('P003T002', 'PROD0003', 50, N'Bìa cứng'),
    ('P003T003', 'PROD0003', 50, N'Boxset'),
    ('P026T001', 'PROD0026', 50, N'Bìa mềm'),
    ('P026T002', 'PROD0026', 50, N'Bìa cứng'),
    ('P026T003', 'PROD0026', 50, N'Tái bản'),
    ('P027T001', 'PROD0027', 50, N'Tiếng Việt'),
    ('P027T002', 'PROD0027', 50, N'Tiếng Anh'),
    ('P027T003', 'PROD0027', 50, N'Limited'),
    ('P028T001', 'PROD0028', 50, N'Tập 1'),
    ('P028T002', 'PROD0028', 50, N'Tập 2'),
    ('P028T003', 'PROD0028', 50, N'Combo 3 tập'),
    ('P029T001', 'PROD0029', 50, N'Màu Đen'),
    ('P029T002', 'PROD0029', 50, N'Màu Xanh'),
    ('P029T003', 'PROD0029', 50, N'Màu Hồng'),
    ('P030T001', 'PROD0030', 50, N'Ngòi F'),
    ('P030T002', 'PROD0030', 50, N'Ngòi M'),
    ('P030T003', 'PROD0030', 50, N'Ngòi Cong'),
    ('P031T001', 'PROD0031', 50, N'48 trang'),
    ('P031T002', 'PROD0031', 50, N'96 trang'),
    ('P031T003', 'PROD0031', 50, N'200 trang'),
    ('P032T001', 'PROD0032', 50, N'Bìa tiêu chuẩn'),
    ('P032T002', 'PROD0032', 50, N'Bìa kỷ niệm'),
    ('P032T003', 'PROD0032', 50, N'Bản minh họa'),
    ('P033T001', 'PROD0033', 50, N'Sơ cấp 1'),
    ('P033T002', 'PROD0033', 50, N'Sơ cấp 2'),
    ('P033T003', 'PROD0033', 50, N'Trung cấp'),
    ('P034T001', 'PROD0034', 50, N'Màu Nâu'),
    ('P034T002', 'PROD0034', 50, N'Màu Đen'),
    ('P034T003', 'PROD0034', 50, N'Màu Xanh'),
    ('P035T001', 'PROD0035', 50, N'Chủ đề Mèo'),
    ('P035T002', 'PROD0035', 50, N'Chủ đề Hoa'),
    ('P035T003', 'PROD0035', 50, N'Chủ đề Vintage'),

    -- Shop 4 (PROD0004 + PROD0036 -> PROD0045)
    ('P004T001', 'PROD0004', 50, N'32GB'),
    ('P004T002', 'PROD0004', 50, N'64GB'),
    ('P004T003', 'PROD0004', 50, N'128GB'),
    ('P036T001', 'PROD0036', 50, N'256GB Titan Tự nhiên'),
    ('P036T002', 'PROD0036', 50, N'512GB Titan Xanh'),
    ('P036T003', 'PROD0036', 50, N'1TB Titan Đen'),
    ('P037T001', 'PROD0037', 50, N'Đen Phantom'),
    ('P037T002', 'PROD0037', 50, N'Xanh Icy'),
    ('P037T003', 'PROD0037', 50, N'Kem Ivory'),
    ('P038T001', 'PROD0038', 50, N'Trong suốt'),
    ('P038T002', 'PROD0038', 50, N'Đen mờ'),
    ('P038T003', 'PROD0038', 50, N'Viền màu'),
    ('P039T001', 'PROD0039', 50, N'Màu Trắng'),
    ('P039T002', 'PROD0039', 50, N'Màu Đen'),
    ('P039T003', 'PROD0039', 50, N'Màu Vàng'),
    ('P040T001', 'PROD0040', 50, N'Bản Quốc tế'),
    ('P040T002', 'PROD0040', 50, N'Bản Nội địa'),
    ('P040T003', 'PROD0040', 50, N'Bản Pro'),
    ('P041T001', 'PROD0041', 50, N'Xanh Green'),
    ('P041T002', 'PROD0041', 50, N'Tím Violet'),
    ('P041T003', 'PROD0041', 50, N'Đen Graphite'),
    ('P042T001', 'PROD0042', 50, N'Chống nhìn trộm'),
    ('P042T002', 'PROD0042', 50, N'Chống vân tay'),
    ('P042T003', 'PROD0042', 50, N'Trong suốt'),
    ('P043T001', 'PROD0043', 50, N'Kẹp khe gió'),
    ('P043T002', 'PROD0043', 50, N'Hút chân không'),
    ('P043T003', 'PROD0043', 50, N'Dán taplo'),
    ('P044T001', 'PROD0044', 50, N'41mm Nhôm'),
    ('P044T002', 'PROD0044', 50, N'45mm Nhôm'),
    ('P044T003', 'PROD0044', 50, N'45mm Thép'),
    ('P045T001', 'PROD0045', 50, N'Xám'),
    ('P045T002', 'PROD0045', 50, N'Xanh'),
    ('P045T003', 'PROD0045', 50, N'Vàng'),

    -- Shop 5 (PROD0005 + PROD0046 -> PROD0055)
    ('P005T001', 'PROD0005', 50, N'Core i3'),
    ('P005T002', 'PROD0005', 50, N'Core i5'),
    ('P005T003', 'PROD0005', 50, N'Core i7'),
    ('P046T001', 'PROD0046', 50, N'8GB/256GB'),
    ('P046T002', 'PROD0046', 50, N'8GB/512GB'),
    ('P046T003', 'PROD0046', 50, N'16GB/512GB'),
    ('P047T001', 'PROD0047', 50, N'GTX 1650'),
    ('P047T002', 'PROD0047', 50, N'RTX 3050'),
    ('P047T003', 'PROD0047', 50, N'RTX 4050'),
    ('P048T001', 'PROD0048', 50, N'Bus 2666'),
    ('P048T002', 'PROD0048', 50, N'Bus 3200'),
    ('P048T003', 'PROD0048', 50, N'Bus 3600'),
    ('P049T001', 'PROD0049', 50, N'24 inch'),
    ('P049T002', 'PROD0049', 50, N'27 inch'),
    ('P049T003', 'PROD0049', 50, N'32 inch'),
    ('P050T001', 'PROD0050', 50, N'720p'),
    ('P050T002', 'PROD0050', 50, N'1080p'),
    ('P050T003', 'PROD0050', 50, N'4K'),
    ('P051T001', 'PROD0051', 50, N'Blue Switch'),
    ('P051T002', 'PROD0051', 50, N'Red Switch'),
    ('P051T003', 'PROD0051', 50, N'Brown Switch'),
    ('P052T001', 'PROD0052', 50, N'500GB'),
    ('P052T002', 'PROD0052', 50, N'1TB'),
    ('P052T003', 'PROD0052', 50, N'2TB'),
    ('P053T001', 'PROD0053', 50, N'1 Quạt'),
    ('P053T002', 'PROD0053', 50, N'2 Quạt'),
    ('P053T003', 'PROD0053', 50, N'5 Quạt'),
    ('P054T001', 'PROD0054', 50, N'In Đơn năng'),
    ('P054T002', 'PROD0054', 50, N'In Đa năng'),
    ('P054T003', 'PROD0054', 50, N'In Màu'),
    ('P055T001', 'PROD0055', 50, N'1 Năm'),
    ('P055T002', 'PROD0055', 50, N'3 Năm'),
    ('P055T003', 'PROD0055', 50, N'Vĩnh viễn'),

    -- Shop 6 (PROD0056 -> PROD0065)
    ('P056T001', 'PROD0056', 50, N'Nâu Tây'),
    ('P056T002', 'PROD0056', 50, N'Đen'),
    ('P056T003', 'PROD0056', 50, N'Nâu Khói'),
    ('P057T001', 'PROD0057', 50, N'Đỏ Cam'),
    ('P057T002', 'PROD0057', 50, N'Hồng Cam'),
    ('P057T003', 'PROD0057', 50, N'Đỏ Tươi'),
    ('P058T001', 'PROD0058', 50, N'Nám Mảng'),
    ('P058T002', 'PROD0058', 50, N'Nám Chân Sâu'),
    ('P058T003', 'PROD0058', 50, N'Tàn Nhang'),
    ('P059T001', 'PROD0059', 50, N'50ml'),
    ('P059T002', 'PROD0059', 50, N'100ml'),
    ('P059T003', 'PROD0059', 50, N'150ml'),
    ('P060T001', 'PROD0060', 50, N'Hũ 30g'),
    ('P060T002', 'PROD0060', 50, N'Hũ 50g'),
    ('P060T003', 'PROD0060', 50, N'Hũ 100g'),
    ('P061T001', 'PROD0061', 50, N'Hương Hoa'),
    ('P061T002', 'PROD0061', 50, N'Hương Trái Cây'),
    ('P061T003', 'PROD0061', 50, N'Không Mùi'),
    ('P062T001', 'PROD0062', 50, N'Đỏ Rượu'),
    ('P062T002', 'PROD0062', 50, N'Cam Đất'),
    ('P062T003', 'PROD0062', 50, N'Hồng Nude'),
    ('P063T001', 'PROD0063', 50, N'Tone 21'),
    ('P063T002', 'PROD0063', 50, N'Tone 23'),
    ('P063T003', 'PROD0063', 50, N'Tone 25'),
    ('P064T001', 'PROD0064', 50, N'Lô Hội'),
    ('P064T002', 'PROD0064', 50, N'Hoa Hồng'),
    ('P064T003', 'PROD0064', 50, N'Trà Xanh'),
    ('P065T001', 'PROD0065', 50, N'Tuýp 50ml'),
    ('P065T002', 'PROD0065', 50, N'Tuýp 100ml'),
    ('P065T003', 'PROD0065', 50, N'Chai Xịt'),

    -- Shop 7 (PROD0066 -> PROD0075)
    ('P066T001', 'PROD0066', 50, N'Quyển 1'),
    ('P066T002', 'PROD0066', 50, N'Quyển 2'),
    ('P066T003', 'PROD0066', 50, N'Quyển 3'),
    ('P067T001', 'PROD0067', 50, N'Màu Bạc'),
    ('P067T002', 'PROD0067', 50, N'Màu Đen'),
    ('P067T003', 'PROD0067', 50, N'Bản Gold'),
    ('P068T001', 'PROD0068', 50, N'Solo USB'),
    ('P068T002', 'PROD0068', 50, N'Duo USB'),
    ('P068T003', 'PROD0068', 50, N'Quad TB'),
    ('P069T001', 'PROD0069', 50, N'Sony 7506'),
    ('P069T002', 'PROD0069', 50, N'Sony 900ST'),
    ('P069T003', 'PROD0069', 50, N'Sony M1ST'),
    ('P070T001', 'PROD0070', 50, N'5 inch'),
    ('P070T002', 'PROD0070', 50, N'7 inch'),
    ('P070T003', 'PROD0070', 50, N'8 inch'),
    ('P071T001', 'PROD0071', 50, N'1 mét'),
    ('P071T002', 'PROD0071', 50, N'3 mét'),
    ('P071T003', 'PROD0071', 50, N'5 mét'),
    ('P072T001', 'PROD0072', 50, N'Màng vải'),
    ('P072T002', 'PROD0072', 50, N'Màng kim loại'),
    ('P072T003', 'PROD0072', 50, N'Combo'),
    ('P073T001', 'PROD0073', 50, N'Kẹp bàn NB-35'),
    ('P073T002', 'PROD0073', 50, N'Chân đứng'),
    ('P073T003', 'PROD0073', 50, N'Chân thấp'),
    ('P074T001', 'PROD0074', 50, N'Quyển 1'),
    ('P074T002', 'PROD0074', 50, N'Quyển 2'),
    ('P074T003', 'PROD0074', 50, N'Combo 2 quyền'),
    ('P075T001', 'PROD0075', 50, N'Artist'),
    ('P075T002', 'PROD0075', 50, N'Pro'),
    ('P075T003', 'PROD0075', 50, N'Elements');

INSERT INTO THONG_TIN_BIEN_THE
    (ID, MaSanPham, KichCo, Loai, Gia)
VALUES('P001T001', 'PROD0001', N'L', N'Đỏ', 100000),
    ('P001T002', 'PROD0001', N'L', N'Xanh', 100000),
    ('P001T003', 'PROD0001', N'L', N'Vàng', 100000),
    ('P002T001', 'PROD0002', N'Hộp', N'Vỉ', 150000),
    ('P002T002', 'PROD0002', N'Hộp', N'Hộp', 1400000),
    ('P002T003', 'PROD0002', N'Chai', N'Chai', 250000),
    ('P003T001', 'PROD0003', N'A5', N'Mềm', 200000),
    ('P003T002', 'PROD0003', N'A5', N'Cứng', 250000),
    ('P003T003', 'PROD0003', N'A5', N'Box', 500000),
    ('P004T001', 'PROD0004', N'6.1', N'32G', 5000000),
    ('P004T002', 'PROD0004', N'6.1', N'64G', 6000000),
    ('P004T003', 'PROD0004', N'6.1', N'128G', 7000000),
    ('P005T001', 'PROD0005', N'13', N'i3', 12000000),
    ('P005T002', 'PROD0005', N'13', N'i5', 15000000),
    ('P005T003', 'PROD0005', N'13', N'i7', 18000000),
    ('P006T001', 'PROD0006', N'5L', N'Trắng', 1500000),
    ('P006T002', 'PROD0006', N'5L', N'Đen', 1500000),
    ('P006T003', 'PROD0006', N'5L', N'Xám', 1600000),
    ('P007T001', 'PROD0007', N'S', N'Mini', 850000),
    ('P007T002', 'PROD0007', N'M', N'Thường', 1200000),
    ('P007T003', 'PROD0007', N'L', N'Pro', 2000000),
    ('P008T001', 'PROD0008', N'Bộ', N'Gỗ', 450000),
    ('P008T002', 'PROD0008', N'Bộ', N'Nhựa', 350000),
    ('P008T003', 'PROD0008', N'Bộ', N'Thép', 550000),
    ('P009T001', 'PROD0009', N'1.5L', N'Inox', 280000),
    ('P009T002', 'PROD0009', N'1.8L', N'Inox', 300000),
    ('P009T003', 'PROD0009', N'2.0L', N'Inox', 350000),
    ('P010T001', 'PROD0010', N'Vừa', N'Trắng', 250000),
    ('P010T002', 'PROD0010', N'Vừa', N'Vàng', 250000),
    ('P010T003', 'PROD0010', N'Vừa', N'Tự nhiên', 270000),
    ('P011T001', 'PROD0011', N'Nhỏ', N'Dây', 600000),
    ('P011T002', 'PROD0011', N'Nhỏ', N'Pin', 800000),
    ('P011T003', 'PROD0011', N'Vừa', N'Robot', 2000000),
    ('P012T001', 'PROD0012', N'5kg', N'Hồng', 180000),
    ('P012T002', 'PROD0012', N'5kg', N'Trắng', 180000),
    ('P012T003', 'PROD0012', N'5kg', N'Xanh', 180000),
    ('P013T001', 'PROD0013', N'10L', N'Nhựa', 750000),
    ('P013T002', 'PROD0013', N'15L', N'Nhựa', 850000),
    ('P013T003', 'PROD0013', N'20L', N'Nhựa', 950000),
    ('P014T001', 'PROD0014', N'Bộ', N'3 món', 95000),
    ('P014T002', 'PROD0014', N'Bộ', N'5 món', 150000),
    ('P014T003', 'PROD0014', N'Bộ', N'7 món', 200000),
    ('P015T001', 'PROD0015', N'20L', N'Cơ', 2500000),
    ('P015T002', 'PROD0015', N'20L', N'Điện tử', 3000000),
    ('P015T003', 'PROD0015', N'30L', N'Cảm ứng', 4000000),
    ('P016T001', 'PROD0016', N'90ml', N'Siro', 85000),
    ('P016T002', 'PROD0016', N'120ml', N'Siro', 110000),
    ('P016T003', 'PROD0016', N'5ml', N'Gói', 5000),
    ('P017T001', 'PROD0017', N'30v', N'Hộp', 150000),
    ('P017T002', 'PROD0017', N'60v', N'Hộp', 290000),
    ('P017T003', 'PROD0017', N'90v', N'Hộp', 400000),
    ('P018T001', 'PROD0018', N'50g', N'Bông', 20000),
    ('P018T002', 'PROD0018', N'100g', N'Bông', 35000),
    ('P018T003', 'PROD0018', N'500g', N'Bông', 150000),
    ('P019T001', 'PROD0019', N'500ml', N'Bạc Hà', 75000),
    ('P019T002', 'PROD0019', N'500ml', N'Trà', 75000),
    ('P019T003', 'PROD0019', N'500ml', N'Cam', 75000),
    ('P020T001', 'PROD0020', N'13ml', N'Xanh', 55000),
    ('P020T002', 'PROD0020', N'13ml', N'Vàng', 55000),
    ('P020T003', 'PROD0020', N'13ml', N'Hồng', 60000),
    ('P021T001', 'PROD0021', N'Bộ', N'Máy', 950000),
    ('P021T002', 'PROD0021', N'Bộ', N'Que', 200000),
    ('P021T003', 'PROD0021', N'Bộ', N'Full', 1200000),
    ('P022T001', 'PROD0022', N'50g', N'SPF30', 150000),
    ('P022T002', 'PROD0022', N'50g', N'SPF50', 180000),
    ('P022T003', 'PROD0022', N'50g', N'SPF80', 220000),
    ('P023T001', 'PROD0023', N'30v', N'Cam', 240000),
    ('P023T002', 'PROD0023', N'30v', N'Dâu', 240000),
    ('P023T003', 'PROD0023', N'30v', N'KĐ', 240000),
    ('P024T001', 'PROD0024', N'100ml', N'Chai', 60000),
    ('P024T002', 'PROD0024', N'250ml', N'Chai', 120000),
    ('P024T003', 'PROD0024', N'500ml', N'Chai', 200000),
    ('P025T001', 'PROD0025', N'6g', N'Hộp', 30000),
    ('P025T002', 'PROD0025', N'20g', N'Hộp', 110000),
    ('P025T003', 'PROD0025', N'Chai', N'Hỗn dịch', 80000),
    ('P026T001', 'PROD0026', N'A5', N'Mềm', 85000),
    ('P026T002', 'PROD0026', N'A5', N'Cứng', 120000),
    ('P026T003', 'PROD0026', N'A5', N'TB', 100000),
    ('P027T001', 'PROD0027', N'A4', N'VN', 250000),
    ('P027T002', 'PROD0027', N'A4', N'EN', 350000),
    ('P027T003', 'PROD0027', N'A4', N'LTD', 600000),
    ('P028T001', 'PROD0028', N'Q1', N'Tập 1', 40000),
    ('P028T002', 'PROD0028', N'Q2', N'Tập 2', 40000),
    ('P028T003', 'PROD0028', N'Bộ', N'Combo', 120000),
    ('P029T001', 'PROD0029', N'Tiêu chuẩn', N'Đen', 550000),
    ('P029T002', 'PROD0029', N'Tiêu chuẩn', N'Xanh', 550000),
    ('P029T003', 'PROD0029', N'Tiêu chuẩn', N'Hồng', 550000),
    ('P030T001', 'PROD0030', N'Kim loại', N'F', 150000),
    ('P030T002', 'PROD0030', N'Kim loại', N'M', 150000),
    ('P030T003', 'PROD0030', N'Kim loại', N'Cong', 180000),
    ('P031T001', 'PROD0031', N'Lốc', N'48tr', 50000),
    ('P031T002', 'PROD0031', N'Lốc', N'96tr', 70000),
    ('P031T003', 'PROD0031', N'Lốc', N'200tr', 120000),
    ('P032T001', 'PROD0032', N'A5', N'Thường', 190000),
    ('P032T002', 'PROD0032', N'A5', N'Kỷ niệm', 250000),
    ('P032T003', 'PROD0032', N'A4', N'Minh họa', 500000),
    ('P033T001', 'PROD0033', N'B5', N'SC1', 170000),
    ('P033T002', 'PROD0033', N'B5', N'SC2', 170000),
    ('P033T003', 'PROD0033', N'B5', N'TC', 200000),
    ('P034T001', 'PROD0034', N'A4', N'Nâu', 95000),
    ('P034T002', 'PROD0034', N'A4', N'Đen', 95000),
    ('P034T003', 'PROD0034', N'A4', N'Xanh', 95000),
    ('P035T001', 'PROD0035', N'Túi', N'Mèo', 45000),
    ('P035T002', 'PROD0035', N'Túi', N'Hoa', 45000),
    ('P035T003', 'PROD0035', N'Túi', N'Vintage', 45000),
    ('P036T001', 'PROD0036', N'256GB', N'TN', 32000000),
    ('P036T002', 'PROD0036', N'512GB', N'Xanh', 38000000),
    ('P036T003', 'PROD0036', N'1TB', N'Đen', 44000000),
    ('P037T001', 'PROD0037', N'512GB', N'Đen', 40000000),
    ('P037T002', 'PROD0037', N'512GB', N'Xanh', 40000000),
    ('P037T003', 'PROD0037', N'512GB', N'Kem', 40000000),
    ('P038T001', 'PROD0038', N'14', N'Trong', 80000),
    ('P038T002', 'PROD0038', N'14', N'Mờ', 80000),
    ('P038T003', 'PROD0038', N'14', N'Viền', 100000),
    ('P039T001', 'PROD0039', N'65W', N'Trắng', 350000),
    ('P039T002', 'PROD0039', N'65W', N'Đen', 350000),
    ('P039T003', 'PROD0039', N'65W', N'Vàng', 380000),
    ('P040T001', 'PROD0040', N'Nhỏ', N'QT', 650000),
    ('P040T002', 'PROD0040', N'Nhỏ', N'NĐ', 550000),
    ('P040T003', 'PROD0040', N'Nhỏ', N'Pro', 900000),
    ('P041T001', 'PROD0041', N'128GB', N'Xanh', 8500000),
    ('P041T002', 'PROD0041', N'128GB', N'Tím', 8500000),
    ('P041T003', 'PROD0041', N'128GB', N'Đen', 8500000),
    ('P042T001', 'PROD0042', N'Full', N'Private', 100000),
    ('P042T002', 'PROD0042', N'Full', N'Matte', 80000),
    ('P042T003', 'PROD0042', N'Full', N'Clear', 50000),
    ('P043T001', 'PROD0043', N'Vừa', N'Khe', 120000),
    ('P043T002', 'PROD0043', N'Vừa', N'Hút', 150000),
    ('P043T003', 'PROD0043', N'Vừa', N'Dán', 100000),
    ('P044T001', 'PROD0044', N'41mm', N'Nhôm', 11000000),
    ('P044T002', 'PROD0044', N'45mm', N'Nhôm', 12000000),
    ('P044T003', 'PROD0044', N'45mm', N'Thép', 18000000),
    ('P045T001', 'PROD0045', N'256GB', N'Xám', 9900000),
    ('P045T002', 'PROD0045', N'256GB', N'Xanh', 9900000),
    ('P045T003', 'PROD0045', N'256GB', N'Vàng', 9900000),
    ('P046T001', 'PROD0046', N'13.6', N'Base', 28000000),
    ('P046T002', 'PROD0046', N'13.6', N'512', 34000000),
    ('P046T003', 'PROD0046', N'13.6', N'16G', 39000000),
    ('P047T001', 'PROD0047', N'15.6', N'1650', 19000000),
    ('P047T002', 'PROD0047', N'15.6', N'3050', 21000000),
    ('P047T003', 'PROD0047', N'15.6', N'4050', 25000000),
    ('P048T001', 'PROD0048', N'16GB', N'2666', 1000000),
    ('P048T002', 'PROD0048', N'16GB', N'3200', 1200000),
    ('P048T003', 'PROD0048', N'16GB', N'3600', 1500000),
    ('P049T001', 'PROD0049', N'24', N'U24', 4500000),
    ('P049T002', 'PROD0049', N'27', N'U27', 8000000),
    ('P049T003', 'PROD0049', N'32', N'U32', 12000000),
    ('P050T001', 'PROD0050', N'HD', N'720p', 800000),
    ('P050T002', 'PROD0050', N'FHD', N'1080p', 1500000),
    ('P050T003', 'PROD0050', N'4K', N'4K', 3000000),
    ('P051T001', 'PROD0051', N'Full', N'Blue', 700000),
    ('P051T002', 'PROD0051', N'Full', N'Red', 700000),
    ('P051T003', 'PROD0051', N'Full', N'Brown', 700000),
    ('P052T001', 'PROD0052', N'500GB', N'T7', 2000000),
    ('P052T002', 'PROD0052', N'1TB', N'T7', 3500000),
    ('P052T003', 'PROD0052', N'2TB', N'T7', 6000000),
    ('P053T001', 'PROD0053', N'15', N'1Fan', 150000),
    ('P053T002', 'PROD0053', N'15', N'2Fan', 250000),
    ('P053T003', 'PROD0053', N'17', N'5Fan', 400000),
    ('P054T001', 'PROD0054', N'Lớn', N'Đơn', 3000000),
    ('P054T002', 'PROD0054', N'Lớn', N'Đa', 4200000),
    ('P054T003', 'PROD0054', N'Lớn', N'Màu', 5500000),
    ('P055T001', 'PROD0055', N'32GB', N'Xám', 380000),
    ('P055T002', 'PROD0055', N'16GB', N'Đen', 900000),
    ('P055T003', 'PROD0055', N'32GB', N'Đen', 1500000),
    ('P056T001', 'PROD0056', N'Cây', N'Nâu Tây', 900000),
    ('P056T002', 'PROD0056', N'Cây', N'Đen', 900000),
    ('P056T003', 'PROD0056', N'Cây', N'Nâu Khói', 900000),
    ('P057T001', 'PROD0057', N'Cây', N'Đỏ', 1200000),
    ('P057T002', 'PROD0057', N'Cây', N'Hồng', 1200000),
    ('P057T003', 'PROD0057', N'Cây', N'Tươi', 1200000),
    ('P058T001', 'PROD0058', N'Bộ', N'Mảng', 3000000),
    ('P058T002', 'PROD0058', N'Bộ', N'Sâu', 3500000),
    ('P058T003', 'PROD0058', N'Bộ', N'Nhang', 2000000),
    ('P059T001', 'PROD0059', N'50ml', N'Bọt', 150000),
    ('P059T002', 'PROD0059', N'100ml', N'Bọt', 350000),
    ('P059T003', 'PROD0059', N'150ml', N'Bọt', 500000),
    ('P060T001', 'PROD0060', N'30g', N'Kem', 500000),
    ('P060T002', 'PROD0060', N'50g', N'Kem', 800000),
    ('P060T003', 'PROD0060', N'100g', N'Kem', 1500000),
    ('P061T001', 'PROD0061', N'100g', N'Hoa', 250000),
    ('P061T002', 'PROD0061', N'100g', N'Quả', 250000),
    ('P061T003', 'PROD0061', N'100g', N'Mộc', 250000),
    ('P062T001', 'PROD0062', N'Thỏi', N'Đỏ', 450000),
    ('P062T002', 'PROD0062', N'Thỏi', N'Cam', 450000),
    ('P062T003', 'PROD0062', N'Thỏi', N'Hồng', 450000),
    ('P063T001', 'PROD0063', N'Hộp', N'21', 600000),
    ('P063T002', 'PROD0063', N'Hộp', N'23', 600000),
    ('P063T003', 'PROD0063', N'Hộp', N'25', 600000),
    ('P064T001', 'PROD0064', N'150ml', N'Hội', 200000),
    ('P064T002', 'PROD0064', N'150ml', N'Hồng', 250000),
    ('P064T003', 'PROD0064', N'150ml', N'Trà', 220000),
    ('P065T001', 'PROD0065', N'50ml', N'Kem', 200000),
    ('P065T002', 'PROD0065', N'100ml', N'Kem', 350000),
    ('P065T003', 'PROD0065', N'150ml', N'Xịt', 500000),
    ('P066T001', 'PROD0066', N'Quyển', N'1', 300000),
    ('P066T002', 'PROD0066', N'Quyển', N'2', 550000),
    ('P066T003', 'PROD0066', N'Quyển', N'3', 1000000),
    ('P067T001', 'PROD0067', N'Hộp', N'Bạc', 85000000),
    ('P067T002', 'PROD0067', N'Hộp', N'Đen', 87000000),
    ('P067T003', 'PROD0067', N'Hộp', N'Gold', 120000000),
    ('P068T001', 'PROD0068', N'Hộp', N'Solo', 15000000),
    ('P068T002', 'PROD0068', N'Hộp', N'Duo', 25000000),
    ('P068T003', 'PROD0068', N'Hộp', N'Quad', 40000000),
    ('P069T001', 'PROD0069', N'Cái', N'7506', 3000000),
    ('P069T002', 'PROD0069', N'Cái', N'900', 4500000),
    ('P069T003', 'PROD0069', N'Cái', N'M1', 6000000),
    ('P070T001', 'PROD0070', N'Cặp', N'5', 9000000),
    ('P070T002', 'PROD0070', N'Cặp', N'7', 12000000),
    ('P070T003', 'PROD0070', N'Cặp', N'8', 15000000),
    ('P071T001', 'PROD0071', N'1m', N'Đen', 150000),
    ('P071T002', 'PROD0071', N'3m', N'Đen', 300000),
    ('P071T003', 'PROD0071', N'5m', N'Đen', 500000),
    ('P072T001', 'PROD0072', N'Cái', N'Vải', 250000),
    ('P072T002', 'PROD0072', N'Cái', N'Kim', 350000),
    ('P072T003', 'PROD0072', N'Cái', N'Combo', 500000),
    ('P073T001', 'PROD0073', N'Cái', N'Kẹp', 400000),
    ('P073T002', 'PROD0073', N'Cái', N'Đứng', 800000),
    ('P073T003', 'PROD0073', N'Cái', N'Thấp', 500000),
    ('P074T001', 'PROD0074', N'Quyển', N'1', 5000000),
    ('P074T002', 'PROD0074', N'Quyển', N'2', 8000000),
    ('P074T003', 'PROD0074', N'Quyển', N'1+2', 15000000),
    ('P075T001', 'PROD0075', N'Quyển', N'Xanh', 140000),
    ('P075T002', 'PROD0075', N'Quyển', N'Đỏ', 140000),
    ('P075T003', 'PROD0075', N'Quyển', N'Vàng', 150000);
GO

INSERT INTO GIO_HANG
    (MaSoGioHang, TenDangNhapNguoiMua)
VALUES
    ('CART0001', 'chidan_singer'),
    ('CART0002', 'dohongphuc'),
    ('CART0003', 'j97_domdom'),
    ('CART0004', 'khabanh_miai'),
    ('CART0005', 'letrongtin'),
    ('CART0006', 'luongbangquang'),
    ('CART0007', 'mailisa_phan'),
    ('CART0008', 'maitrithuc'),
    ('CART0009', 'ngan98_dj'),
    ('CART0010', 'ngominhtri'),
    ('CART0011', 'nguyenngocton'),
    ('CART0012', 'phanphucthinh'),
    ('CART0013', 'phuonghang_dainam'),
    ('CART0014', 'quynhtrang'),
    ('CART0015', 'thuytien_miss'),
    ('CART0016', 'viethuong_hai');
INSERT INTO GIO_HANG_CHUA
    (MaSoGioHang, ID_BienThe, MaSanPham, SoLuong)
VALUES
    ('CART0001', 'P001T001', 'PROD0001', 2),
    ('CART0001', 'P002T001', 'PROD0002', 1),
    ('CART0002', 'P005T001', 'PROD0005', 1),
    -- Dữ liệu mới thêm (10 dòng)
    ('CART0003', 'P060T001', 'PROD0060', 2),
    -- Thịnh mua Kem dưỡng Mailisa
    ('CART0004', 'P070T001', 'PROD0070', 1),
    -- Tín mua Loa kiểm âm
    ('CART0005', 'P036T001', 'PROD0036', 1),
    -- Tôn mua iPhone 15
    ('CART0006', 'P046T001', 'PROD0046', 1),
    -- Trí mua MacBook
    ('CART0007', 'P027T001', 'PROD0027', 1),
    -- Thức mua sách Sapiens
    ('CART0008', 'P056T001', 'PROD0056', 3),
    -- Thùy Tiên mua Kẻ chân mày
    ('CART0009', 'P006T001', 'PROD0006', 1),
    -- Việt Hương mua Nồi chiên
    ('CART0010', 'P074T001', 'PROD0074', 1),
    -- Chi Dân mua Sách thanh nhạc cho DJ
    ('CART0011', 'P062T001', 'PROD0062', 5),
    -- Ngân 98 mua Son môi
    ('CART0013', 'P007T001', 'PROD0007', 1),
    ('CART0012', 'P022T003', 'PROD0022', 2),
    ('CART0013', 'P017T003', 'PROD0017', 3),
    ('CART0001', 'P010T001', 'PROD0010', 1);
-- Phúc mua Đèn bàn

INSERT INTO DON_VI_VAN_CHUYEN
    (TenDonVi, MaDonVi)
VALUES
    (N'Giao hàng nhanh', 'DELIV001'),
    (N'VNPost', 'DELIV002'),
    (N'Giao Hàng Tiết Kiệm', 'DELIV003'),
    (N'J&T Express', 'DELIV004'),
    (N'Viettel Post', 'DELIV005'),
    (N'Ninja Van', 'DELIV006'),
    (N'GrabExpress', 'DELIV007'),
    (N'AhaMove', 'DELIV008'),
    (N'Shopee Xpress', 'DELIV009'),
    (N'Best Express', 'DELIV010');

INSERT INTO PHUONG_THUC_VAN_CHUYEN
    (MaDonVi, PhuongThucVanChuyen)
VALUES
    ('DELIV001', N'Nhanh'),
    -- GHN: Gói Nhanh
    ('DELIV001', N'Tiêu chuẩn'),
    -- GHN: Gói Tiêu chuẩn
    ('DELIV002', N'EMS'),
    -- VNPost: Chuyển phát nhanh
    ('DELIV002', N'Bưu kiện'),
    -- VNPost: Gói thường
    ('DELIV003', N'Tiết kiệm'),
    -- GHTK: Gói Tiết kiệm
    ('DELIV004', N'Chuẩn'),
    -- J&T: Gói Chuẩn
    ('DELIV005', N'Hỏa tốc'),
    -- Viettel: Gói Hỏa tốc
    ('DELIV005', N'V60'),
    ('DELIV006', N'Siêu tốc'),
    ('DELIV007', N'Siêu tốc'),
    ('DELIV008', N'Siêu tốc'),
    ('DELIV009', N'Hàng cồng kềnh'),
    ('DELIV010', N'Siêu tốc');      -- Shopee Xpress: Gói hàng nặng
GO

INSERT INTO DON_HANG
    (MaDonHang, PhuongThucVanChuyen, TrangThai, DiaChiLayHang, DiaChiGiaoHang, PhuongThucThanhToan, ThoiGianDatHang, ThoiGianGiaoDuKien, ThoiGianHoanThanhDon, ThoiGianThanhToan, ChietKhau, GiaBanDau, GiaVanChuyen, MaSoShop, TenDangNhapNguoiMua, ID_BienThe, MaSanPham_BienThe, SoLuongCuaBienThe, MaDonViVanChuyen)
VALUES
    -- SHOP 1 
    ('ORDE0001', N'Nhanh', N'Đang xử lý', N'123 Lê Lợi, TP.HCM', N'789 Ký Túc Xá, TP.HCM', 'COD', GETDATE(), DATEADD(day,3,GETDATE()), DATEADD(day,3,GETDATE()), DATEADD(day,3,GETDATE()) , 1, 200000, 20000, 'SHOP0001', 'dohongphuc', 'P001T001', 'PROD0001', 2, 'DELIV001'),
    ('ORDE0004', N'Tiêu chuẩn', N'Đã hoàn thành', N'123 Lê Lợi, TP.HCM', N'78 Nguyễn Văn Linh, Hà Nội', 'COD', DATEADD(day,-10,GETDATE()), DATEADD(day,-5,GETDATE()), DATEADD(day,-4,GETDATE()), DATEADD(day,-4,GETDATE()), 1, 1500000, 45000, 'SHOP0001', 'quynhtrang', 'P006T001', 'PROD0006', 1, 'DELIV001'),
    ('ORDE0005', N'Nhanh', N'Đang xử lý', N'123 Lê Lợi, TP.HCM', N'90 Hai Bà Trưng, Đà Nẵng', 'CREDIT', GETDATE(), DATEADD(day,2,GETDATE()), NULL, GETDATE(), 1, 850000, 35000, 'SHOP0001', 'letrongtin', 'P007T001', 'PROD0007', 1, 'DELIV003'),
    ('ORDE0006', N'Tiêu chuẩn', N'Đã hoàn thành', N'123 Lê Lợi, TP.HCM', N'10 Nguyễn Hữu Cảnh, TP.HCM', 'ZALOPAY', DATEADD(day,-5,GETDATE()), DATEADD(day,-2,GETDATE()), DATEADD(day,-1,GETDATE()), DATEADD(day,-5,GETDATE()), 1, 900000, 20000, 'SHOP0001', 'dohongphuc', 'P008T001', 'PROD0008', 2, 'DELIV002'),
    ('ORDE0007', N'Nhanh', N'Đang xử lý', N'123 Lê Lợi, TP.HCM', N'80 Trần Duy Hưng, Hà Nội', 'COD', GETDATE(), DATEADD(day,3,GETDATE()), NULL, NULL, 1, 280000, 40000, 'SHOP0001', 'quynhtrang', 'P009T001', 'PROD0009', 1, 'DELIV001'),
    ('ORDE0008', N'Tiêu chuẩn', N'Đã hoàn thành', N'123 Lê Lợi, TP.HCM', N'55 Phan Xích Long, TP.HCM', 'COD', DATEADD(day,-15,GETDATE()), DATEADD(day,-10,GETDATE()), DATEADD(day,-9,GETDATE()), DATEADD(day,-9,GETDATE()), 1, 750000, 20000, 'SHOP0001', 'letrongtin', 'P010T001', 'PROD0010', 3, 'DELIV003'),
    ('ORDE0009', N'Nhanh', N'Đã hủy', N'123 Lê Lợi, TP.HCM', N'43 Hùng Vương, Huế', 'CREDIT', DATEADD(day,-7,GETDATE()), DATEADD(day,-5,GETDATE()), NULL, DATEADD(day,-7,GETDATE()), 1, 600000, 45000, 'SHOP0001', 'dohongphuc', 'P011T001', 'PROD0011', 1, 'DELIV002'),
    ('ORDE0010', N'Tiêu chuẩn', N'Đã hoàn thành', N'123 Lê Lợi, TP.HCM', N'77 Lê Lợi, Vũng Tàu', 'ZALOPAY', DATEADD(day,-20,GETDATE()), DATEADD(day,-15,GETDATE()), DATEADD(day,-14,GETDATE()), DATEADD(day,-20,GETDATE()), 1, 360000, 30000, 'SHOP0001', 'quynhtrang', 'P012T001', 'PROD0012', 2, 'DELIV001'),
    ('ORDE0011', N'Nhanh', N'Đang xử lý', N'123 Lê Lợi, TP.HCM', N'66 Nguyễn Huệ, Nha Trang', 'COD', GETDATE(), DATEADD(day,3,GETDATE()), NULL, NULL, 1, 750000, 40000, 'SHOP0001', 'letrongtin', 'P013T001', 'PROD0013', 1, 'DELIV003'),
    ('ORDE0012', N'Tiêu chuẩn', N'Đã hoàn thành', N'123 Lê Lợi, TP.HCM', N'22 Lê Thánh Tôn, TP.HCM', 'COD', DATEADD(day,-6,GETDATE()), DATEADD(day,-3,GETDATE()), DATEADD(day,-2,GETDATE()), DATEADD(day,-2,GETDATE()), 1, 475000, 20000, 'SHOP0001', 'dohongphuc', 'P014T001', 'PROD0014', 5, 'DELIV002'),
    ('ORDE0013', N'Nhanh', N'Đang xử lý', N'123 Lê Lợi, TP.HCM', N'34 Bến Vân Đồn, TP.HCM', 'CREDIT', GETDATE(), DATEADD(day,1,GETDATE()), NULL, GETDATE(), 1, 2500000, 30000, 'SHOP0001', 'quynhtrang', 'P015T001', 'PROD0015', 1, 'DELIV001'),
    -- SHOP 2 
    ('ORDE0002', N'Tiêu chuẩn', N'Đang xử lý', N'18 Tôn Thất Thuyết, TP.HCM', N'789 Ký Túc Xá, TP.HCM', 'COD', GETDATE(), DATEADD(day,5,GETDATE()), DATEADD(day,6,GETDATE()), DATEADD(day,6,GETDATE()), 1, 150000, 15000, 'SHOP0002', 'dohongphuc', 'P002T001', 'PROD0002', 1, 'DELIV002'),
    ('ORDE0014', N'Nhanh', N'Đã hoàn thành', N'18 Tôn Thất Thuyết, TP.HCM', N'88 Lê Lợi, TP.HCM', 'ZALOPAY', DATEADD(day,-8,GETDATE()), DATEADD(day,-5,GETDATE()), DATEADD(day,-4,GETDATE()), DATEADD(day,-8,GETDATE()), 1, 170000, 25000, 'SHOP0002', 'letrongtin', 'P016T001', 'PROD0016', 2, 'DELIV003'),
    ('ORDE0015', N'Tiêu chuẩn', N'Đang xử lý', N'18 Tôn Thất Thuyết, TP.HCM', N'11 Nguyễn Văn Cừ, Cần Thơ', 'COD', GETDATE(), DATEADD(day,4,GETDATE()), NULL, NULL, 1, 150000, 35000, 'SHOP0002', 'dohongphuc', 'P017T001', 'PROD0017', 1, 'DELIV002'),
    ('ORDE0016', N'Nhanh', N'Đã hoàn thành', N'18 Tôn Thất Thuyết, TP.HCM', N'45 Hai Bà Trưng, Hà Nội', 'CREDIT', DATEADD(day,-12,GETDATE()), DATEADD(day,-8,GETDATE()), DATEADD(day,-7,GETDATE()), DATEADD(day,-12,GETDATE()), 1, 80000, 45000, 'SHOP0002', 'quynhtrang', 'P018T001', 'PROD0018', 4, 'DELIV001'),
    ('ORDE0017', N'Tiêu chuẩn', N'Đang xử lý', N'18 Tôn Thất Thuyết, TP.HCM', N'99 Lý Thường Kiệt, TP.HCM', 'COD', GETDATE(), DATEADD(day,2,GETDATE()), NULL, NULL, 1, 75000, 20000, 'SHOP0002', 'letrongtin', 'P019T001', 'PROD0019', 1, 'DELIV003'),
    ('ORDE0018', N'Nhanh', N'Đã hủy', N'18 Tôn Thất Thuyết, TP.HCM', N'77 Phạm Văn Đồng, TP.HCM', 'ZALOPAY', DATEADD(day,-3,GETDATE()), DATEADD(day,-1,GETDATE()), NULL, DATEADD(day,-3,GETDATE()), 1, 165000, 25000, 'SHOP0002', 'dohongphuc', 'P020T001', 'PROD0020', 3, 'DELIV002'),
    ('ORDE0019', N'Tiêu chuẩn', N'Đã hoàn thành', N'18 Tôn Thất Thuyết, TP.HCM', N'23 Võ Thị Sáu, Đà Nẵng', 'COD', DATEADD(day,-25,GETDATE()), DATEADD(day,-20,GETDATE()), DATEADD(day,-19,GETDATE()), DATEADD(day,-19,GETDATE()), 1, 950000, 40000, 'SHOP0002', 'quynhtrang', 'P021T001', 'PROD0021', 1, 'DELIV001'),
    -- SHOP 3 
    ('ORDE0020', N'Nhanh', N'Đang xử lý', N'456 Nguyễn Trãi, TP.HCM', N'12 Đồng Khởi, TP.HCM', 'CREDIT', GETDATE(), DATEADD(day,1,GETDATE()), NULL, GETDATE(), 1, 85000, 20000, 'SHOP0003', 'dohongphuc', 'P026T001', 'PROD0026', 1, 'DELIV003'),
    ('ORDE0021', N'Tiêu chuẩn', N'Đã hoàn thành', N'456 Nguyễn Trãi, TP.HCM', N'33 Tràng Tiền, Hà Nội', 'COD', DATEADD(day,-14,GETDATE()), DATEADD(day,-9,GETDATE()), DATEADD(day,-8,GETDATE()), DATEADD(day,-8,GETDATE()), 1, 250000, 45000, 'SHOP0003', 'letrongtin', 'P027T001', 'PROD0027', 1, 'DELIV002'),
    ('ORDE0022', N'Nhanh', N'Đang xử lý', N'456 Nguyễn Trãi, TP.HCM', N'76 Lê Lai, TP.HCM', 'ZALOPAY', GETDATE(), DATEADD(day,2,GETDATE()), NULL, GETDATE(), 1, 40000, 25000, 'SHOP0003', 'quynhtrang', 'P028T001', 'PROD0028', 1, 'DELIV001'),
    ('ORDE0023', N'Tiêu chuẩn', N'Đã hoàn thành', N'456 Nguyễn Trãi, TP.HCM', N'40 Võ Văn Kiệt, Cần Thơ', 'COD', DATEADD(day,-10,GETDATE()), DATEADD(day,-5,GETDATE()), DATEADD(day,-4,GETDATE()), DATEADD(day,-4,GETDATE()), 1, 550000, 35000, 'SHOP0003', 'dohongphuc', 'P029T001', 'PROD0029', 1, 'DELIV003'),
    ('ORDE0024', N'Nhanh', N'Đã hủy', N'456 Nguyễn Trãi, TP.HCM', N'15 Nguyễn Huệ, TP.HCM', 'CREDIT', DATEADD(day,-2,GETDATE()), DATEADD(day,0,GETDATE()), NULL, DATEADD(day,-2,GETDATE()), 1, 300000, 20000, 'SHOP0003', 'letrongtin', 'P030T001', 'PROD0030', 2, 'DELIV002'),
    -- SHOP 4 
    ('ORDE0025', N'Nhanh', N'Đang xử lý', N'56 Nguyễn Huệ, TP.HCM', N'13 Hai Bà Trưng, TP.HCM', 'COD', GETDATE(), DATEADD(day,1,GETDATE()), NULL, NULL, 1, 32000000, 30000, 'SHOP0004', 'quynhtrang', 'P036T001', 'PROD0036', 1, 'DELIV001'),
    ('ORDE0026', N'Tiêu chuẩn', N'Đã hoàn thành', N'56 Nguyễn Huệ, TP.HCM', N'99 Trần Phú, Nha Trang', 'ZALOPAY', DATEADD(day,-18,GETDATE()), DATEADD(day,-13,GETDATE()), DATEADD(day,-12,GETDATE()), DATEADD(day,-18,GETDATE()), 1, 400000, 40000, 'SHOP0004', 'dohongphuc', 'P038T001', 'PROD0038', 5, 'DELIV003'),
    ('ORDE0027', N'Nhanh', N'Đang xử lý', N'56 Nguyễn Huệ, TP.HCM', N'22 Hàng Bông, Hà Nội', 'CREDIT', GETDATE(), DATEADD(day,3,GETDATE()), NULL, GETDATE(), 1, 700000, 45000, 'SHOP0004', 'letrongtin', 'P039T001', 'PROD0039', 2, 'DELIV002'),
    ('ORDE0028', N'Tiêu chuẩn', N'Đã hoàn thành', N'56 Nguyễn Huệ, TP.HCM', N'88 Phạm Văn Đồng, TP.HCM', 'COD', DATEADD(day,-7,GETDATE()), DATEADD(day,-4,GETDATE()), DATEADD(day,-3,GETDATE()), DATEADD(day,-3,GETDATE()), 1, 650000, 25000, 'SHOP0004', 'quynhtrang', 'P040T001', 'PROD0040', 1, 'DELIV001'),
    ('ORDE0029', N'Nhanh', N'Đã hủy', N'56 Nguyễn Huệ, TP.HCM', N'34 Chợ Lớn, TP.HCM', 'ZALOPAY', DATEADD(day,-1,GETDATE()), DATEADD(day,0,GETDATE()), NULL, DATEADD(day,-1,GETDATE()), 1, 1000000, 20000, 'SHOP0004', 'dohongphuc', 'P042T001', 'PROD0042', 10, 'DELIV003'),
    -- SHOP 5 
    ('ORDE0003', N'Nhanh', N'Đang xử lý', N'202 Điện Biên Phủ, TP.HCM', N'101 Lê Duẩn, TP.HCM', 'CREDIT', GETDATE(), DATEADD(day,2,GETDATE()), DATEADD(day,2,GETDATE()), GETDATE(), 1, 12000000, 30000, 'SHOP0005', 'quynhtrang', 'P005T001', 'PROD0005', 1, 'DELIV003'),
    ('ORDE0030', N'Nhanh', N'Đang xử lý', N'101 Lê Duẩn, TP.HCM', N'55 Nguyễn Thị Minh Khai, TP.HCM', 'CREDIT', GETDATE(), DATEADD(day,1,GETDATE()), NULL, GETDATE(), 1, 28000000, 30000, 'SHOP0005', 'letrongtin', 'P046T001', 'PROD0046', 1, 'DELIV002'),
    ('ORDE0031', N'Tiêu chuẩn', N'Đã hoàn thành', N'101 Lê Duẩn, TP.HCM', N'12 Phan Bội Châu, Đà Nẵng', 'COD', DATEADD(day,-15,GETDATE()), DATEADD(day,-10,GETDATE()), DATEADD(day,-9,GETDATE()), DATEADD(day,-9,GETDATE()), 1, 19000000, 50000, 'SHOP0005', 'quynhtrang', 'P047T001', 'PROD0047', 1, 'DELIV001'),
    ('ORDE0032', N'Nhanh', N'Đang xử lý', N'101 Lê Duẩn, TP.HCM', N'77 Cộng Hòa, TP.HCM', 'ZALOPAY', GETDATE(), DATEADD(day,2,GETDATE()), NULL, GETDATE(), 1, 2000000, 20000, 'SHOP0005', 'dohongphuc', 'P048T001', 'PROD0048', 2, 'DELIV003'),
    ('ORDE0033', N'Tiêu chuẩn', N'Đã hoàn thành', N'101 Lê Duẩn, TP.HCM', N'44 Lê Hồng Phong, Hà Nội', 'COD', DATEADD(day,-22,GETDATE()), DATEADD(day,-17,GETDATE()), DATEADD(day,-16,GETDATE()), DATEADD(day,-16,GETDATE()), 1, 4500000, 45000, 'SHOP0005', 'letrongtin', 'P049T001', 'PROD0049', 1, 'DELIV002'),
    -- SHOP 6 
    ('ORDE0034', N'Nhanh', N'Đang xử lý', N'88 Huỳnh Văn Bánh, TP.HCM', N'Quận 1, TP.HCM', 'COD', GETDATE(), DATEADD(day,1,GETDATE()), NULL, NULL, 1, 900000, 20000, 'SHOP0006', 'thuytien_miss', 'P056T001', 'PROD0056', 1, 'DELIV001'),
    ('ORDE0035', N'Tiêu chuẩn', N'Đã hoàn thành', N'88 Huỳnh Văn Bánh, TP.HCM', N'Quận 3, TP.HCM', 'ZALOPAY', DATEADD(day,-5,GETDATE()), DATEADD(day,-3,GETDATE()), DATEADD(day,-2,GETDATE()), DATEADD(day,-2,GETDATE()), 1, 1200000, 20000, 'SHOP0006', 'viethuong_hai', 'P057T001', 'PROD0057', 1, 'DELIV002'),
    ('ORDE0036', N'Nhanh', N'Đang xử lý', N'88 Huỳnh Văn Bánh, TP.HCM', N'Phú Nhuận, TP.HCM', 'CREDIT', GETDATE(), DATEADD(day,2,GETDATE()), NULL, GETDATE(), 1, 3000000, 0, 'SHOP0006', 'ngan98_dj', 'P058T001', 'PROD0058', 1, 'DELIV003'),
    ('ORDE0037', N'Tiêu chuẩn', N'Đã hoàn thành', N'88 Huỳnh Văn Bánh, TP.HCM', N'Gò Vấp, TP.HCM', 'COD', DATEADD(day,-10,GETDATE()), DATEADD(day,-8,GETDATE()), DATEADD(day,-7,GETDATE()), DATEADD(day,-7,GETDATE()), 1, 300000, 15000, 'SHOP0006', 'chidan_singer', 'P059T001', 'PROD0059', 2, 'DELIV004'),
    ('ORDE0038', N'Nhanh', N'Đang xử lý', N'88 Huỳnh Văn Bánh, TP.HCM', N'Bình Thạnh, TP.HCM', 'ZALOPAY', GETDATE(), DATEADD(day,1,GETDATE()), NULL, GETDATE(), 1, 500000, 25000, 'SHOP0006', 'quynhtrang', 'P060T001', 'PROD0060', 1, 'DELIV005'),
    ('ORDE0039', N'Tiêu chuẩn', N'Đã hủy', N'88 Huỳnh Văn Bánh, TP.HCM', N'Quận 10, TP.HCM', 'COD', DATEADD(day,-2,GETDATE()), DATEADD(day,-1,GETDATE()), NULL, NULL, 1, 250000, 20000, 'SHOP0006', 'dohongphuc', 'P061T001', 'PROD0061', 1, 'DELIV001'),
    ('ORDE0040', N'Nhanh', N'Đang xử lý', N'88 Huỳnh Văn Bánh, TP.HCM', N'Tân Bình, TP.HCM', 'CREDIT', GETDATE(), DATEADD(day,2,GETDATE()), NULL, GETDATE(), 1, 450000, 20000, 'SHOP0006', 'letrongtin', 'P062T001', 'PROD0062', 1, 'DELIV002'),
    ('ORDE0041', N'Tiêu chuẩn', N'Đã hoàn thành', N'88 Huỳnh Văn Bánh, TP.HCM', N'Quận 7, TP.HCM', 'COD', DATEADD(day,-7,GETDATE()), DATEADD(day,-5,GETDATE()), DATEADD(day,-4,GETDATE()), DATEADD(day,-4,GETDATE()), 1, 600000, 30000, 'SHOP0006', 'maitrithuc', 'P063T001', 'PROD0063', 1, 'DELIV003'),
    ('ORDE0042', N'Nhanh', N'Đang xử lý', N'88 Huỳnh Văn Bánh, TP.HCM', N'Quận 12, TP.HCM', 'ZALOPAY', GETDATE(), DATEADD(day,3,GETDATE()), NULL, GETDATE(), 1, 600000, 25000, 'SHOP0006', 'ngominhtri', 'P064T001', 'PROD0064', 3, 'DELIV004'),
    ('ORDE0043', N'Tiêu chuẩn', N'Đã hoàn thành', N'88 Huỳnh Văn Bánh, TP.HCM', N'Thủ Đức, TP.HCM', 'CREDIT', DATEADD(day,-15,GETDATE()), DATEADD(day,-12,GETDATE()), DATEADD(day,-11,GETDATE()), DATEADD(day,-11,GETDATE()), 1, 200000, 20000, 'SHOP0006', 'phanphucthinh', 'P065T001', 'PROD0065', 1, 'DELIV005'),
    -- SHOP 7 
    ('ORDE0044', N'Nhanh', N'Đang xử lý', N'Quận 7, TP.HCM', N'Hà Nội', 'CREDIT', GETDATE(), DATEADD(day,3,GETDATE()), NULL, GETDATE(), 1, 300000, 50000, 'SHOP0007', 'chidan_singer', 'P066T001', 'PROD0066', 1, 'DELIV001'),
    ('ORDE0045', N'Tiêu chuẩn', N'Đã hoàn thành', N'Quận 7, TP.HCM', N'Đà Nẵng', 'COD', DATEADD(day,-20,GETDATE()), DATEADD(day,-15,GETDATE()), DATEADD(day,-14,GETDATE()), DATEADD(day,-14,GETDATE()), 1, 85000000, 200000, 'SHOP0007', 'thuytien_miss', 'P067T001', 'PROD0067', 1, 'DELIV002'),
    ('ORDE0046', N'Nhanh', N'Đang xử lý', N'Quận 7, TP.HCM', N'Cần Thơ', 'ZALOPAY', GETDATE(), DATEADD(day,2,GETDATE()), NULL, GETDATE(), 1, 15000000, 100000, 'SHOP0007', 'ngan98_dj', 'P068T001', 'PROD0068', 1, 'DELIV003'),
    ('ORDE0047', N'Tiêu chuẩn', N'Đã hoàn thành', N'Quận 7, TP.HCM', N'Hải Phòng', 'COD', DATEADD(day,-10,GETDATE()), DATEADD(day,-7,GETDATE()), DATEADD(day,-6,GETDATE()), DATEADD(day,-6,GETDATE()), 1, 3000000, 50000, 'SHOP0007', 'viethuong_hai', 'P069T001', 'PROD0069', 1, 'DELIV004'),
    ('ORDE0048', N'Nhanh', N'Đang xử lý', N'Quận 7, TP.HCM', N'Nha Trang', 'CREDIT', GETDATE(), DATEADD(day,3,GETDATE()), NULL, GETDATE(), 1, 9000000, 80000, 'SHOP0007', 'phanphucthinh', 'P070T001', 'PROD0070', 1, 'DELIV005'),
    ('ORDE0049', N'Tiêu chuẩn', N'Đã hủy', N'Quận 7, TP.HCM', N'Huế', 'COD', DATEADD(day,-5,GETDATE()), DATEADD(day,-3,GETDATE()), NULL, NULL, 1, 300000, 30000, 'SHOP0007', 'dohongphuc', 'P071T001', 'PROD0071', 2, 'DELIV001'),
    ('ORDE0050', N'Nhanh', N'Đang xử lý', N'Quận 7, TP.HCM', N'Bình Định', 'ZALOPAY', GETDATE(), DATEADD(day,2,GETDATE()), NULL, GETDATE(), 1, 250000, 25000, 'SHOP0007', 'quynhtrang', 'P072T001', 'PROD0072', 1, 'DELIV002'),
    ('ORDE0051', N'Tiêu chuẩn', N'Đã hoàn thành', N'Quận 7, TP.HCM', N'Quảng Ninh', 'COD', DATEADD(day,-15,GETDATE()), DATEADD(day,-12,GETDATE()), DATEADD(day,-11,GETDATE()), DATEADD(day,-11,GETDATE()), 1, 400000, 30000, 'SHOP0007', 'letrongtin', 'P073T001', 'PROD0073', 1, 'DELIV003'),
    ('ORDE0052', N'Nhanh', N'Đang xử lý', N'Quận 7, TP.HCM', N'Thanh Hóa', 'CREDIT', GETDATE(), DATEADD(day,1,GETDATE()), NULL, GETDATE(), 1, 5000000, 40000, 'SHOP0007', 'ngominhtri', 'P074T001', 'PROD0074', 1, 'DELIV004'),
    ('ORDE0053', N'Tiêu chuẩn', N'Đã hoàn thành', N'Quận 7, TP.HCM', N'Nghệ An', 'ZALOPAY', DATEADD(day,-25,GETDATE()), DATEADD(day,-20,GETDATE()), DATEADD(day,-19,GETDATE()), DATEADD(day,-19,GETDATE()), 1, 140000, 60000, 'SHOP0007', 'maitrithuc', 'P075T001', 'PROD0075', 1, 'DELIV005');
GO

INSERT INTO GIAO_DICH
    (MaGiaoDich, MaDonHang, TenDangNhapNguoiMua, TenDangNhapNguoiBan, PhuongThucThanhToan, TienGiaoDich, ThoiGianGiaoDich)
VALUES
    -- Shop 1 (Chủ: phanphucthinh)
    ('TX000001', 'ORDE0001', 'dohongphuc', 'phanphucthinh', 'COD', 220000, DATEADD(day,3,GETDATE())),
    ('TX000002', 'ORDE0004', 'quynhtrang', 'phanphucthinh', 'COD', 1545000, DATEADD(day,-4,GETDATE())),
    ('TX000003', 'ORDE0005', 'letrongtin', 'phanphucthinh', 'CREDIT', 885000, GETDATE()),
    ('TX000004', 'ORDE0006', 'dohongphuc', 'phanphucthinh', 'ZALOPAY', 920000, DATEADD(day,-5,GETDATE())),
    ('TX000005', 'ORDE0008', 'letrongtin', 'phanphucthinh', 'COD', 770000, DATEADD(day,-9,GETDATE())),
    ('TX000006', 'ORDE0009', 'dohongphuc', 'phanphucthinh', 'CREDIT', 645000, DATEADD(day,-7,GETDATE())),
    ('TX000007', 'ORDE0010', 'quynhtrang', 'phanphucthinh', 'ZALOPAY', 390000, DATEADD(day,-20,GETDATE())),
    ('TX000008', 'ORDE0012', 'dohongphuc', 'phanphucthinh', 'COD', 495000, DATEADD(day,-2,GETDATE())),
    ('TX000009', 'ORDE0013', 'quynhtrang', 'phanphucthinh', 'CREDIT', 2530000, GETDATE()),

    -- Shop 2 (Chủ: maitrithuc)
    ('TX000010', 'ORDE0002', 'dohongphuc', 'maitrithuc', 'COD', 165000, DATEADD(day,6,GETDATE())),
    ('TX000011', 'ORDE0014', 'letrongtin', 'maitrithuc', 'ZALOPAY', 195000, DATEADD(day,-8,GETDATE())),
    ('TX000012', 'ORDE0016', 'quynhtrang', 'maitrithuc', 'CREDIT', 125000, DATEADD(day,-12,GETDATE())),
    ('TX000013', 'ORDE0018', 'dohongphuc', 'maitrithuc', 'ZALOPAY', 190000, DATEADD(day,-3,GETDATE())),
    ('TX000014', 'ORDE0019', 'quynhtrang', 'maitrithuc', 'COD', 990000, DATEADD(day,-19,GETDATE())),

    -- Shop 3 (Chủ: nguyenngocton)
    ('TX000015', 'ORDE0020', 'dohongphuc', 'nguyenngocton', 'CREDIT', 105000, GETDATE()),
    ('TX000016', 'ORDE0021', 'letrongtin', 'nguyenngocton', 'COD', 295000, DATEADD(day,-8,GETDATE())),
    ('TX000017', 'ORDE0022', 'quynhtrang', 'nguyenngocton', 'ZALOPAY', 145000, GETDATE()),
    ('TX000018', 'ORDE0023', 'dohongphuc', 'nguyenngocton', 'COD', 585000, DATEADD(day,-4,GETDATE())),
    ('TX000019', 'ORDE0024', 'letrongtin', 'nguyenngocton', 'CREDIT', 320000, DATEADD(day,-2,GETDATE())),

    -- Shop 4 (Chủ: ngominhtri)
    ('TX000020', 'ORDE0026', 'dohongphuc', 'ngominhtri', 'ZALOPAY', 440000, DATEADD(day,-18,GETDATE())),
    ('TX000021', 'ORDE0027', 'letrongtin', 'ngominhtri', 'CREDIT', 745000, GETDATE()),
    ('TX000022', 'ORDE0028', 'quynhtrang', 'ngominhtri', 'COD', 675000, DATEADD(day,-3,GETDATE())),
    ('TX000023', 'ORDE0029', 'dohongphuc', 'ngominhtri', 'ZALOPAY', 520000, DATEADD(day,-1,GETDATE())),

    -- Shop 5 (Chủ: letrongtin)
    ('TX000024', 'ORDE0003', 'quynhtrang', 'letrongtin', 'CREDIT', 1230000, GETDATE()),
    ('TX000025', 'ORDE0030', 'letrongtin', 'letrongtin', 'CREDIT', 28030000, GETDATE()),
    ('TX000026', 'ORDE0031', 'quynhtrang', 'letrongtin', 'COD', 19050000, DATEADD(day,-9,GETDATE())),
    ('TX000027', 'ORDE0032', 'dohongphuc', 'letrongtin', 'ZALOPAY', 2420000, GETDATE()),
    ('TX000028', 'ORDE0033', 'letrongtin', 'letrongtin', 'COD', 4545000, DATEADD(day,-16,GETDATE())),

    -- Shop 6 (Chủ: mailisa_phan)
    ('TX000029', 'ORDE0035', 'viethuong_hai', 'mailisa_phan', 'ZALOPAY', 1220000, DATEADD(day,-2,GETDATE())),
    ('TX000030', 'ORDE0036', 'ngan98_dj', 'mailisa_phan', 'CREDIT', 3000000, GETDATE()),
    ('TX000031', 'ORDE0037', 'chidan_singer', 'mailisa_phan', 'COD', 715000, DATEADD(day,-7,GETDATE())),
    ('TX000032', 'ORDE0038', 'quynhtrang', 'mailisa_phan', 'ZALOPAY', 825000, GETDATE()),
    ('TX000033', 'ORDE0040', 'letrongtin', 'mailisa_phan', 'CREDIT', 470000, GETDATE()),
    ('TX000034', 'ORDE0041', 'maitrithuc', 'mailisa_phan', 'COD', 630000, DATEADD(day,-4,GETDATE())),
    ('TX000035', 'ORDE0042', 'ngominhtri', 'mailisa_phan', 'ZALOPAY', 625000, GETDATE()),
    ('TX000036', 'ORDE0043', 'phanphucthinh', 'mailisa_phan', 'CREDIT', 520000, DATEADD(day,-11,GETDATE())),

    -- Shop 7 (Chủ: luongbangquang)
    ('TX000037', 'ORDE0044', 'chidan_singer', 'luongbangquang', 'CREDIT', 1050000, GETDATE()),
    ('TX000038', 'ORDE0045', 'thuytien_miss', 'luongbangquang', 'COD', 85200000, DATEADD(day,-14,GETDATE())),
    ('TX000039', 'ORDE0046', 'ngan98_dj', 'luongbangquang', 'ZALOPAY', 25100000, GETDATE()),
    ('TX000040', 'ORDE0047', 'viethuong_hai', 'luongbangquang', 'COD', 3050000, DATEADD(day,-6,GETDATE())),
    ('TX000041', 'ORDE0048', 'phanphucthinh', 'luongbangquang', 'CREDIT', 9080000, GETDATE()),
    ('TX000042', 'ORDE0050', 'quynhtrang', 'luongbangquang', 'ZALOPAY', 275000, GETDATE()),
    ('TX000043', 'ORDE0051', 'letrongtin', 'luongbangquang', 'COD', 430000, DATEADD(day,-11,GETDATE())),
    ('TX000044', 'ORDE0052', 'ngominhtri', 'luongbangquang', 'CREDIT', 5040000, GETDATE()),
    ('TX000045', 'ORDE0053', 'maitrithuc', 'luongbangquang', 'ZALOPAY', 14060000, DATEADD(day,-19,GETDATE()));
GO

INSERT INTO AP_DUNG_MA_GIAM_GIA
    (MaVoucher, MaDonHang)
VALUES
    ('VCHR0001', 'ORDE0001'),
    ('VCHR0002', 'ORDE0002'),
    ('VCHR0005', 'ORDE0003'),
    ('VCHR0001', 'ORDE0034'),
    ('VCHR0002', 'ORDE0035'),
    ('VCHR0003', 'ORDE0044'),
    ('SALE0005', 'ORDE0045');
GO

-- ======================================================================================
-- PHẦN BỔ SUNG: TẠO CÁC BẢNG AUDIT ĐỂ GHI LOG TRIGGER
-- ======================================================================================

-- --------------------------------------------------------------------------------------
-- BẢNG 1: AUDIT_SAN_PHAM - Ghi log mọi thao tác INSERT/UPDATE/DELETE trên SAN_PHAM
-- Phục vụ cho Trigger 1 & 2 (Mục 2.1)
-- --------------------------------------------------------------------------------------
CREATE TABLE AUDIT_SAN_PHAM
(
    ID INT IDENTITY(1,1) PRIMARY KEY,
    MaSanPham VARCHAR(100) NOT NULL,
    HanhDong VARCHAR(20) NOT NULL,
    -- 'INSERT', 'UPDATE', 'DELETE'
    ThoiGian DATETIME NOT NULL DEFAULT GETDATE(),
    NguoiThucHien VARCHAR(100) DEFAULT SYSTEM_USER,
    -- User SQL Server

    -- Thông tin CŨ (trước khi thay đổi)
    TenSanPhamCu NVARCHAR(255),
    GiaHienThiCu DECIMAL(18, 2),
    LoaiCu NVARCHAR(100),
    ThongTinCu NVARCHAR(511),
    LinkSanPhamCu VARCHAR(511),

    -- Thông tin MỚI (sau khi thay đổi)
    TenSanPhamMoi NVARCHAR(255),
    GiaHienThiMoi DECIMAL(18, 2),
    LoaiMoi NVARCHAR(100),
    ThongTinMoi NVARCHAR(511),
    LinkSanPhamMoi VARCHAR(511),

    -- Lý do từ trigger (nếu có)
    LyDo NVARCHAR(MAX)
);

-- --------------------------------------------------------------------------------------
-- BẢNG 2: AUDIT_XOA_SAN_PHAM - Ghi log chi tiết khi xóa sản phẩm (cascade)
-- Phục vụ cho Trigger 2 (Mục 2.1)
-- --------------------------------------------------------------------------------------
CREATE TABLE AUDIT_XOA_SAN_PHAM
(
    ID INT IDENTITY(1,1) PRIMARY KEY,
    MaSanPham VARCHAR(100) NOT NULL,
    ThoiGian DATETIME NOT NULL DEFAULT GETDATE(),
    NguoiThucHien VARCHAR(100) DEFAULT SYSTEM_USER,

    -- Thông tin sản phẩm bị xóa
    TenSanPham NVARCHAR(255),
    GiaHienThi DECIMAL(18, 2),
    MaSoShop CHAR(8),

    -- Thống kê dữ liệu bị xóa cascade
    SoLuongBienTheXoa INT DEFAULT 0,
    SoLuongDanhGiaXoa INT DEFAULT 0,
    SoLuongAnhVideoXoa INT DEFAULT 0,
    SoLuongGioHangXoa INT DEFAULT 0,

    TrangThai NVARCHAR(50)
    -- 'Thành công', 'Lỗi: Sản phẩm có trong đơn hàng'
);

-- --------------------------------------------------------------------------------------
-- BẢNG 3: AUDIT_KHO - Ghi log thay đổi số lượng kho (BIEN_THE_SAN_PHAM)
-- Phục vụ cho Trigger 3 (Mục 2.2)
-- --------------------------------------------------------------------------------------
CREATE TABLE AUDIT_KHO
(
    ID INT IDENTITY(1,1) PRIMARY KEY,
    MaDonHang CHAR(8) NOT NULL,
    ID_BienThe VARCHAR(100) NOT NULL,
    MaSanPham VARCHAR(100) NOT NULL,
    ThoiGian DATETIME NOT NULL DEFAULT GETDATE(),

    HanhDong NVARCHAR(50) NOT NULL,
    -- 'Đặt hàng', 'Hủy đơn', 'Kích hoạt lại'
    SoLuongDat INT NOT NULL,
    SoLuongKhoCu INT NOT NULL,
    SoLuongKhoMoi INT NOT NULL,
    ChenhLech INT NOT NULL,
    -- Âm = Trừ kho, Dương = Hoàn kho

    TrangThai NVARCHAR(50)
    -- 'Thành công', 'Lỗi: Không đủ hàng'
);

-- --------------------------------------------------------------------------------------
-- BẢNG 4: AUDIT_DANH_GIA - Ghi log thay đổi số sao sản phẩm
-- Phục vụ cho Trigger 4 (Mục 2.2)
-- --------------------------------------------------------------------------------------
CREATE TABLE AUDIT_DANH_GIA
(
    ID INT IDENTITY(1,1) PRIMARY KEY,
    MaSanPham VARCHAR(100) NOT NULL,
    ThoiGian DATETIME NOT NULL DEFAULT GETDATE(),

    HanhDong NVARCHAR(50) NOT NULL,
    -- 'Thêm đánh giá', 'Sửa đánh giá', 'Xóa đánh giá'
    MaDanhGia VARCHAR(100),
    SoSaoThayDoi INT,
    -- Số sao của đánh giá bị thêm/sửa/xóa

    SoSaoCu DECIMAL(2, 1),
    -- Số sao trung bình CŨ
    SoSaoMoi DECIMAL(2, 1),
    -- Số sao trung bình MỚI
    TongSoDanhGia INT
    -- Tổng số đánh giá hiện tại
);
GO

PRINT N'✅ Đã tạo 4 bảng AUDIT để ghi log triggers';
GO

USE HeThongBanHang;
GO

PRINT N'=== 1. NHÓM NGƯỜI DÙNG & TÀI KHOẢN ===';
SELECT *
FROM NGUOI_DUNG;
SELECT *
FROM DIA_CHI;
SELECT *
FROM LIEN_KET_MANG_XA_HOI;
SELECT *
FROM TAI_KHOAN_NGAN_HANG;
SELECT *
FROM THEO_DOI;

PRINT N'=== 2. NHÓM VAI TRÒ (ADMIN - MUA - BÁN) ===';
SELECT *
FROM QUAN_TRI_VIEN;
SELECT *
FROM NGUOI_MUA;
SELECT *
FROM NGUOI_BAN;
SELECT *
FROM CHAN_NGUOI_MUA;
SELECT *
FROM CHAN_NGUOI_BAN;

PRINT N'=== 3. NHÓM CỬA HÀNG & SẢN PHẨM ===';
SELECT *
FROM CUA_HANG;
SELECT *
FROM SAN_PHAM;
SELECT *
FROM LINK_ANH_VIDEO_SAN_PHAM;
SELECT *
FROM BIEN_THE_SAN_PHAM;
SELECT *
FROM THONG_TIN_BIEN_THE;
SELECT *
FROM DUYET_SAN_PHAM;

PRINT N'=== 4. NHÓM GIỎ HÀNG & ĐƠN HÀNG ===';
SELECT *
FROM GIO_HANG;
SELECT *
FROM GIO_HANG_CHUA;
SELECT *
FROM DON_VI_VAN_CHUYEN;
SELECT *
FROM PHUONG_THUC_VAN_CHUYEN;
SELECT *
FROM DON_HANG;
SELECT *
FROM GIAO_DICH;

PRINT N'=== 5. NHÓM KHUYẾN MÃI & ĐÁNH GIÁ & TỐ CÁO ===';
SELECT *
FROM MA_GIAM_GIA;
SELECT *
FROM MAT_HANG_AP_DUNG;
SELECT *
FROM AP_DUNG_MA_GIAM_GIA;
SELECT *
FROM DANH_GIA;
SELECT *
FROM LINK_ANH_VIDEO_DANH_GIA;
SELECT *
FROM TO_CAO;
SELECT *
FROM NHAN_TIN;

-- -------------------------------------
-- -------------------------------------
-- -------------------------------------

ALTER TABLE SAN_PHAM
ADD SoSaoSanPham DECIMAL(2, 1) DEFAULT 0;
GO

-- ===

-- CREATE TRIGGER TR_DANH_GIA_CapNhatSoSaoSanPham
-- ON DANH_GIA
-- AFTER INSERT, UPDATE, DELETE
-- AS
-- BEGIN
--     -- Kiểm tra xem có dòng nào bị ảnh hưởng không 
--     IF EXISTS (SELECT *
--         FROM inserted) OR EXISTS (SELECT *
--         FROM deleted)
--    BEGIN
--         -- BƯỚC 1: Xác định danh sách các MaSanPham cần được cập nhật
--         -- Lấy MaSanPham từ cả bảng 'inserted' (thêm mới/giá trị mới sau sửa)
--         -- và bảng 'deleted' (giá trị cũ trước sửa/xóa)
--         DECLARE @MaSanPhamBiAnhHuong TABLE (
--             MaSanPham VARCHAR(100) PRIMARY KEY
--        );

--         INSERT INTO @MaSanPhamBiAnhHuong
--             (MaSanPham)
--                     SELECT MaSanPham
--             FROM inserted
--         UNION
--             SELECT MaSanPham
--             FROM deleted;


--         -- BƯỚC 2: Cập nhật cột SoSaoSanPham trong bảng SAN_PHAM
--         UPDATE SP
--        SET SoSaoSanPham = ISNULL(
--            (
--                SELECT AVG(CAST(DG.SoSao AS DECIMAL(2, 1)))
--         -- Tính trung bình sao
--         FROM DANH_GIA DG
--         WHERE DG.MaSanPham = SP.MaSanPham
--            ),
--            0.0 -- Nếu không còn đánh giá nào, mặc định là 0.0
--        )
--        FROM SAN_PHAM SP
--             INNER JOIN @MaSanPhamBiAnhHuong T -- Chỉ cập nhật những sản phẩm bị ảnh hưởng
--             ON SP.MaSanPham = T.MaSanPham;
--     END
-- END;
-- GO


-- Cập nhật SoSaoSanPham ban đầu (cần chạy 1 lần để Trigger tính toán dữ liệu ban đầu)
UPDATE SP
SET SoSaoSanPham = ISNULL(
    (
        SELECT AVG(CAST(DG.SoSao AS DECIMAL(2, 1)))
FROM DANH_GIA DG
WHERE DG.MaSanPham = SP.MaSanPham
    ), 
    0.0
)
FROM SAN_PHAM SP;
GO


-- ==================== TESTCASE ====================

-- 1. Xem SoSaoSanPham ban đầu
-- Sản phẩm PROD0001 có 1 đánh giá 5 sao. Sản phẩm PROD0002 có 1 đánh giá 4 sao.
SELECT MaSanPham, TenSanPham, SoSaoSanPham
FROM SAN_PHAM
WHERE MaSanPham IN ('PROD0001', 'PROD0002', 'PROD0003');
-- Kết quả dự kiến: PROD0001 = 5.0, PROD0002 = 4.0

-- 2. Test INSERT (Thêm một đánh giá 3 sao cho PROD0001)
INSERT INTO DANH_GIA
    (MaDanhGia, MaSanPham, TenDangNhapNguoiMua, MaSoShop, SoSao, NoiDung)
VALUES
    ('REVI0006', 'PROD0001', 'quynhtrang', 'SHOP0001', 3, N'Chất lượng tạm được');
GO

-- Kiểm tra kết quả
SELECT MaSanPham, TenSanPham, SoSaoSanPham
FROM SAN_PHAM
WHERE MaSanPham = 'PROD0001';
-- Kết quả dự kiến: (5 + 3) / 2 = 4.0

-- 3. Test UPDATE (Sửa đánh giá 5 sao thành 1 sao)
UPDATE DANH_GIA
SET SoSao = 1
WHERE MaDanhGia = 'REVI0001';
GO

-- Kiểm tra kết quả
SELECT MaSanPham, TenSanPham, SoSaoSanPham
FROM SAN_PHAM
WHERE MaSanPham = 'PROD0001';
-- Kết quả dự kiến: (1 + 3) / 2 = 2.0

-- 4. Test DELETE (Xóa đánh giá 3 sao)
-- Phải xóa dữ liệu con trước (nếu có link ảnh/video)
DELETE FROM LINK_ANH_VIDEO_DANH_GIA
WHERE MaDanhGia = 'REVI0006';

-- Sau đó mới xóa đánh giá
DELETE FROM DANH_GIA
WHERE MaDanhGia = 'REVI0006';
GO

-- Kiểm tra kết quả
SELECT MaSanPham, TenSanPham, SoSaoSanPham
FROM SAN_PHAM
WHERE MaSanPham = 'PROD0001';
-- Kết quả dự kiến: Còn lại 1 đánh giá 1 sao. Trung bình là 1.0

