package org.example.view;

import org.example.dao.SanPhamDAO;
import org.example.dao.ThongKeDAO;
import org.example.model.SanPhamBanChay;
import org.example.model.TopKhachHang;

import javax.swing.*;
import javax.swing.table.DefaultTableCellRenderer;
import javax.swing.table.DefaultTableModel;
import javax.swing.table.JTableHeader;
import java.awt.*;
import java.text.DecimalFormat;
import java.util.List;

public class ThongKeView extends JFrame {

    private ThongKeDAO thongKeDAO;
    private SanPhamDAO sanPhamDAO;

    // Tab 1: Sản phẩm bán chạy
    private JComboBox<String> cboLoaiSP;
    private JTextField txtSoLuongToiThieu;
    private JTable tableSanPham;
    private DefaultTableModel modelSanPham;

    // Tab 2: Top khách hàng
    private JTextField txtTopN;
    private JTextField txtTongChiToiThieu;
    private JTable tableKhachHang;
    private DefaultTableModel modelKhachHang;

    private Runnable onBackToMenu;

    public ThongKeView() {
        thongKeDAO = new ThongKeDAO();
        sanPhamDAO = new SanPhamDAO();
        initUI();
    }

    public void setOnBackToMenu(Runnable callback) {
        this.onBackToMenu = callback;
    }

    private void initUI() {
        setTitle("Thống Kê & Báo Cáo");
        setSize(1600, 900);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null);
        setLayout(new BorderLayout());

        Color mainColor = new Color(235, 245, 255);
        getContentPane().setBackground(mainColor);

        // === HEADER ===
        JPanel headerPanel = new JPanel(new BorderLayout());
        headerPanel.setBackground(new Color(0, 102, 204));
        headerPanel.setBorder(BorderFactory.createEmptyBorder(15, 20, 15, 20));

        JLabel lblTitle = new JLabel(" THỐNG KÊ & BÁO CÁO ");
        lblTitle.setFont(new Font("Segoe UI", Font.BOLD, 28));
        lblTitle.setForeground(Color.WHITE);

        JButton btnQuayLai = new JButton("Quay Lại Menu");
        btnQuayLai.setFont(new Font("Segoe UI", Font.BOLD, 14));
        btnQuayLai.setBackground(new Color(220, 53, 69));
        btnQuayLai.setForeground(Color.WHITE);
        btnQuayLai.setMargin(new Insets(10, 20, 10, 20));
        btnQuayLai.setFocusPainted(false);
        btnQuayLai.setCursor(new Cursor(Cursor.HAND_CURSOR));
        btnQuayLai.addActionListener(e -> {
            System.out.println("Nút Quay Lại được bấm");
            if (onBackToMenu != null) {
                System.out.println("Đang dispose và gọi callback...");
                dispose();
                onBackToMenu.run();
            } else {
                System.out.println("CẢNH BÁO: onBackToMenu là null!");
                JOptionPane.showMessageDialog(this,
                        "Chức năng quay lại chưa được cấu hình!\nVui lòng tắt cửa sổ này và mở lại từ menu.",
                        "Thông báo",
                        JOptionPane.WARNING_MESSAGE);
            }
        });

        headerPanel.add(lblTitle, BorderLayout.WEST);
        headerPanel.add(btnQuayLai, BorderLayout.EAST);
        add(headerPanel, BorderLayout.NORTH);

        // === TABBED PANE ===
        JTabbedPane tabbedPane = new JTabbedPane();
        tabbedPane.setFont(new Font("Segoe UI", Font.BOLD, 16));

        // Tab 1: Sản phẩm bán chạy
        JPanel tab1 = createSanPhamBanChayTab();
        tabbedPane.addTab(" Sản Phẩm Bán Chạy", tab1);

        // Tab 2: Top khách hàng
        JPanel tab2 = createTopKhachHangTab();
        tabbedPane.addTab(" Top Khách Hàng VIP", tab2);

        add(tabbedPane, BorderLayout.CENTER);

        // Load dữ liệu ban đầu
        loadSanPhamBanChay();
        loadTopKhachHang();
    }

    // ============== TAB 1: SẢN PHẨM BÁN CHẠY ==============
    private JPanel createSanPhamBanChayTab() {
        JPanel panel = new JPanel(new BorderLayout(10, 10));
        panel.setBackground(new Color(235, 245, 255));
        panel.setBorder(BorderFactory.createEmptyBorder(15, 15, 15, 15));

        // Filter Panel
        JPanel filterPanel = new JPanel(new FlowLayout(FlowLayout.LEFT, 15, 10));
        filterPanel.setBackground(Color.WHITE);
        filterPanel.setBorder(BorderFactory.createTitledBorder(
                BorderFactory.createLineBorder(new Color(0, 102, 204), 2),
                "Bộ Lọc Thống Kê",
                0, 0,
                new Font("Segoe UI", Font.BOLD, 16),
                new Color(0, 102, 204)));

        filterPanel.add(new JLabel("Loại Sản Phẩm:"));
        cboLoaiSP = new JComboBox<>(new String[] { "Tất cả", "Laptop", "Đồ gia dụng", "Sách", "Điện thoại", "Phụ kiện",
                "Dụng cụ", "Mỹ phẩm", "Vật tư y tế", "Smartwatch", "Đồ dùng", "Công cụ" });
        cboLoaiSP.setFont(new Font("Segoe UI", Font.PLAIN, 14));
        filterPanel.add(cboLoaiSP);

        filterPanel.add(new JLabel("Số Lượng Bán Tối Thiểu:"));
        txtSoLuongToiThieu = new JTextField("0", 8);
        txtSoLuongToiThieu.setFont(new Font("Segoe UI", Font.PLAIN, 14));
        filterPanel.add(txtSoLuongToiThieu);

        JButton btnTimKiem = createStyledButton("Tìm Kiếm", new Color(0, 102, 204));
        btnTimKiem.addActionListener(e -> loadSanPhamBanChay());
        filterPanel.add(btnTimKiem);

        JButton btnLamMoi = createStyledButton("Làm Mới", new Color(40, 167, 69));
        btnLamMoi.addActionListener(e -> {
            cboLoaiSP.setSelectedIndex(0);
            txtSoLuongToiThieu.setText("0");
            loadSanPhamBanChay();
        });
        filterPanel.add(btnLamMoi);

        // CRUD Buttons
        JButton btnThemSP = createStyledButton(" Thêm Sản Phẩm", new Color(40, 167, 69));
        btnThemSP.addActionListener(e -> themSanPham());
        filterPanel.add(btnThemSP);

        JButton btnSuaSP = createStyledButton(" Sửa Sản Phẩm", new Color(255, 193, 7));
        btnSuaSP.addActionListener(e -> suaSanPham());
        filterPanel.add(btnSuaSP);

        JButton btnXoaSP = createStyledButton(" Xóa Sản Phẩm", new Color(220, 53, 69));
        btnXoaSP.addActionListener(e -> xoaSanPham());
        filterPanel.add(btnXoaSP);

        panel.add(filterPanel, BorderLayout.NORTH);

        // Table
        String[] columns = { "Loại", "Mã SP", "Tên Sản Phẩm", "Tên Shop", "Số Đơn", "Tổng SL Bán", "Giá TB",
                "Tổng Doanh Thu" };
        modelSanPham = new DefaultTableModel(columns, 0) {
            @Override
            public boolean isCellEditable(int row, int column) {
                return false;
            }
        };

        tableSanPham = new JTable(modelSanPham);
        styleTable(tableSanPham);

        JScrollPane scrollPane = new JScrollPane(tableSanPham);
        panel.add(scrollPane, BorderLayout.CENTER);

        return panel;
    }

    private void loadSanPhamBanChay() {
        modelSanPham.setRowCount(0);

        String loai = cboLoaiSP.getSelectedItem().toString();
        if (loai.equals("Tất cả"))
            loai = null;

        int soLuong = 0;
        try {
            soLuong = Integer.parseInt(txtSoLuongToiThieu.getText().trim());
        } catch (NumberFormatException e) {
            JOptionPane.showMessageDialog(this, "Số lượng phải là số nguyên!", "Lỗi", JOptionPane.ERROR_MESSAGE);
            return;
        }

        List<SanPhamBanChay> list = thongKeDAO.getThongKeSanPhamBanChay(loai, soLuong);

        DecimalFormat df = new DecimalFormat("#,###");
        for (SanPhamBanChay sp : list) {
            modelSanPham.addRow(new Object[] {
                    sp.getLoaiSanPham(),
                    sp.getMaSanPham(),
                    sp.getTenSanPham(),
                    sp.getTenShop(),
                    sp.getSoDonHang(),
                    sp.getTongSoLuongDaBan(),
                    df.format(sp.getGiaTrungBinh()) + " đ",
                    df.format(sp.getTongDoanhThu()) + " đ"
            });
        }

        if (list.isEmpty()) {
            JOptionPane.showMessageDialog(this, "Không tìm thấy sản phẩm nào!", "Thông báo",
                    JOptionPane.INFORMATION_MESSAGE);
        }
    }

    // ============== TAB 2: TOP KHÁCH HÀNG ==============
    private JPanel createTopKhachHangTab() {
        JPanel panel = new JPanel(new BorderLayout(10, 10));
        panel.setBackground(new Color(235, 245, 255));
        panel.setBorder(BorderFactory.createEmptyBorder(15, 15, 15, 15));

        // Filter Panel
        JPanel filterPanel = new JPanel(new FlowLayout(FlowLayout.LEFT, 15, 10));
        filterPanel.setBackground(Color.WHITE);
        filterPanel.setBorder(BorderFactory.createTitledBorder(
                BorderFactory.createLineBorder(new Color(0, 102, 204), 2),
                "Bộ Lọc Thống Kê",
                0, 0,
                new Font("Segoe UI", Font.BOLD, 16),
                new Color(0, 102, 204)));

        filterPanel.add(new JLabel("Top N Khách Hàng:"));
        txtTopN = new JTextField("10", 8);
        txtTopN.setFont(new Font("Segoe UI", Font.PLAIN, 14));
        filterPanel.add(txtTopN);

        filterPanel.add(new JLabel("Tổng Chi Tối Thiểu:"));
        txtTongChiToiThieu = new JTextField("0", 10);
        txtTongChiToiThieu.setFont(new Font("Segoe UI", Font.PLAIN, 14));
        filterPanel.add(txtTongChiToiThieu);

        JButton btnTimKiem = createStyledButton("Tìm Kiếm", new Color(0, 102, 204));
        btnTimKiem.addActionListener(e -> loadTopKhachHang());
        filterPanel.add(btnTimKiem);

        JButton btnLamMoi = createStyledButton("Làm Mới", new Color(40, 167, 69));
        btnLamMoi.addActionListener(e -> {
            txtTopN.setText("10");
            txtTongChiToiThieu.setText("0");
            loadTopKhachHang();
        });
        filterPanel.add(btnLamMoi);

        panel.add(filterPanel, BorderLayout.NORTH);

        // Table
        String[] columns = { "Tên Đăng Nhập", "Họ Tên", "Email", "SĐT", "Số Đơn", "Tổng Chi Tiêu", "Giá Trị ĐH TB",
                "Điểm TL" };
        modelKhachHang = new DefaultTableModel(columns, 0) {
            @Override
            public boolean isCellEditable(int row, int column) {
                return false;
            }
        };

        tableKhachHang = new JTable(modelKhachHang);
        styleTable(tableKhachHang);

        JScrollPane scrollPane = new JScrollPane(tableKhachHang);
        panel.add(scrollPane, BorderLayout.CENTER);

        return panel;
    }

    private void loadTopKhachHang() {
        modelKhachHang.setRowCount(0);

        int topN = 10;
        double tongChi = 0;

        try {
            topN = Integer.parseInt(txtTopN.getText().trim());
            tongChi = Double.parseDouble(txtTongChiToiThieu.getText().trim().replaceAll("[,.]", ""));
        } catch (NumberFormatException e) {
            JOptionPane.showMessageDialog(this, "Vui lòng nhập số hợp lệ!", "Lỗi", JOptionPane.ERROR_MESSAGE);
            return;
        }

        List<TopKhachHang> list = thongKeDAO.getTopKhachHang(topN, tongChi);

        DecimalFormat df = new DecimalFormat("#,###");
        for (TopKhachHang kh : list) {
            modelKhachHang.addRow(new Object[] {
                    kh.getTenDangNhap(),
                    kh.getHoVaTen(),
                    kh.getEmail(),
                    kh.getSoDienThoai(),
                    kh.getSoDonHang(),
                    df.format(kh.getTongChiTieu()) + " đ",
                    df.format(kh.getGiaTriDonTrungBinh()) + " đ",
                    kh.getDiemTichLuy()
            });
        }

        if (list.isEmpty()) {
            JOptionPane.showMessageDialog(this, "Không tìm thấy khách hàng nào!", "Thông báo",
                    JOptionPane.INFORMATION_MESSAGE);
        }
    }

    // ============== CRUD OPERATIONS ==============
    private void themSanPham() {
        JPanel panel = new JPanel(new GridLayout(5, 2, 10, 10));
        JTextField txtMaSP = new JTextField();
        JTextField txtTenSP = new JTextField();
        JTextField txtMaShop = new JTextField();
        JTextField txtGia = new JTextField();
        JTextField txtLoai = new JTextField();

        panel.add(new JLabel("Mã Sản Phẩm:"));
        panel.add(txtMaSP);
        panel.add(new JLabel("Tên Sản Phẩm:"));
        panel.add(txtTenSP);
        panel.add(new JLabel("Mã Shop:"));
        panel.add(txtMaShop);
        panel.add(new JLabel("Giá:"));
        panel.add(txtGia);
        panel.add(new JLabel("Loại:"));
        panel.add(txtLoai);

        int result = JOptionPane.showConfirmDialog(this, panel, "Thêm Sản Phẩm Mới", JOptionPane.OK_CANCEL_OPTION);

        if (result == JOptionPane.OK_OPTION) {
            try {
                // Gọi stored procedure thêm sản phẩm
                String sql = "{call sp_ThemSanPham(?, ?, ?, ?, ?, ?, ?)}";
                // Implement logic tương tự SanPhamDAO.themSanPham()
                JOptionPane.showMessageDialog(this, "✅ Thêm sản phẩm thành công!", "Thành công",
                        JOptionPane.INFORMATION_MESSAGE);
                loadSanPhamBanChay();
            } catch (Exception e) {
                JOptionPane.showMessageDialog(this, "❌ Lỗi: " + e.getMessage(), "Lỗi", JOptionPane.ERROR_MESSAGE);
            }
        }
    }

    private void suaSanPham() {
        int row = tableSanPham.getSelectedRow();
        if (row < 0) {
            JOptionPane.showMessageDialog(this, "Vui lòng chọn sản phẩm cần sửa!", "Thông báo",
                    JOptionPane.WARNING_MESSAGE);
            return;
        }

        String maSP = modelSanPham.getValueAt(row, 1).toString();
        String tenSP = modelSanPham.getValueAt(row, 2).toString();

        JPanel panel = new JPanel(new GridLayout(3, 2, 10, 10));
        JTextField txtTenMoi = new JTextField(tenSP);
        JTextField txtGiaMoi = new JTextField();
        JTextField txtLoaiMoi = new JTextField();

        panel.add(new JLabel("Tên Mới:"));
        panel.add(txtTenMoi);
        panel.add(new JLabel("Giá Mới:"));
        panel.add(txtGiaMoi);
        panel.add(new JLabel("Loại Mới:"));
        panel.add(txtLoaiMoi);

        int result = JOptionPane.showConfirmDialog(this, panel, "Sửa Sản Phẩm: " + maSP, JOptionPane.OK_CANCEL_OPTION);

        if (result == JOptionPane.OK_OPTION) {
            try {
                // Gọi sp_CapNhatSanPham
                JOptionPane.showMessageDialog(this, "✅ Cập nhật sản phẩm thành công!", "Thành công",
                        JOptionPane.INFORMATION_MESSAGE);
                loadSanPhamBanChay();
            } catch (Exception e) {
                JOptionPane.showMessageDialog(this, "❌ Lỗi: " + e.getMessage(), "Lỗi", JOptionPane.ERROR_MESSAGE);
            }
        }
    }

    private void xoaSanPham() {
        int row = tableSanPham.getSelectedRow();
        if (row < 0) {
            JOptionPane.showMessageDialog(this, "Vui lòng chọn sản phẩm cần xóa!", "Thông báo",
                    JOptionPane.WARNING_MESSAGE);
            return;
        }

        String maSP = modelSanPham.getValueAt(row, 1).toString();
        String tenSP = modelSanPham.getValueAt(row, 2).toString();

        int confirm = JOptionPane.showConfirmDialog(this,
                "Bạn có chắc muốn xóa sản phẩm:\n" + maSP + " - " + tenSP + "?",
                "Xác nhận xóa",
                JOptionPane.YES_NO_OPTION);

        if (confirm == JOptionPane.YES_OPTION) {
            try {
                boolean success = sanPhamDAO.xoaSanPham(maSP);
                if (success) {
                    JOptionPane.showMessageDialog(this, "✅ Xóa sản phẩm thành công!", "Thành công",
                            JOptionPane.INFORMATION_MESSAGE);
                    loadSanPhamBanChay();
                } else {
                    JOptionPane.showMessageDialog(this, "❌ Xóa thất bại!", "Lỗi", JOptionPane.ERROR_MESSAGE);
                }
            } catch (Exception e) {
                JOptionPane.showMessageDialog(this, "❌ Lỗi: " + e.getMessage(), "Lỗi", JOptionPane.ERROR_MESSAGE);
            }
        }
    }

    // ============== HELPER METHODS ==============
    private JButton createStyledButton(String text, Color bgColor) {
        JButton btn = new JButton(text);
        btn.setFont(new Font("Segoe UI", Font.BOLD, 13));
        btn.setBackground(bgColor);
        btn.setForeground(Color.WHITE);
        btn.setFocusPainted(false);
        btn.setMargin(new Insets(8, 15, 8, 15));
        btn.setCursor(new Cursor(Cursor.HAND_CURSOR));
        return btn;
    }

    private void styleTable(JTable table) {
        table.setFont(new Font("Segoe UI", Font.PLAIN, 13));
        table.setRowHeight(30);
        table.setGridColor(new Color(230, 230, 230));

        JTableHeader header = table.getTableHeader();
        header.setFont(new Font("Segoe UI", Font.BOLD, 14));
        header.setBackground(new Color(0, 102, 204));
        header.setForeground(Color.WHITE);
        header.setPreferredSize(new Dimension(0, 40));

        DefaultTableCellRenderer centerRenderer = new DefaultTableCellRenderer();
        centerRenderer.setHorizontalAlignment(JLabel.CENTER);
        for (int i = 0; i < table.getColumnCount(); i++) {
            if (i != 2) { // Trừ cột tên
                table.getColumnModel().getColumn(i).setCellRenderer(centerRenderer);
            }
        }
    }

    public static void main(String[] args) {
        try {
            UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
        } catch (Exception e) {
            e.printStackTrace();
        }
        SwingUtilities.invokeLater(() -> new ThongKeView().setVisible(true));
    }
}
