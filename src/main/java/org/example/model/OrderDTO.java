package org.example.model;

import java.math.BigDecimal;
import java.util.Date;

public class OrderDTO {
    private int stt;
    private String maDonHang;
    private String tenSanPhamHienThi;
    private String tenNguoiMua;
    private int soLuong;
    private BigDecimal donGia;
    private BigDecimal giaBanDau;
    private BigDecimal thanhTien;
    private BigDecimal thucThu;
    private String trangThai;
    private Date ngayDat;
    private Date ngayDuKienGiao;

    public OrderDTO() {}

    // Getters and Setters
    public int getStt() { return stt; }
    public void setStt(int stt) { this.stt = stt; }

    public String getMaDonHang() { return maDonHang; }
    public void setMaDonHang(String maDonHang) { this.maDonHang = maDonHang; }

    public String getTenSanPhamHienThi() { return tenSanPhamHienThi; }
    public void setTenSanPhamHienThi(String tenSanPhamHienThi) { this.tenSanPhamHienThi = tenSanPhamHienThi; }

    public String getTenNguoiMua() { return tenNguoiMua; }
    public void setTenNguoiMua(String tenNguoiMua) { this.tenNguoiMua = tenNguoiMua; }

    public int getSoLuong() { return soLuong; }
    public void setSoLuong(int soLuong) { this.soLuong = soLuong; }

    public BigDecimal getDonGia() { return donGia; }
    public void setDonGia(BigDecimal donGia) { this.donGia = donGia; }

    public BigDecimal getGiaBanDau() { return giaBanDau; }
    public void setGiaBanDau(BigDecimal giaBanDau) { this.giaBanDau = giaBanDau; }

    public BigDecimal getThanhTien() { return thanhTien; }
    public void setThanhTien(BigDecimal thanhTien) { this.thanhTien = thanhTien; }

    public BigDecimal getThucThu() { return thucThu; }
    public void setThucThu(BigDecimal thucThu) { this.thucThu = thucThu; }

    public String getTrangThai() { return trangThai; }
    public void setTrangThai(String trangThai) { this.trangThai = trangThai; }

    public Date getNgayDat() { return ngayDat; }
    public void setNgayDat(Date ngayDat) { this.ngayDat = ngayDat; }

    public Date getNgayDuKienGiao() { return ngayDuKienGiao; }
    public void setNgayDuKienGiao(Date ngayDuKienGiao) { this.ngayDuKienGiao = ngayDuKienGiao; }
}