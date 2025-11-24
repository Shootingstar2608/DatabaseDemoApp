package org.example.dao;

import org.example.database.DatabaseConnection;
import org.example.model.SanPham;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class SanPhamDAO {

    // Hàm lấy toàn bộ danh sách sản phẩm
    public List<SanPham> layDanhSachSanPham() {
        List<SanPham> danhSach = new ArrayList<>();
        String sql = "SELECT * FROM SAN_PHAM"; // Tên bảng trong SQL

        try {
            Connection conn = DatabaseConnection.getConnection();
            PreparedStatement stmt = conn.prepareStatement(sql);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                SanPham sp = new SanPham();
                // Map dữ liệu từ cột SQL vào thuộc tính Java
                sp.setMaSanPham(rs.getString("MaSanPham"));
                sp.setMaSoShop(rs.getString("MaSoShop"));
                sp.setTenSanPham(rs.getString("TenSanPham"));
                sp.setThongTinSanPham(rs.getString("ThongTinSanPham"));
                sp.setLinkSanPham(rs.getString("LinkSanPham"));
                sp.setGiaHienThi(rs.getDouble("GiaHienThi"));
                sp.setLoai(rs.getString("Loai"));

                danhSach.add(sp);
            }

            rs.close();
            stmt.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return danhSach;
    }

}