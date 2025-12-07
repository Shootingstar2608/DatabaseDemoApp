package org.example.model;

import java.math.BigDecimal;

public class VoucherDTO {
    private int stt;
    private String maVoucher;
    private String tenVoucher;
    private String loaiVoucher; // SHOP, ADMIN, TRANSPORT
    private String moTaGiamGia;
    private int soTienGiam;
    private String dieuKienApDung;
    private String trangThaiApDung;
    private BigDecimal giaApDung;
    private BigDecimal giaSauGiam;
    private BigDecimal tongDonHangSauVoucher;
    private String chuThich;
    private boolean coTheApDung;
    private String lyDoKhongApDung;

    // Constructor không tham số
    public VoucherDTO() {
    }

    // Getters and Setters (Generate đầy đủ nhé)
    public int getStt() { return stt; }
    public void setStt(int stt) { this.stt = stt; }

    public String getMaVoucher() { return maVoucher; }
    public void setMaVoucher(String maVoucher) { this.maVoucher = maVoucher; }

    public String getTenVoucher() { return tenVoucher; }
    public void setTenVoucher(String tenVoucher) { this.tenVoucher = tenVoucher; }

    public String getLoaiVoucher() { return loaiVoucher; }
    public void setLoaiVoucher(String loaiVoucher) { this.loaiVoucher = loaiVoucher; }

    public String getMoTaGiamGia() { return moTaGiamGia; }
    public void setMoTaGiamGia(String moTaGiamGia) { this.moTaGiamGia = moTaGiamGia; }

    public int getSoTienGiam() { return soTienGiam; }
    public void setSoTienGiam(int soTienGiam) { this.soTienGiam = soTienGiam; }

    public String getDieuKienApDung() { return dieuKienApDung; }
    public void setDieuKienApDung(String dieuKienApDung) { this.dieuKienApDung = dieuKienApDung; }

    public String getTrangThaiApDung() { return trangThaiApDung; }
    public void setTrangThaiApDung(String trangThaiApDung) { this.trangThaiApDung = trangThaiApDung; }

    public BigDecimal getGiaApDung() { return giaApDung; }
    public void setGiaApDung(BigDecimal giaApDung) { this.giaApDung = giaApDung; }

    public BigDecimal getGiaSauGiam() { return giaSauGiam; }
    public void setGiaSauGiam(BigDecimal giaSauGiam) { this.giaSauGiam = giaSauGiam; }

    public BigDecimal getTongDonHangSauVoucher() { return tongDonHangSauVoucher; }
    public void setTongDonHangSauVoucher(BigDecimal tongDonHangSauVoucher) { this.tongDonHangSauVoucher = tongDonHangSauVoucher; }

    public String getChuThich() { return chuThich; }
    public void setChuThich(String chuThich) { this.chuThich = chuThich; }

    public boolean isCoTheApDung() { return coTheApDung; }
    public void setCoTheApDung(boolean coTheApDung) { this.coTheApDung = coTheApDung; }

    public String getLyDoKhongApDung() { return lyDoKhongApDung; }
    public void setLyDoKhongApDung(String lyDoKhongApDung) { this.lyDoKhongApDung = lyDoKhongApDung; }
}