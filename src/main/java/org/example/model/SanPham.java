package org.example.model;

public class SanPham {
    private String maSanPham;       // PK: VARCHAR(100)
    private String maSoShop;        // FK: CHAR(8)
    private String tenSanPham;      // NVARCHAR(255)
    private String thongTinSanPham; // NVARCHAR(511)
    private String linkSanPham;     // VARCHAR(511)
    private double giaHienThi;      // DECIMAL(18, 2)
    private String loai;            // NVARCHAR(100)


    public SanPham() {
    }

    public SanPham(String maSanPham, String maSoShop, String tenSanPham,
                   String thongTinSanPham, String linkSanPham,
                   double giaHienThi, String loai) {
        this.maSanPham = maSanPham;
        this.maSoShop = maSoShop;
        this.tenSanPham = tenSanPham;
        this.thongTinSanPham = thongTinSanPham;
        this.linkSanPham = linkSanPham;
        this.giaHienThi = giaHienThi;
        this.loai = loai;
    }

    public String getMaSanPham() {
        return maSanPham;
    }

    public void setMaSanPham(String maSanPham) {
        this.maSanPham = maSanPham;
    }

    public String getMaSoShop() {
        return maSoShop;
    }

    public void setMaSoShop(String maSoShop) {
        this.maSoShop = maSoShop;
    }

    public String getTenSanPham() {
        return tenSanPham;
    }

    public void setTenSanPham(String tenSanPham) {
        this.tenSanPham = tenSanPham;
    }

    public String getThongTinSanPham() {
        return thongTinSanPham;
    }

    public void setThongTinSanPham(String thongTinSanPham) {
        this.thongTinSanPham = thongTinSanPham;
    }

    public String getLinkSanPham() {
        return linkSanPham;
    }

    public void setLinkSanPham(String linkSanPham) {
        this.linkSanPham = linkSanPham;
    }

    public double getGiaHienThi() {
        return giaHienThi;
    }

    public void setGiaHienThi(double giaHienThi) {
        this.giaHienThi = giaHienThi;
    }

    public String getLoai() {
        return loai;
    }

    public void setLoai(String loai) {
        this.loai = loai;
    }

    // cho dễ debug
    @Override
    public String toString() {
        return "SanPham{" +
                "maSanPham='" + maSanPham + '\'' +
                ", tenSanPham='" + tenSanPham + '\'' +
                ", giaHienThi=" + giaHienThi +
                '}';
    }
}