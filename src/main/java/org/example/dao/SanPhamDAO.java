package org.example.dao;

import org.example.database.DatabaseConnection;
import org.example.model.SanPham;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class SanPhamDAO {

    // 1. TÌM KIẾM & HIỂN THỊ (GỌI THỦ TỤC sp_TraCuuSanPham)
    // Cập nhật: Gọi thủ tục với 7 tham số (thêm @TuKhoa cho ô tìm kiếm nhanh)
    public List<SanPham> timKiemKetHop(String tuKhoaNhanh, String ma, String ten, String loai, String giaMin,
            String giaMax, String shop) {
        List<SanPham> danhSach = new ArrayList<>();

        // Gọi thủ tục SQL (7 dấu hỏi cho 7 tham số)
        String sql = "{call sp_TraCuuSanPham(?, ?, ?, ?, ?, ?, ?)}";

        try {
            Connection conn = DatabaseConnection.getConnection();
            CallableStatement stmt = conn.prepareCall(sql);

            // --- MAPPING THAM SỐ ---

            // 1. @MaSP (Lấy từ ô chi tiết)
            stmt.setString(1, (ma != null && !ma.trim().isEmpty()) ? ma : null);

            // 2. @TenSP (Lấy từ ô chi tiết)
            stmt.setString(2, (ten != null && !ten.trim().isEmpty()) ? ten : null);

            // 3. @Loai
            stmt.setString(3, (loai != null && !loai.trim().isEmpty()) ? loai : null);

            // 4. @Shop
            stmt.setString(4, (shop != null && !shop.trim().isEmpty()) ? shop : null);

            // 5. @GiaMin
            try {
                if (giaMin != null && !giaMin.trim().isEmpty())
                    stmt.setDouble(5, Double.parseDouble(giaMin));
                else
                    stmt.setNull(5, java.sql.Types.DECIMAL);
            } catch (NumberFormatException e) {
                stmt.setNull(5, java.sql.Types.DECIMAL);
            }

            // 6. @GiaMax
            try {
                if (giaMax != null && !giaMax.trim().isEmpty())
                    stmt.setDouble(6, Double.parseDouble(giaMax));
                else
                    stmt.setNull(6, java.sql.Types.DECIMAL);
            } catch (NumberFormatException e) {
                stmt.setNull(6, java.sql.Types.DECIMAL);
            }

            // 7. @TuKhoa (Ô Tìm kiếm nhanh ở trên cùng)
            stmt.setString(7, (tuKhoaNhanh != null && !tuKhoaNhanh.trim().isEmpty()) ? tuKhoaNhanh : null);

            // --- THỰC THI ---
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                SanPham sp = new SanPham();
                sp.setMaSanPham(rs.getString("MaSanPham"));
                sp.setTenSanPham(rs.getString("TenSanPham"));
                sp.setGiaHienThi(rs.getDouble("GiaHienThi"));
                sp.setLoai(rs.getString("Loai"));
                sp.setMaSoShop(rs.getString("MaSoShop"));

                // Lấy LinkSanPham
                try {
                    String linkSP = rs.getString("LinkSanPham");
                    sp.setLinkSanPham(linkSP != null ? linkSP : "");
                } catch (Exception e) {
                    sp.setLinkSanPham("");
                }

                // Lấy tên shop
                try {
                    String tenShop = rs.getString("TenShop");
                    sp.setTenShop(tenShop != null ? tenShop : "Không xác định");
                } catch (Exception e) {
                    sp.setTenShop("Lỗi hiển thị");
                }

                // Lấy tên chủ shop (nếu có)
                try {
                    String tenChu = rs.getString("TenChuShop");
                    sp.setTenChuShop(tenChu != null ? tenChu : "");
                } catch (Exception e) {
                    // Bỏ qua
                }

                danhSach.add(sp);
            }
            rs.close();
            stmt.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("LỖI SQL: " + e.getMessage());
        }
        return danhSach;
    }

    // Hàm lấy tất cả (Gọi lại hàm tìm kiếm với tham số null)
    public List<SanPham> layDanhSachSanPham() {
        return timKiemKetHop(null, null, null, null, null, null, null);
    }

    // Alias cho giao diện CRUD (tương thích)
    public List<SanPham> traCuuSanPham(String maSP, String tenSP, String loai, String shop, String giaMin,
            String giaMax, String tuKhoa) {
        return timKiemKetHop(tuKhoa, maSP, tenSP, loai, giaMin, giaMax, shop);
    }

    // =====================================================================
    // CÁC HÀM CRUD (THÊM / SỬA / XÓA) - ĐÃ KÍCH HOẠT LẠI
    // =====================================================================

    // 2. THÊM SẢN PHẨM (Gọi sp_ThemSanPham)
    public boolean themSanPham(SanPham sp) {
        String sql = "{call sp_ThemSanPham(?, ?, ?, ?, ?, ?, ?)}"; // 7 tham số

        try (Connection conn = DatabaseConnection.getConnection();
                CallableStatement stmt = conn.prepareCall(sql)) {

            stmt.setString(1, sp.getMaSanPham());
            stmt.setString(2, sp.getMaSoShop());
            stmt.setString(3, sp.getTenSanPham());
            stmt.setString(4, sp.getThongTinSanPham() != null && !sp.getThongTinSanPham().isEmpty()
                    ? sp.getThongTinSanPham()
                    : "Mô tả mặc định");
            stmt.setString(5, sp.getLinkSanPham() != null && !sp.getLinkSanPham().isEmpty()
                    ? sp.getLinkSanPham()
                    : "link_" + sp.getMaSanPham() + "_" + System.currentTimeMillis() + ".com");
            stmt.setDouble(6, sp.getGiaHienThi());
            stmt.setString(7, sp.getLoai());

            stmt.executeUpdate();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // 3. CẬP NHẬT SẢN PHẨM (Gọi sp_CapNhatSanPham)
    public boolean capNhatSanPham(String maSP, String tenSP, String thongTinSP, double gia, String loai) {
        String sql = "{call sp_CapNhatSanPham(?, ?, ?, ?, ?)}"; // 5 tham số

        try (Connection conn = DatabaseConnection.getConnection();
                CallableStatement stmt = conn.prepareCall(sql)) {

            stmt.setString(1, maSP);
            stmt.setString(2, tenSP);
            stmt.setString(3, thongTinSP);
            stmt.setDouble(4, gia);
            stmt.setString(5, loai);

            stmt.executeUpdate();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // 4. XÓA SẢN PHẨM (Gọi sp_XoaSanPham)
    public boolean xoaSanPham(String maSP) {
        String sql = "{call sp_XoaSanPham(?)}"; // 1 tham số

        try (Connection conn = DatabaseConnection.getConnection();
                CallableStatement stmt = conn.prepareCall(sql)) {

            stmt.setString(1, maSP);
            stmt.executeUpdate();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}