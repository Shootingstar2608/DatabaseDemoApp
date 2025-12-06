package org.example.view;

import org.example.dao.SanPhamDAO;
import org.example.model.SanPham;

import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import javax.swing.table.JTableHeader;
import javax.swing.table.TableRowSorter;
import java.awt.*;
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

        // ========== PANEL NHẬP LIỆU (BÊN TRÁI) ==========
        JPanel inputPanel = createInputPanel();

        // ========== PANEL BẢNG DỮ LIỆU (BÊN PHẢI) ==========
        JPanel tablePanel = createTablePanel();

        // ========== PANEL CHỨC NĂNG (DƯỚI CÙNG) ==========
        JPanel buttonPanel = createButtonPanel();

        // Thêm vào frame
        add(inputPanel, BorderLayout.WEST);
        add(tablePanel, BorderLayout.CENTER);
        add(buttonPanel, BorderLayout.SOUTH);
    }

    private JPanel createInputPanel() {
        JPanel panel = new JPanel(new GridBagLayout());
        panel.setBorder(BorderFactory.createTitledBorder("Thông Tin Sản Phẩm"));
        panel.setPreferredSize(new Dimension(400, 0));

        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(5, 5, 5, 5);
        gbc.fill = GridBagConstraints.HORIZONTAL;

        // Khởi tạo các field
        txtMaSanPham = new JTextField(20);
        txtMaSoShop = new JTextField(20);
        txtTenSanPham = new JTextField(20);
        txtThongTinSanPham = new JTextArea(4, 20);
        txtThongTinSanPham.setLineWrap(true);
        txtThongTinSanPham.setWrapStyleWord(true);
        JScrollPane scrollThongTin = new JScrollPane(txtThongTinSanPham);
        txtLinkSanPham = new JTextField(20);
        txtGiaHienThi = new JTextField(20);
        txtLoai = new JTextField(20);

        // Thêm các label và field
        int row = 0;

        addFormField(panel, gbc, "Mã Sản Phẩm:", txtMaSanPham, row++);
        addFormField(panel, gbc, "Mã Shop:", txtMaSoShop, row++);
        addFormField(panel, gbc, "Tên Sản Phẩm:", txtTenSanPham, row++);

        // Thông tin sản phẩm (TextArea)
        gbc.gridx = 0;
        gbc.gridy = row;
        gbc.anchor = GridBagConstraints.NORTHEAST;
        panel.add(new JLabel("Thông Tin SP:"), gbc);

        gbc.gridx = 1;
        gbc.gridy = row++;
        gbc.anchor = GridBagConstraints.WEST;
        panel.add(scrollThongTin, gbc);

        addFormField(panel, gbc, "Link Sản Phẩm:", txtLinkSanPham, row++);
        addFormField(panel, gbc, "Giá Hiển Thị:", txtGiaHienThi, row++);
        addFormField(panel, gbc, "Loại:", txtLoai, row++);

        return panel;
    }

    private void addFormField(JPanel panel, GridBagConstraints gbc, String label, JTextField field, int row) {
        gbc.gridx = 0;
        gbc.gridy = row;
        gbc.anchor = GridBagConstraints.EAST;
        panel.add(new JLabel(label), gbc);

        gbc.gridx = 1;
        gbc.gridy = row;
        gbc.anchor = GridBagConstraints.WEST;
        panel.add(field, gbc);
    }

    private JPanel createTablePanel() {
        JPanel panel = new JPanel(new BorderLayout());
        panel.setBorder(BorderFactory.createTitledBorder("Danh Sách Sản Phẩm"));

        // Tạo bảng
        String[] columns = { "Mã SP", "Tên Sản Phẩm", "Giá", "Loại", "Mã Shop" };
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

        // Bật auto-create row sorter (hiển thị mũi tên sort tự động)
        table.setAutoCreateRowSorter(true);

        // Style bảng
        table.setFont(new Font("Segoe UI", Font.PLAIN, 14));
        table.setRowHeight(28);

        JTableHeader header = table.getTableHeader();
        header.setFont(new Font("Segoe UI", Font.BOLD, 14));
        header.setBackground(new Color(220, 220, 220));
        header.setReorderingAllowed(false); // Không cho kéo thả cột

        // Force hiển thị icon sort (FlatLaf đôi khi ẩn nó)
        UIManager.put("Table.sortIconHighlight", Color.BLACK);
        UIManager.put("Table.sortIconColor", Color.DARK_GRAY);
        header.repaint();

        // Khi click vào 1 dòng → hiển thị thông tin lên form
        table.getSelectionModel().addListSelectionListener(e -> {
            if (!e.getValueIsAdjusting() && table.getSelectedRow() != -1) {
                hienThiThongTinSanPham();
            }
        });

        JScrollPane scrollPane = new JScrollPane(table);
        panel.add(scrollPane, BorderLayout.CENTER);

        return panel;
    }

    private JPanel createButtonPanel() {
        JPanel panel = new JPanel(new FlowLayout(FlowLayout.CENTER, 20, 10));

        btnThem = new JButton("➕ Thêm");
        btnSua = new JButton("✏️ Sửa");
        btnXoa = new JButton("🗑️ Xóa");
        btnLamMoi = new JButton("🔄 Làm Mới");
        JButton btnQuayLai = new JButton("⬅️ Quay Lại Menu");

        // Style buttons
        styleButton(btnThem, new Color(46, 204, 113));
        styleButton(btnSua, new Color(52, 152, 219));
        styleButton(btnXoa, new Color(231, 76, 60));
        styleButton(btnLamMoi, new Color(149, 165, 166));
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

        return panel;
    }

    private void styleButton(JButton button, Color color) {
        button.setPreferredSize(new Dimension(120, 40));
        button.setBackground(color);
        button.setForeground(Color.WHITE);
        button.setFocusPainted(false);
        button.setFont(new Font("Arial", Font.BOLD, 14));
        button.setBorder(BorderFactory.createEmptyBorder(5, 15, 5, 15));
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
        SwingUtilities.invokeLater(() -> {
            QuanLySanPhamCRUD frame = new QuanLySanPhamCRUD();
            frame.setVisible(true);
        });
    }
}
