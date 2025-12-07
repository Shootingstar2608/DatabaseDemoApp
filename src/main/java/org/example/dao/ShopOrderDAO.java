package org.example.dao;

import org.example.model.OrderDTO;
import org.example.database.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ShopOrderDAO {

    public List<OrderDTO> getOrdersByShop(String maShop) {
        List<OrderDTO> list = new ArrayList<>();
        String query = "SELECT * FROM dbo.fn_LietKeDonHangCuaShop(?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, maShop);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                OrderDTO o = new OrderDTO();
                o.setStt(rs.getInt("STT"));
                o.setMaDonHang(rs.getString("MaDonHang"));
                o.setTenSanPhamHienThi(rs.getString("TenSanPhamHienThi"));
                o.setTenNguoiMua(rs.getString("TenNguoiMua"));
                o.setSoLuong(rs.getInt("SoLuong"));
                o.setDonGia(rs.getBigDecimal("DonGia"));
                o.setGiaBanDau(rs.getBigDecimal("GiaBanDau"));
                o.setThanhTien(rs.getBigDecimal("ThanhTien"));
                o.setThucThu(rs.getBigDecimal("ThucThu"));
                o.setTrangThai(rs.getString("TrangThai"));
                o.setNgayDat(rs.getTimestamp("NgayDat")); // Dùng getTimestamp để lấy cả giờ phút
                o.setNgayDuKienGiao(rs.getDate("NgayDuKienGiao"));
                
                list.add(o);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}