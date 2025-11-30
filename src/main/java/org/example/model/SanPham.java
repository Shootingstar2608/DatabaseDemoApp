package org.example.model;

public class SanPham {
    private String maSanPham;
    private String maSoShop;
    private String tenSanPham;
    private String thongTinSanPham;
    private String linkSanPham;
    private double giaHienThi;
    private String loai;
    
    // Các biến mở rộng (Lấy từ bảng khác qua JOIN)
    private String tenShop;
    private String tenChuShop;   // <--- MỚI: Tên chủ shop
    private String emailChuShop; // <--- MỚI: Email chủ shop

    public SanPham() {
    }

    public SanPham(String maSanPham, String maSoShop, String tenSanPham, String thongTinSanPham, String linkSanPham, double giaHienThi, String loai, String tenShop) {
        this.maSanPham = maSanPham;
        this.maSoShop = maSoShop;
        this.tenSanPham = tenSanPham;
        this.thongTinSanPham = thongTinSanPham;
        this.linkSanPham = linkSanPham;
        this.giaHienThi = giaHienThi;
        this.loai = loai;
        this.tenShop = tenShop;
    }

    // --- GETTER & SETTER CŨ (GIỮ NGUYÊN) ---
    public String getMaSanPham() { return maSanPham; }
    public void setMaSanPham(String maSanPham) { this.maSanPham = maSanPham; }

    public String getMaSoShop() { return maSoShop; }
    public void setMaSoShop(String maSoShop) { this.maSoShop = maSoShop; }

    public String getTenSanPham() { return tenSanPham; }
    public void setTenSanPham(String tenSanPham) { this.tenSanPham = tenSanPham; }

    public String getThongTinSanPham() { return thongTinSanPham; }
    public void setThongTinSanPham(String thongTinSanPham) { this.thongTinSanPham = thongTinSanPham; }

    public String getLinkSanPham() { return linkSanPham; }
    public void setLinkSanPham(String linkSanPham) { this.linkSanPham = linkSanPham; }

    public double getGiaHienThi() { return giaHienThi; }
    public void setGiaHienThi(double giaHienThi) { this.giaHienThi = giaHienThi; }

    public String getLoai() { return loai; }
    public void setLoai(String loai) { this.loai = loai; }

    public String getTenShop() { return tenShop; }
    public void setTenShop(String tenShop) { this.tenShop = tenShop; }

    // --- 👇 GETTER & SETTER MỚI (BẮT BUỘC THÊM) ---
    
    public String getTenChuShop() { return tenChuShop; }
    public void setTenChuShop(String tenChuShop) { this.tenChuShop = tenChuShop; }

    public String getEmailChuShop() { return emailChuShop; }
    public void setEmailChuShop(String emailChuShop) { this.emailChuShop = emailChuShop; }

    @Override
    public String toString() {
        return tenSanPham;
    }
}