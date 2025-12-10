package org.example.dao;

import org.example.database.DatabaseConnection;
import org.example.model.SanPhamBanChay;
import org.example.model.TopKhachHang;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ThongKeDAO {

    // Gọi thủ tục sp_ThongKeSanPhamBanChay
    public List<SanPhamBanChay> getThongKeSanPhamBanChay(String loai, int soLuongToiThieu) {
        List<SanPhamBanChay> list = new ArrayList<>();
        String sql = "{call sp_ThongKeSanPhamBanChay(?, ?)}";

        try (Connection conn = DatabaseConnection.getConnection();
                CallableStatement stmt = conn.prepareCall(sql)) {

            stmt.setString(1, loai == null || loai.trim().isEmpty() ? null : loai);
            stmt.setInt(2, soLuongToiThieu);

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                SanPhamBanChay sp = new SanPhamBanChay();
                sp.setLoaiSanPham(rs.getString("LoaiSanPham"));
                sp.setMaSanPham(rs.getString("MaSanPham"));
                sp.setTenSanPham(rs.getString("TenSanPham"));
                sp.setTenShop(rs.getString("TenShop"));
                sp.setSoDonHang(rs.getInt("SoDonHang"));
                sp.setTongSoLuongDaBan(rs.getInt("TongSoLuongDaBan"));
                sp.setGiaTrungBinh(rs.getDouble("GiaTrungBinh"));
                sp.setTongDoanhThu(rs.getDouble("TongDoanhThu"));
                list.add(sp);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Gọi thủ tục sp_ThongKeTopKhachHang
    public List<TopKhachHang> getTopKhachHang(int topN, double tongChiToiThieu) {
        List<TopKhachHang> list = new ArrayList<>();
        String sql = "{call sp_ThongKeTopKhachHang(?, ?)}";

        try (Connection conn = DatabaseConnection.getConnection();
                CallableStatement stmt = conn.prepareCall(sql)) {

            stmt.setInt(1, topN);
            stmt.setDouble(2, tongChiToiThieu);

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                TopKhachHang kh = new TopKhachHang();
                kh.setTenDangNhap(rs.getString("TenDangNhap"));
                kh.setHoVaTen(rs.getString("HoVaTen"));
                kh.setEmail(rs.getString("Email"));
                kh.setSoDienThoai(rs.getString("SoDienThoai"));
                kh.setSoDonHang(rs.getInt("SoDonHang"));
                kh.setTongChiTieu(rs.getDouble("TongChiTieu"));
                kh.setGiaTriDonTrungBinh(rs.getDouble("GiaTriDonTrungBinh"));
                kh.setDiemTichLuy(rs.getInt("DiemTichLuy"));
                list.add(kh);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
