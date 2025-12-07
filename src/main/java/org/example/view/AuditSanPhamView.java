package org.example.view;

import org.example.database.DatabaseConnection;
import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import javax.swing.table.DefaultTableCellRenderer;
import java.awt.*;
import java.sql.*;
import java.text.SimpleDateFormat;

/**
 * Giao diện hiển thị lịch sử thay đổi (AUDIT) của sản phẩm
 * Phục vụ cho Trigger 1 & 2 (Mục 2.1)
 */
public class AuditSanPhamView extends JFrame {
    private JTable tableAudit;
    private DefaultTableModel tableModel;
    private JTable tableXoa;
    private DefaultTableModel tableModelXoa;
    private JComboBox<String> cboLoaiAudit;
    private JTextField txtTimKiemMaSP;
    private SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

    public AuditSanPhamView() {
        initUI();
        loadAuditData();
    }

    private void initUI() {
        setTitle("📋 Lịch sử thay đổi sản phẩm (Audit Log)");
        setSize(1400, 800);
        setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        setLocationRelativeTo(null);

        // Panel chính
        JPanel mainPanel = new JPanel(new BorderLayout(10, 10));
        mainPanel.setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 20));

        // ===== PANEL TIÊU ĐỀ =====
        JPanel headerPanel = new JPanel(new BorderLayout());
        JLabel lblTitle = new JLabel("📋 LỊCH SỬ THAY ĐỔI SẢN PHẨM", SwingConstants.CENTER);
        lblTitle.setFont(new Font("Segoe UI", Font.BOLD, 24));
        lblTitle.setForeground(new Color(0, 102, 204));
        headerPanel.add(lblTitle, BorderLayout.CENTER);

        JLabel lblSubtitle = new JLabel("Ghi log bởi Trigger 1 & 2 (Mục 2.1)", SwingConstants.CENTER);
        lblSubtitle.setFont(new Font("Segoe UI", Font.ITALIC, 14));
        lblSubtitle.setForeground(Color.GRAY);
        headerPanel.add(lblSubtitle, BorderLayout.SOUTH);

        // ===== PANEL BỘ LỌC =====
        JPanel filterPanel = new JPanel(new FlowLayout(FlowLayout.LEFT, 15, 10));
        filterPanel.setBorder(BorderFactory.createTitledBorder("🔍 Bộ lọc"));

        filterPanel.add(new JLabel("Mã sản phẩm:"));
        txtTimKiemMaSP = new JTextField(20);
        filterPanel.add(txtTimKiemMaSP);

        JButton btnTimKiem = new JButton("🔍 Tìm kiếm");
        btnTimKiem.addActionListener(e -> loadAuditData());
        filterPanel.add(btnTimKiem);

        JButton btnLamMoi = new JButton("🔄 Làm mới");
        btnLamMoi.addActionListener(e -> {
            txtTimKiemMaSP.setText("");
            loadAuditData();
        });
        filterPanel.add(btnLamMoi);

        // ===== TABBED PANE: 2 TAB (AUDIT_SAN_PHAM + AUDIT_XOA_SAN_PHAM) =====
        JTabbedPane tabbedPane = new JTabbedPane();

        // Tab 1: Audit Thêm/Sửa sản phẩm
        JPanel tabAudit = createAuditTablePanel();
        tabbedPane.addTab("✏️ Lịch sử Thêm/Sửa", tabAudit);

        // Tab 2: Audit Xóa sản phẩm
        JPanel tabXoa = createXoaTablePanel();
        tabbedPane.addTab("🗑️ Lịch sử Xóa", tabXoa);

        // ===== GHÉP CÁC THÀNH PHẦN =====
        mainPanel.add(headerPanel, BorderLayout.NORTH);
        mainPanel.add(filterPanel, BorderLayout.NORTH);
        mainPanel.add(tabbedPane, BorderLayout.CENTER);

        add(mainPanel);
    }

    // ===== TAB 1: AUDIT_SAN_PHAM (INSERT/UPDATE) =====
    private JPanel createAuditTablePanel() {
        JPanel panel = new JPanel(new BorderLayout());

        String[] columns = {
                "ID", "Mã SP", "Hành động", "Thời gian", "Người thực hiện",
                "Tên CŨ", "Giá CŨ", "Tên MỚI", "Giá MỚI"
        };
        tableModel = new DefaultTableModel(columns, 0) {
            @Override
            public boolean isCellEditable(int row, int column) {
                return false;
            }
        };

        tableAudit = new JTable(tableModel);
        tableAudit.setRowHeight(30);
        tableAudit.setFont(new Font("Segoe UI", Font.PLAIN, 14));
        tableAudit.getTableHeader().setFont(new Font("Segoe UI", Font.BOLD, 14));
        tableAudit.setSelectionBackground(new Color(184, 207, 229));

        // Căn giữa các cột số
        DefaultTableCellRenderer centerRenderer = new DefaultTableCellRenderer();
        centerRenderer.setHorizontalAlignment(SwingConstants.CENTER);
        tableAudit.getColumnModel().getColumn(0).setCellRenderer(centerRenderer); // ID
        tableAudit.getColumnModel().getColumn(2).setCellRenderer(centerRenderer); // Hành động

        JScrollPane scrollPane = new JScrollPane(tableAudit);

        // 🔥 THÊM NÚT "XEM CHI TIẾT"
        JPanel buttonPanel = new JPanel(new FlowLayout(FlowLayout.CENTER, 10, 10));
        JButton btnChiTiet = new JButton("👁️ Xem chi tiết");
        btnChiTiet.setFont(new Font("Segoe UI", Font.BOLD, 14));
        btnChiTiet.setBackground(new Color(0, 123, 255));
        btnChiTiet.setForeground(Color.WHITE);
        btnChiTiet.addActionListener(e -> {
            int selectedRow = tableAudit.getSelectedRow();
            if (selectedRow >= 0) {
                showAuditDetail(selectedRow);
            } else {
                JOptionPane.showMessageDialog(this, "Vui lòng chọn một bản ghi!", "Thông báo",
                        JOptionPane.WARNING_MESSAGE);
            }
        });
        buttonPanel.add(btnChiTiet);

        panel.add(scrollPane, BorderLayout.CENTER);
        panel.add(buttonPanel, BorderLayout.SOUTH);

        return panel;
    }

    // ===== TAB 2: AUDIT_XOA_SAN_PHAM (DELETE CASCADE) =====
    private JPanel createXoaTablePanel() {
        JPanel panel = new JPanel(new BorderLayout());

        String[] columns = {
                "ID", "Mã SP", "Tên SP", "Giá", "Mã Shop", "Thời gian",
                "Người thực hiện", "Trạng thái"
        };
        tableModelXoa = new DefaultTableModel(columns, 0) {
            @Override
            public boolean isCellEditable(int row, int column) {
                return false;
            }
        };

        tableXoa = new JTable(tableModelXoa);
        tableXoa.setRowHeight(30);
        tableXoa.setFont(new Font("Segoe UI", Font.PLAIN, 14));
        tableXoa.getTableHeader().setFont(new Font("Segoe UI", Font.BOLD, 14));
        tableXoa.setSelectionBackground(new Color(255, 200, 200));

        JScrollPane scrollPane = new JScrollPane(tableXoa);

        // 🔥 THÊM NÚT "XEM CHI TIẾT"
        JPanel buttonPanel = new JPanel(new FlowLayout(FlowLayout.CENTER, 10, 10));
        JButton btnChiTiet = new JButton("👁️ Xem chi tiết");
        btnChiTiet.setFont(new Font("Segoe UI", Font.BOLD, 14));
        btnChiTiet.setBackground(new Color(220, 53, 69));
        btnChiTiet.setForeground(Color.WHITE);
        btnChiTiet.addActionListener(e -> {
            int selectedRow = tableXoa.getSelectedRow();
            if (selectedRow >= 0) {
                showXoaDetail(selectedRow);
            } else {
                JOptionPane.showMessageDialog(this, "Vui lòng chọn một bản ghi!", "Thông báo",
                        JOptionPane.WARNING_MESSAGE);
            }
        });
        buttonPanel.add(btnChiTiet);

        panel.add(scrollPane, BorderLayout.CENTER);
        panel.add(buttonPanel, BorderLayout.SOUTH);

        return panel;
    }

    // ===== LOAD DỮ LIỆU TỪ DATABASE =====
    private void loadAuditData() {
        loadAuditSanPham();
        loadAuditXoa();
    }

    private void loadAuditSanPham() {
        tableModel.setRowCount(0);
        String maSP = txtTimKiemMaSP.getText().trim();

        StringBuilder sql = new StringBuilder("SELECT TOP 100 * FROM AUDIT_SAN_PHAM WHERE 1=1");

        if (!maSP.isEmpty()) {
            sql.append(" AND MaSanPham LIKE '%").append(maSP).append("%'");
        }

        sql.append(" ORDER BY ThoiGian DESC");

        try (Connection conn = DatabaseConnection.getConnection();
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(sql.toString())) {

            while (rs.next()) {
                Object[] row = {
                        rs.getInt("ID"),
                        rs.getString("MaSanPham"),
                        rs.getString("HanhDong"),
                        dateFormat.format(rs.getTimestamp("ThoiGian")),
                        rs.getString("NguoiThucHien"),
                        rs.getString("TenSanPhamCu"),
                        rs.getBigDecimal("GiaHienThiCu"),
                        rs.getString("TenSanPhamMoi"),
                        rs.getBigDecimal("GiaHienThiMoi")
                };
                tableModel.addRow(row);
            }

        } catch (SQLException e) {
            JOptionPane.showMessageDialog(this,
                    "Lỗi khi tải dữ liệu audit: " + e.getMessage(),
                    "Lỗi Database",
                    JOptionPane.ERROR_MESSAGE);
        }
    }

    private void loadAuditXoa() {
        tableModelXoa.setRowCount(0);
        String maSP = txtTimKiemMaSP.getText().trim();

        StringBuilder sql = new StringBuilder("SELECT TOP 50 * FROM AUDIT_XOA_SAN_PHAM WHERE 1=1");

        if (!maSP.isEmpty()) {
            sql.append(" AND MaSanPham LIKE '%").append(maSP).append("%'");
        }

        sql.append(" ORDER BY ThoiGian DESC");

        try (Connection conn = DatabaseConnection.getConnection();
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(sql.toString())) {

            while (rs.next()) {
                Object[] row = {
                        rs.getInt("ID"),
                        rs.getString("MaSanPham"),
                        rs.getString("TenSanPham"),
                        rs.getBigDecimal("GiaHienThi"),
                        rs.getString("MaSoShop"),
                        dateFormat.format(rs.getTimestamp("ThoiGian")),
                        rs.getString("NguoiThucHien"),
                        rs.getString("TrangThai")
                };
                tableModelXoa.addRow(row);
            }

        } catch (SQLException e) {
            JOptionPane.showMessageDialog(this,
                    "Lỗi khi tải dữ liệu xóa: " + e.getMessage(),
                    "Lỗi Database",
                    JOptionPane.ERROR_MESSAGE);
        }
    }

    // 🔥 HÀM HIỂN THỊ CHI TIẾT AUDIT THÊM/SỬA
    private void showAuditDetail(int row) {
        int id = (int) tableModel.getValueAt(row, 0);

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement("SELECT * FROM AUDIT_SAN_PHAM WHERE ID = ?")) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                StringBuilder detail = new StringBuilder();
                detail.append("════════════════════════════════════════\n");
                detail.append("         CHI TIẾT LỊCH SỬ THAY ĐỔI\n");
                detail.append("════════════════════════════════════════\n\n");

                detail.append("🆔 ID: ").append(rs.getInt("ID")).append("\n");
                detail.append("📦 Mã sản phẩm: ").append(rs.getString("MaSanPham")).append("\n");
                detail.append("⚡ Hành động: ").append(rs.getString("HanhDong")).append("\n");
                detail.append("🕒 Thời gian: ").append(dateFormat.format(rs.getTimestamp("ThoiGian"))).append("\n");
                detail.append("👤 Người thực hiện: ").append(rs.getString("NguoiThucHien")).append("\n\n");

                detail.append("────────── GIÁ TRỊ CŨ ──────────\n");
                detail.append("📝 Tên: ")
                        .append(rs.getString("TenSanPhamCu") != null ? rs.getString("TenSanPhamCu") : "(Không có)")
                        .append("\n");
                detail.append("💰 Giá: ")
                        .append(rs.getBigDecimal("GiaHienThiCu") != null
                                ? String.format("%,.0f VNĐ", rs.getBigDecimal("GiaHienThiCu"))
                                : "(Không có)")
                        .append("\n");
                detail.append("🏷️ Loại: ")
                        .append(rs.getString("LoaiCu") != null ? rs.getString("LoaiCu") : "(Không có)").append("\n");
                detail.append("📄 Thông tin: ")
                        .append(rs.getString("ThongTinCu") != null ? rs.getString("ThongTinCu") : "(Không có)")
                        .append("\n");
                detail.append("🔗 Link: ")
                        .append(rs.getString("LinkSanPhamCu") != null ? rs.getString("LinkSanPhamCu") : "(Không có)")
                        .append("\n\n");

                detail.append("────────── GIÁ TRỊ MỚI ──────────\n");
                detail.append("📝 Tên: ")
                        .append(rs.getString("TenSanPhamMoi") != null ? rs.getString("TenSanPhamMoi") : "(Không có)")
                        .append("\n");
                detail.append("💰 Giá: ")
                        .append(rs.getBigDecimal("GiaHienThiMoi") != null
                                ? String.format("%,.0f VNĐ", rs.getBigDecimal("GiaHienThiMoi"))
                                : "(Không có)")
                        .append("\n");
                detail.append("🏷️ Loại: ")
                        .append(rs.getString("LoaiMoi") != null ? rs.getString("LoaiMoi") : "(Không có)").append("\n");
                detail.append("📄 Thông tin: ")
                        .append(rs.getString("ThongTinMoi") != null ? rs.getString("ThongTinMoi") : "(Không có)")
                        .append("\n");
                detail.append("🔗 Link: ")
                        .append(rs.getString("LinkSanPhamMoi") != null ? rs.getString("LinkSanPhamMoi") : "(Không có)")
                        .append("\n\n");

                detail.append("────────── LÝ DO ──────────\n");
                detail.append(rs.getString("LyDo") != null ? rs.getString("LyDo") : "(Không có lý do)").append("\n");

                JTextArea textArea = new JTextArea(detail.toString());
                textArea.setEditable(false);
                textArea.setFont(new Font("Courier New", Font.PLAIN, 14));
                JScrollPane scrollPane = new JScrollPane(textArea);
                scrollPane.setPreferredSize(new Dimension(600, 500));

                JOptionPane.showMessageDialog(this, scrollPane,
                        "Chi tiết Audit #" + id,
                        JOptionPane.INFORMATION_MESSAGE);
            }

        } catch (SQLException e) {
            JOptionPane.showMessageDialog(this,
                    "Lỗi khi tải chi tiết: " + e.getMessage(),
                    "Lỗi",
                    JOptionPane.ERROR_MESSAGE);
        }
    }

    // 🔥 HÀM HIỂN THỊ CHI TIẾT XÓA
    private void showXoaDetail(int row) {
        int id = (int) tableModelXoa.getValueAt(row, 0);

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement("SELECT * FROM AUDIT_XOA_SAN_PHAM WHERE ID = ?")) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                StringBuilder detail = new StringBuilder();
                detail.append("════════════════════════════════════════\n");
                detail.append("         CHI TIẾT LỊCH SỬ XÓA\n");
                detail.append("════════════════════════════════════════\n\n");

                detail.append("🆔 ID: ").append(rs.getInt("ID")).append("\n");
                detail.append("📦 Mã sản phẩm: ").append(rs.getString("MaSanPham")).append("\n");
                detail.append("📝 Tên sản phẩm: ").append(rs.getString("TenSanPham")).append("\n");
                detail.append("💰 Giá: ").append(String.format("%,.0f VNĐ", rs.getBigDecimal("GiaHienThi")))
                        .append("\n");
                detail.append("🏪 Mã Shop: ").append(rs.getString("MaSoShop")).append("\n");
                detail.append("🕒 Thời gian: ").append(dateFormat.format(rs.getTimestamp("ThoiGian"))).append("\n");
                detail.append("👤 Người thực hiện: ").append(rs.getString("NguoiThucHien")).append("\n\n");

                detail.append("────── THỐNG KÊ DỮ LIỆU BỊ XÓA ──────\n");
                detail.append("🔢 Biến thể xóa: ").append(rs.getInt("SoLuongBienTheXoa")).append("\n");
                detail.append("⭐ Đánh giá xóa: ").append(rs.getInt("SoLuongDanhGiaXoa")).append("\n");
                detail.append("🖼️ Ảnh/Video xóa: ").append(rs.getInt("SoLuongAnhVideoXoa")).append("\n");
                detail.append("🛒 Giỏ hàng xóa: ").append(rs.getInt("SoLuongGioHangXoa")).append("\n\n");

                detail.append("────────── TRẠNG THÁI ──────────\n");
                String trangThai = rs.getString("TrangThai");
                detail.append(trangThai.startsWith("Lỗi") ? "❌ " : "✅ ").append(trangThai).append("\n");

                JTextArea textArea = new JTextArea(detail.toString());
                textArea.setEditable(false);
                textArea.setFont(new Font("Courier New", Font.PLAIN, 14));
                JScrollPane scrollPane = new JScrollPane(textArea);
                scrollPane.setPreferredSize(new Dimension(550, 450));

                JOptionPane.showMessageDialog(this, scrollPane,
                        "Chi tiết xóa #" + id,
                        JOptionPane.INFORMATION_MESSAGE);
            }

        } catch (SQLException e) {
            JOptionPane.showMessageDialog(this,
                    "Lỗi khi tải chi tiết: " + e.getMessage(),
                    "Lỗi",
                    JOptionPane.ERROR_MESSAGE);
        }
    }

    // Test giao diện
    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            try {
                UIManager.setLookAndFeel(new com.formdev.flatlaf.FlatLightLaf());
            } catch (Exception e) {
                e.printStackTrace();
            }
            new AuditSanPhamView().setVisible(true);
        });
    }
}
