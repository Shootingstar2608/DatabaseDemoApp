package org.example.model;

import java.math.BigDecimal;

public class ReceiptDTO {
    private String maDonHang;
    
    // --- MỚI THÊM ---
    private BigDecimal giaNiemYet;   // Giá ban đầu (chưa trừ gì cả)
    private BigDecimal tienChietKhau; // Tiền giảm do chiết khấu %
    // ----------------
    
    private BigDecimal giaGoc; // Đây là giá sau khi đã trừ chiết khấu (dùng để tính voucher)
    private BigDecimal phiVanChuyen;
    
    private String maVoucherShop;
    private BigDecimal giamGiaShop;
    
    private String maVoucherAdmin;
    private BigDecimal giamGiaAdmin;
    
    private String maVoucherShip;
    private BigDecimal giamGiaShip;
    
    private BigDecimal tongThanhToan;

    public ReceiptDTO() {}

    // Getters and Setters cho trường mới
    public BigDecimal getGiaNiemYet() { return giaNiemYet; }
    public void setGiaNiemYet(BigDecimal giaNiemYet) { this.giaNiemYet = giaNiemYet; }

    public BigDecimal getTienChietKhau() { return tienChietKhau; }
    public void setTienChietKhau(BigDecimal tienChietKhau) { this.tienChietKhau = tienChietKhau; }

    // Các Getter/Setter cũ giữ nguyên...
    public String getMaDonHang() { return maDonHang; }
    public void setMaDonHang(String maDonHang) { this.maDonHang = maDonHang; }

    public BigDecimal getGiaGoc() { return giaGoc; }
    public void setGiaGoc(BigDecimal giaGoc) { this.giaGoc = giaGoc; }

    public BigDecimal getPhiVanChuyen() { return phiVanChuyen; }
    public void setPhiVanChuyen(BigDecimal phiVanChuyen) { this.phiVanChuyen = phiVanChuyen; }

    public String getMaVoucherShop() { return maVoucherShop; }
    public void setMaVoucherShop(String maVoucherShop) { this.maVoucherShop = maVoucherShop; }

    public BigDecimal getGiamGiaShop() { return giamGiaShop; }
    public void setGiamGiaShop(BigDecimal giamGiaShop) { this.giamGiaShop = giamGiaShop; }

    public String getMaVoucherAdmin() { return maVoucherAdmin; }
    public void setMaVoucherAdmin(String maVoucherAdmin) { this.maVoucherAdmin = maVoucherAdmin; }

    public BigDecimal getGiamGiaAdmin() { return giamGiaAdmin; }
    public void setGiamGiaAdmin(BigDecimal giamGiaAdmin) { this.giamGiaAdmin = giamGiaAdmin; }

    public String getMaVoucherShip() { return maVoucherShip; }
    public void setMaVoucherShip(String maVoucherShip) { this.maVoucherShip = maVoucherShip; }

    public BigDecimal getGiamGiaShip() { return giamGiaShip; }
    public void setGiamGiaShip(BigDecimal giamGiaShip) { this.giamGiaShip = giamGiaShip; }

    public BigDecimal getTongThanhToan() { return tongThanhToan; }
    public void setTongThanhToan(BigDecimal tongThanhToan) { this.tongThanhToan = tongThanhToan; }
}