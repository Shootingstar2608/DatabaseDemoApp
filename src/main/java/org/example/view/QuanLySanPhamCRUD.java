package org.example.view;

import org.example.dao.SanPhamDAO;
import org.example.model.SanPham;
import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import javax.swing.table.JTableHeader;
import javax.swing.table.DefaultTableCellRenderer;
import java.awt.*;
import java.text.DecimalFormat;
import java.util.List;

public class QuanLySanPhamCRUD extends JFrame {
    private JTable table;
    private DefaultTableModel tableModel;
    private SanPhamDAO sanPhamDAO;

    // Các trường nhập liệu đầy đủ
    private JTextField txtMaSanPham, txtMaSoShop, txtTenSanPham, txtLinkSanPham, txtGiaHienThi, txtLoai;
    private JTextArea txtThongTinSanPham;

    // Các nút chức năng
    private JButton btnThem, btnSua, btnXoa, btnLamMoi;

    // Callback để quay lại menu
    private Runnable onBackToMenu;

    public QuanLySanPhamCRUD() {
        sanPhamDAO = new SanPhamDAO();
        initializeUI();
        loadAllProducts();
    }

    public void setOnBackToMenu(Runnable callback) {
        this.onBackToMenu = callback;
    }

    private void initializeUI() {
        setTitle("Quản Lý Sản Phẩm - CRUD");
        setSize(1200, 700);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null);
        setLayout(new BorderLayout(10, 10));

        // --- [THÊM] ĐỊNH NGHĨA MÀU NỀN ---
        Color mainColor = new Color(235, 245, 255); // Màu xanh nhạt rất dịu
        getContentPane().setBackground(mainColor); // Set màu cho nền cửa sổ chính
        // ---------------------------------

        // ========== PANEL NHẬP LIỆU (BÊN TRÁI) ==========
        JPanel inputPanel = createInputPanel(mainColor); // [SỬA] Truyền màu vào

        // ========== PANEL BẢNG DỮ LIỆU (BÊN PHẢI) ==========
        JPanel tablePanel = createTablePanel(mainColor); // [SỬA] Truyền màu vào

        // ========== PANEL CHỨC NĂNG (DƯỚI CÙNG) ==========
        JPanel buttonPanel = createButtonPanel(mainColor); // [SỬA] Truyền màu vào

        // Thêm vào frame
        add(inputPanel, BorderLayout.WEST);
        add(tablePanel, BorderLayout.CENTER);
        add(buttonPanel, BorderLayout.SOUTH);
    }

    private JPanel createInputPanel(Color color) {
        JPanel panel = new JPanel(new GridBagLayout());
        // 1. Tạo Border
        javax.swing.border.TitledBorder border = BorderFactory.createTitledBorder("Thông Tin Sản Phẩm");

        // 2. Cấu hình Font: Font Segoe UI, In Đậm (BOLD), Cỡ 23
        border.setTitleFont(new Font("Segoe UI", Font.BOLD, 30));

        // (Tùy chọn) Thêm màu cho tiêu đề nếu muốn nổi hơn
        border.setTitleColor(new Color(0, 51, 102));
        border.setTitleJustification(javax.swing.border.TitledBorder.CENTER);
        // 3. Gán Border đã chỉnh sửa vào Panel
        panel.setBorder(border);

        // Giữ độ rộng panel để giao diện cân đối
        panel.setPreferredSize(new Dimension(500, 0));

        panel.setBackground(color);

        GridBagConstraints gbc = new GridBagConstraints();
        // Insets mặc định (sẽ được ghi đè trong addFormField)
        gbc.insets = new Insets(8, 5, 8, 5);
        gbc.fill = GridBagConstraints.HORIZONTAL;

        // --- KHỞI TẠO CÁC FIELD ---
        txtMaSanPham = new JTextField(20);
        txtMaSoShop = new JTextField(20);
        txtTenSanPham = new JTextField(20);

        // Cấu hình TextArea
        txtThongTinSanPham = new JTextArea(4, 20);
        txtThongTinSanPham.setLineWrap(true);
        txtThongTinSanPham.setWrapStyleWord(true);
        txtThongTinSanPham.setMargin(new Insets(8, 0, 8, 5));
        txtThongTinSanPham.setFont(new Font("Segoe UI", Font.PLAIN, 14));

        JScrollPane scrollThongTin = new JScrollPane(txtThongTinSanPham);
        scrollThongTin.setPreferredSize(new Dimension(0, 100));
        scrollThongTin.putClientProperty("FlatLaf.style", "arc: 20; borderColor: #cccccc");

        txtLinkSanPham = new JTextField(20);
        txtGiaHienThi = new JTextField(20);
        txtLoai = new JTextField(20);

        // --- THÊM CÁC THÀNH PHẦN VÀO PANEL ---
        int row = 0;

        addFormField(panel, gbc, "Mã Sản Phẩm:", txtMaSanPham, row++);
        addFormField(panel, gbc, "Mã Shop:", txtMaSoShop, row++);
        addFormField(panel, gbc, "Tên Sản Phẩm:", txtTenSanPham, row++);

        // --- XỬ LÝ RIÊNG CHO TEXT AREA (THÔNG TIN SP) ---
        // 1. Label "Thông Tin SP"
        gbc.gridx = 0;
        gbc.gridy = row;
        gbc.weightx = 0;
        gbc.fill = GridBagConstraints.NONE;
        gbc.anchor = GridBagConstraints.NORTHEAST; // Căn góc trên bên phải
        // Insets: Trên 10, Trái 10, Dưới 5, Phải 15 (Để khớp với hàm addFormField bên
        // dưới)
        gbc.insets = new Insets(8, 10, 8, 15);

        JLabel lblThongTin = new JLabel("Thông Tin Sản Phẩm:");
        lblThongTin.setFont(new Font("Segoe UI", Font.BOLD, 16));
        panel.add(lblThongTin, gbc);

        // 2. ScrollPane chứa TextArea
        gbc.gridx = 1;
        gbc.gridy = row++;
        gbc.weightx = 1.0;
        gbc.fill = GridBagConstraints.HORIZONTAL;
        gbc.anchor = GridBagConstraints.WEST;
        // Insets: Trái = 0 (vì Label đã đẩy ra 15 rồi), Phải = 10
        gbc.insets = new Insets(8, 10, 8, 15);
        panel.add(scrollThongTin, gbc);
        // ----------------------------------------------------

        addFormField(panel, gbc, "Link Sản Phẩm:", txtLinkSanPham, row++);
        addFormField(panel, gbc, "Giá Hiển Thị:", txtGiaHienThi, row++);
        addFormField(panel, gbc, "Loại:", txtLoai, row++);

        return panel;
    }

    private void addFormField(JPanel panel, GridBagConstraints gbc, String label, JTextField field, int row) {
        // --- CẤU HÌNH CHO LABEL (GIỮ NGUYÊN) ---
        gbc.gridx = 0;
        gbc.gridy = row;
        gbc.weightx = 0;
        gbc.fill = GridBagConstraints.NONE;
        gbc.anchor = GridBagConstraints.EAST;

        // Khoảng cách giữa Label và TextField là 15px
        gbc.insets = new Insets(8, 10, 8, 15);

        JLabel lbl = new JLabel(label);
        lbl.setFont(new Font("Segoe UI", Font.BOLD, 16));
        panel.add(lbl, gbc);

        // --- CẤU HÌNH CHO TEXTFIELD ---
        gbc.gridx = 1;
        gbc.gridy = row;
        gbc.weightx = 1.0;
        gbc.fill = GridBagConstraints.HORIZONTAL;
        gbc.anchor = GridBagConstraints.WEST;
        gbc.insets = new Insets(0, 10, 0, 10);

        field.setFont(new Font("Segoe UI", Font.PLAIN, 14));
        field.setPreferredSize(new Dimension(0, 40));

        // === [THÊM DÒNG NÀY] ===
        // Đẩy chữ bên trong thụt vào 10px để thẳng hàng với ô Thông tin SP
        // Insets(Top, Left, Bottom, Right) -> Left = 10
        field.setMargin(new Insets(0, 10, 0, 10));
        // =======================

        panel.add(field, gbc);
    }

    private JPanel createTablePanel(Color color) {
        JPanel panel = new JPanel(new BorderLayout());
        // 1. Tạo border và lưu vào biến
        javax.swing.border.TitledBorder border = BorderFactory.createTitledBorder("Danh Sách Sản Phẩm");

        // 2. Cấu hình Font: Font Segoe UI, In Đậm (BOLD), Cỡ 24 (bạn có thể tăng lên 30
        // nếu muốn to hơn)
        border.setTitleFont(new Font("Segoe UI", Font.BOLD, 30));

        // 3. (Tùy chọn) Chỉnh màu xanh đậm cho đồng bộ với giao diện của bạn
        border.setTitleColor(new Color(0, 51, 102));
        // 4. 👇 DÒNG QUAN TRỌNG: CĂN GIỮA TIÊU ĐỀ
        border.setTitleJustification(javax.swing.border.TitledBorder.CENTER);

        // 5. Gán border đã chỉnh sửa vào panel
        panel.setBorder(border);

        panel.setBackground(color);

        // Tạo bảng
        String[] columns = { "Mã SP", "Tên Sản Phẩm", "Giá", "Loại", "Link Sản Phẩm", "Mã Shop" };
        tableModel = new DefaultTableModel(columns, 0) {
            @Override
            public boolean isCellEditable(int row, int column) {
                return false; // Không cho edit trực tiếp trên bảng
            }

            @Override
            public Class<?> getColumnClass(int columnIndex) {
                if (columnIndex == 2)
                    return Double.class; // Cột Giá là số để sort đúng
                return String.class;
            }
        };

        table = new JTable(tableModel);
        table.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);

        // Bật auto-create row sorter
        table.setAutoCreateRowSorter(true);

        // ================== BẮT ĐẦU STYLE GIỐNG QUANLYSANPHAMVIEW ==================

        // 1. Cấu hình Font và chiều cao dòng
        table.setFont(new Font("Segoe UI", Font.PLAIN, 14));
        table.setRowHeight(28);

        // 2. Lấy header ra để chỉnh sửa
        JTableHeader header = table.getTableHeader();
        header.setReorderingAllowed(false); // Cố định cột, không cho kéo thả
        header.setPreferredSize(new Dimension(header.getWidth(), 40)); // Header cao hơn (40px)

        // 3. Tạo bộ Renderer (Bộ vẽ giao diện) cho Header giống nút bấm 3D
        DefaultTableCellRenderer customHeaderRenderer = new DefaultTableCellRenderer() {
            @Override
            public Component getTableCellRendererComponent(JTable table, Object value, boolean isSelected,
                    boolean hasFocus, int row, int column) {
                JLabel label = (JLabel) super.getTableCellRendererComponent(table, value, isSelected, hasFocus, row,
                        column);

                // Trang trí giống nút bấm
                label.setFont(new Font("Segoe UI", Font.BOLD, 18));
                label.setBackground(new Color(230, 240, 255)); // Nền xanh nhạt
                label.setForeground(new Color(0, 51, 102)); // Chữ xanh đậm
                label.setHorizontalAlignment(JLabel.CENTER);

                // Tạo viền nổi (RAISED) - Hiệu ứng 3D
                label.setBorder(BorderFactory.createCompoundBorder(
                        BorderFactory.createMatteBorder(0, 0, 1, 1, Color.GRAY),
                        BorderFactory.createBevelBorder(javax.swing.border.BevelBorder.RAISED)));

                // Xử lý Icon mũi tên dựa trên trạng thái Sort
                String text = value.toString();
                String icon = "";

                RowSorter<?> sorter = table.getRowSorter();
                if (sorter != null) {
                    List<? extends RowSorter.SortKey> keys = sorter.getSortKeys();
                    if (!keys.isEmpty() && keys.get(0).getColumn() == column) {
                        SortOrder order = keys.get(0).getSortOrder();
                        if (order == SortOrder.ASCENDING) {
                            icon = " ▲";
                            label.setForeground(new Color(0, 150, 0));
                            label.setBackground(new Color(220, 255, 220));
                        } else if (order == SortOrder.DESCENDING) {
                            icon = " ▼";
                            label.setForeground(new Color(200, 0, 0));
                            label.setBackground(new Color(255, 220, 220));
                        }
                    }
                }
                label.setText(text + icon);
                return label;
            }
        };

        // Áp dụng Header Renderer cho tất cả các cột
        for (int i = 0; i < table.getColumnCount(); i++) {
            table.getColumnModel().getColumn(i).setHeaderRenderer(customHeaderRenderer);
        }

        // 4. Căn giữa dữ liệu cho cột Mã SP (0) và Mã Shop (5)
        DefaultTableCellRenderer centerRenderer = new DefaultTableCellRenderer();
        centerRenderer.setHorizontalAlignment(JLabel.CENTER);
        table.getColumnModel().getColumn(0).setCellRenderer(centerRenderer); // Mã SP
        table.getColumnModel().getColumn(5).setCellRenderer(centerRenderer); // Mã Shop

        // 5. Format cột Giá (2) hiển thị dấu phẩy ngăn cách (1,000,000)
        table.getColumnModel().getColumn(2).setCellRenderer(new DefaultTableCellRenderer() {
            DecimalFormat formatter = new DecimalFormat("#,###");

            @Override
            public Component getTableCellRendererComponent(JTable table, Object value, boolean isSelected,
                    boolean hasFocus, int row, int column) {
                if (value instanceof Number) {
                    value = formatter.format(value);
                }
                setHorizontalAlignment(JLabel.CENTER); // Căn giữa giá tiền
                return super.getTableCellRendererComponent(table, value, isSelected, hasFocus, row, column);
            }
        });

        // 6. Chỉnh độ rộng cột
        table.getColumnModel().getColumn(0).setPreferredWidth(120); // Mã SP rộng hơn
        table.getColumnModel().getColumn(1).setPreferredWidth(250); // Tên SP rộng hơn
        table.getColumnModel().getColumn(4).setPreferredWidth(180); // Link SP
        table.getColumnModel().getColumn(5).setPreferredWidth(100); // Mã shop nhỏ lại

        // ================== KẾT THÚC STYLE ==================

        // Khi click vào 1 dòng → hiển thị thông tin lên form
        table.getSelectionModel().addListSelectionListener(e -> {
            if (!e.getValueIsAdjusting() && table.getSelectedRow() != -1) {
                hienThiThongTinSanPham();
            }
        });

        JScrollPane scrollPane = new JScrollPane(table);
        // Thêm khoảng đệm cho bảng đẹp hơn
        scrollPane.setBorder(BorderFactory.createEmptyBorder(0, 5, 5, 5));
        panel.add(scrollPane, BorderLayout.CENTER);

        return panel;
    }

    private JPanel createButtonPanel(Color color) {
        JPanel panel = new JPanel(new FlowLayout(FlowLayout.CENTER, 20, 10));

        btnThem = new JButton("Thêm");
        btnSua = new JButton("Sửa");
        btnXoa = new JButton("Xóa");
        btnLamMoi = new JButton("Làm Mới");
        JButton btnQuayLai = new JButton("Quay Lại Menu");

        // Style buttons
        styleButton(btnThem, new Color(40, 167, 69));
        styleButton(btnSua, new Color(52, 152, 219));
        styleButton(btnXoa, new Color(220, 53, 69));
        styleButton(btnLamMoi, new Color(40, 165, 166));
        styleButton(btnQuayLai, new Color(52, 73, 94));

        // Add listeners
        btnThem.addActionListener(e -> themSanPham());
        btnSua.addActionListener(e -> suaSanPham());
        btnXoa.addActionListener(e -> xoaSanPham());
        btnLamMoi.addActionListener(e -> lamMoi());
        btnQuayLai.addActionListener(e -> {
            if (onBackToMenu != null) {
                dispose();
                onBackToMenu.run();
            }
        });

        panel.add(btnThem);
        panel.add(btnSua);
        panel.add(btnXoa);
        panel.add(btnLamMoi);
        panel.add(btnQuayLai);
        panel.setBackground(color);
        return panel;
    }

    private void styleButton(JButton button, Color color) {
        // 1. Xóa dòng setPreferredSize cũ để nút không bị ép size
        // button.setPreferredSize(new Dimension(width, 40));

        // 2. CHỈ ĐỊNH CHIỀU CAO CỐ ĐỊNH (40px), CHIỀU RỘNG TỰ DO
        // Dùng Dimension với chiều rộng là d.width (tự nhiên) và chiều cao 40
        Dimension d = button.getPreferredSize();
        button.setPreferredSize(new Dimension(d.width + 40, 40));
        // Mẹo: cộng thêm 40 vào chiều rộng để nút trông rộng rãi hơn, không bị sát chữ

        button.setBackground(color);
        button.setForeground(Color.WHITE);
        button.setFocusPainted(false);
        button.setFont(new Font("Segoe UI", Font.BOLD, 14));

        // 3. Set Margin (Khoảng cách đệm từ mép nút vào chữ)
        // Insets(Top, Left, Bottom, Right) -> Trái/Phải để 20px cho thoáng
        button.setMargin(new Insets(0, 20, 0, 20));

        // 4. Style bo tròn (Capsule) của FlatLaf
        button.putClientProperty("FlatLaf.style", "arc: 999; borderWidth: 0;");

        button.setCursor(new Cursor(Cursor.HAND_CURSOR));
    }

    private void loadAllProducts() {
        tableModel.setRowCount(0);
        List<SanPham> danhSach = sanPhamDAO.traCuuSanPham(null, null, null, null, null, null, null);

        for (SanPham sp : danhSach) {
            tableModel.addRow(new Object[] {
                    sp.getMaSanPham(),
                    sp.getTenSanPham(),
                    sp.getGiaHienThi(), // Giữ nguyên Double để sort đúng
                    sp.getLoai(),
                    sp.getLinkSanPham(),
                    sp.getMaSoShop()
            });
        }
    }

    private void hienThiThongTinSanPham() {
        int selectedRow = table.getSelectedRow();
        if (selectedRow == -1)
            return;

        // QUAN TRỌNG: Convert row index từ view (sau khi sort) sang model (dữ liệu gốc)
        int modelRow = table.convertRowIndexToModel(selectedRow);
        String maSP = (String) tableModel.getValueAt(modelRow, 0);

        // Lấy thông tin đầy đủ từ database
        List<SanPham> result = sanPhamDAO.traCuuSanPham(maSP, null, null, null, null, null, null);
        if (!result.isEmpty()) {
            SanPham sp = result.get(0);

            txtMaSanPham.setText(sp.getMaSanPham());
            txtMaSoShop.setText(sp.getMaSoShop());
            txtTenSanPham.setText(sp.getTenSanPham());
            txtThongTinSanPham.setText(sp.getThongTinSanPham());
            txtLinkSanPham.setText(sp.getLinkSanPham());
            txtGiaHienThi.setText(String.valueOf(sp.getGiaHienThi()));
            txtLoai.setText(sp.getLoai());
        }
    }

    private void themSanPham() {
        try {
            // Validate
            if (txtMaSanPham.getText().trim().isEmpty() ||
                    txtTenSanPham.getText().trim().isEmpty() ||
                    txtMaSoShop.getText().trim().isEmpty()) {
                JOptionPane.showMessageDialog(this,
                        "Vui lòng nhập đầy đủ: Mã SP, Tên SP, Mã Shop!",
                        "Thiếu thông tin",
                        JOptionPane.WARNING_MESSAGE);
                return;
            }

            String giaStr = txtGiaHienThi.getText().trim().replaceAll("[,.]", "");
            double gia = 0;
            if (!giaStr.isEmpty()) {
                gia = Double.parseDouble(giaStr);
            }

            SanPham sp = new SanPham();
            sp.setMaSanPham(txtMaSanPham.getText().trim());
            sp.setMaSoShop(txtMaSoShop.getText().trim());
            sp.setTenSanPham(txtTenSanPham.getText().trim());
            sp.setThongTinSanPham(txtThongTinSanPham.getText().trim());
            sp.setLinkSanPham(txtLinkSanPham.getText().trim());
            sp.setGiaHienThi(gia);
            sp.setLoai(txtLoai.getText().trim());

            boolean success = sanPhamDAO.themSanPham(sp);

            if (success) {
                JOptionPane.showMessageDialog(this, "✅ Thêm sản phẩm thành công!");
                loadAllProducts();
                lamMoi();
            } else {
                JOptionPane.showMessageDialog(this, "❌ Thêm thất bại!", "Lỗi", JOptionPane.ERROR_MESSAGE);
            }

        } catch (NumberFormatException ex) {
            JOptionPane.showMessageDialog(this, "Giá phải là số hợp lệ!", "Lỗi định dạng", JOptionPane.ERROR_MESSAGE);
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this, "Lỗi: " + ex.getMessage(), "Lỗi", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void suaSanPham() {
        try {
            if (table.getSelectedRow() == -1) {
                JOptionPane.showMessageDialog(this, "Vui lòng chọn sản phẩm cần sửa!", "Chưa chọn",
                        JOptionPane.WARNING_MESSAGE);
                return;
            }

            String maSP = txtMaSanPham.getText().trim();
            String giaStr = txtGiaHienThi.getText().trim().replaceAll("[,.]", "");
            double gia = Double.parseDouble(giaStr);

            boolean success = sanPhamDAO.capNhatSanPham(
                    maSP,
                    txtTenSanPham.getText().trim(),
                    txtThongTinSanPham.getText().trim(),
                    gia,
                    txtLoai.getText().trim());

            if (success) {
                JOptionPane.showMessageDialog(this, "✅ Cập nhật sản phẩm thành công!");
                loadAllProducts();
                lamMoi();
            } else {
                JOptionPane.showMessageDialog(this, "❌ Cập nhật thất bại!", "Lỗi", JOptionPane.ERROR_MESSAGE);
            }

        } catch (NumberFormatException ex) {
            JOptionPane.showMessageDialog(this, "Giá phải là số hợp lệ!", "Lỗi định dạng", JOptionPane.ERROR_MESSAGE);
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this, "Lỗi: " + ex.getMessage(), "Lỗi", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void xoaSanPham() {
        try {
            if (table.getSelectedRow() == -1) {
                JOptionPane.showMessageDialog(this, "Vui lòng chọn sản phẩm cần xóa!", "Chưa chọn",
                        JOptionPane.WARNING_MESSAGE);
                return;
            }

            String maSP = txtMaSanPham.getText().trim();

            int confirm = JOptionPane.showConfirmDialog(this,
                    "Bạn có chắc muốn xóa sản phẩm " + maSP + "?",
                    "Xác nhận xóa",
                    JOptionPane.YES_NO_OPTION);

            if (confirm == JOptionPane.YES_OPTION) {
                boolean success = sanPhamDAO.xoaSanPham(maSP);

                if (success) {
                    JOptionPane.showMessageDialog(this, "✅ Xóa sản phẩm thành công!");
                    loadAllProducts();
                    lamMoi();
                } else {
                    JOptionPane.showMessageDialog(this, "❌ Xóa thất bại!", "Lỗi", JOptionPane.ERROR_MESSAGE);
                }
            }

        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this, "Lỗi: " + ex.getMessage(), "Lỗi", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void lamMoi() {
        txtMaSanPham.setText("");
        txtMaSoShop.setText("");
        txtTenSanPham.setText("");
        txtThongTinSanPham.setText("");
        txtLinkSanPham.setText("");
        txtGiaHienThi.setText("");
        txtLoai.setText("");
        table.clearSelection();
    }

    public static void main(String[] args) {
        try {
            UIManager.setLookAndFeel(new com.formdev.flatlaf.FlatLightLaf());
            javax.swing.UIManager.put("TextField.font", new java.awt.Font("Segoe UI", java.awt.Font.PLAIN, 16));
            // Giao diện Tối (DARK MODE)
            // UIManager.setLookAndFeel(new com.formdev.flatlaf.FlatDarkLaf());
            // Tùy chỉnh thêm (tùy chọn): Làm tròn các nút bấm cho mềm mại
            UIManager.put("Button.arc", 100); // Nút bấm tròn hơn
            UIManager.put("Component.arc", 100); // Các thành phần khác (Border)
            UIManager.put("TextComponent.arc", 100); // Ô nhập liệu (TextField)
            // UIManager.put("ProgressBar.arc", 100); // Thanh tiến trình
        } catch (Exception e) {
            e.printStackTrace();
        }
        SwingUtilities.invokeLater(() -> {
            QuanLySanPhamCRUD frame = new QuanLySanPhamCRUD();
            frame.setVisible(true);
        });
    }
}
