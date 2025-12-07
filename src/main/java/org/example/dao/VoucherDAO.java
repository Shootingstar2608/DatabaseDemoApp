package org.example.dao;

import org.example.model.ReceiptDTO;
import org.example.model.VoucherDTO;
import org.example.database.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class VoucherDAO {

    // Hàm cũ: Lấy danh sách voucher để hiển thị Popup
    public List<VoucherDTO> getVoucherKhaDung(String maDonHang, String maShop, String maAdmin, String maTransport) {
        List<VoucherDTO> list = new ArrayList<>();
        String query = "SELECT * FROM dbo.fn_LayVoucherKhaDung(?, ?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            setParams(ps, maDonHang, maShop, maAdmin, maTransport);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                VoucherDTO v = new VoucherDTO();
                v.setMaVoucher(rs.getString("MaVoucher"));
                v.setTenVoucher(rs.getString("TenVoucher"));
                v.setLoaiVoucher(rs.getString("LoaiVoucher"));
                v.setMoTaGiamGia(rs.getString("MoTaGiamGia"));
                v.setSoTienGiam(rs.getInt("SoTienGiam"));
                v.setDieuKienApDung(rs.getString("DieuKienApDung"));
                v.setTrangThaiApDung(rs.getString("TrangThaiApDung"));
                v.setGiaApDung(rs.getBigDecimal("GiaApDung"));
                v.setGiaSauGiam(rs.getBigDecimal("GiaSauGiam"));
                v.setTongDonHangSauVoucher(rs.getBigDecimal("TongDonHangSauVoucher"));
                v.setChuThich(rs.getString("ChuThich"));
                v.setCoTheApDung(rs.getBoolean("CoTheApDung"));
                v.setLyDoKhongApDung(rs.getString("LyDoKhongApDung"));
                list.add(v);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // --- HÀM MỚI: TÍNH TOÁN CHI TIẾT HÓA ĐƠN (GỌI FUNCTION RECEIPT) ---
    public ReceiptDTO getReceiptDetails(String maDonHang, String maShop, String maAdmin, String maTransport) {
        ReceiptDTO receipt = null;
        String query = "SELECT * FROM dbo.fn_TinhChiTietDonHang(?, ?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            setParams(ps, maDonHang, maShop, maAdmin, maTransport);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                receipt = new ReceiptDTO();
                receipt.setMaDonHang(rs.getString("MaDonHang"));
                receipt.setGiaNiemYet(rs.getBigDecimal("GiaNiemYet"));
                receipt.setTienChietKhau(rs.getBigDecimal("TienChietKhau"));
                receipt.setGiaGoc(rs.getBigDecimal("GiaGoc"));
                receipt.setPhiVanChuyen(rs.getBigDecimal("PhiVanChuyen"));
                
                receipt.setMaVoucherShop(rs.getString("MaVoucherShop"));
                receipt.setGiamGiaShop(rs.getBigDecimal("GiamGiaShop"));
                
                receipt.setMaVoucherAdmin(rs.getString("MaVoucherAdmin"));
                receipt.setGiamGiaAdmin(rs.getBigDecimal("GiamGiaAdmin"));
                
                receipt.setMaVoucherShip(rs.getString("MaVoucherShip"));
                receipt.setGiamGiaShip(rs.getBigDecimal("GiamGiaShip"));
                
                receipt.setTongThanhToan(rs.getBigDecimal("TONG_THANH_TOAN"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return receipt;
    }

    // --- HÀM MỚI: GỌI PROCEDURE ĐẶT HÀNG ---
    public boolean placeOrder(String maDonHang, String maShop, String maAdmin, String maTransport) {
        String query = "{CALL dbo.sp_DatHang(?, ?, ?, ?)}"; // Cú pháp gọi SP

        try (Connection conn = DatabaseConnection.getConnection();
             CallableStatement cs = conn.prepareCall(query)) {

            cs.setString(1, maDonHang);
            
            if (maShop == null || maShop.trim().isEmpty()) cs.setNull(2, Types.CHAR);
            else cs.setString(2, maShop);

            if (maAdmin == null || maAdmin.trim().isEmpty()) cs.setNull(3, Types.CHAR);
            else cs.setString(3, maAdmin);

            if (maTransport == null || maTransport.trim().isEmpty()) cs.setNull(4, Types.CHAR);
            else cs.setString(4, maTransport);

            boolean hasResults = cs.execute();
            
            return true;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Helper set params
    private void setParams(PreparedStatement ps, String maDon, String v1, String v2, String v3) throws SQLException {
        ps.setString(1, maDon);
        if (v1 == null || v1.trim().isEmpty()) ps.setNull(2, Types.CHAR); else ps.setString(2, v1);
        if (v2 == null || v2.trim().isEmpty()) ps.setNull(3, Types.CHAR); else ps.setString(3, v2);
        if (v3 == null || v3.trim().isEmpty()) ps.setNull(4, Types.CHAR); else ps.setString(4, v3);
    }
}