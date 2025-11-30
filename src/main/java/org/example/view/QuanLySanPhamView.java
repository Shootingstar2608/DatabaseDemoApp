package org.example.view;
import org.example.dao.SanPhamDAO;
import org.example.model.SanPham;
import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import javax.swing.table.DefaultTableCellRenderer;
import javax.swing.table.TableRowSorter;
import java.awt.*;
import java.awt.event.ActionListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.List;
import java.text.Collator;
import java.util.Locale;
import java.util.Comparator;

public class QuanLySanPhamView extends JFrame {
    private JTable table; // Bảng hiển thị sản phẩm
    private DefaultTableModel tableModel; // Kho dữ liệu
    private TableRowSorter<DefaultTableModel> sorter; // Biến quản lý sắp xếp
    private SanPhamDAO sanPhamDAO; // Liên kết DAO
    // Các ô nhập liệu
    private JTextField txtMaSP, txtTenSP, txtLoai, txtMaShop, txtGia, txtGiaMin, txtGiaMax, txtTimKiem;
    private JButton btnLinkToFriend; // Nút chuyển giao diện CRUD
    public QuanLySanPhamView() {
        sanPhamDAO = new SanPhamDAO(); // Khởi tạo kết nối
        initUI(); // Gọi hàm vẽ
        loadData(); // Đổ dữ liệu vào
    }
    public static void main(String[] args) {
        try {
            UIManager.setLookAndFeel(new com.formdev.flatlaf.FlatLightLaf());
            // Giao diện Tối (DARK MODE)
            //UIManager.setLookAndFeel(new com.formdev.flatlaf.FlatDarkLaf());
            // Tùy chỉnh thêm (tùy chọn): Làm tròn các nút bấm cho mềm mại
            UIManager.put("Button.arc", 100); // Nút bấm tròn hơn
            UIManager.put("Component.arc", 100); // Các thành phần khác (Border)
            UIManager.put("TextComponent.arc", 100); // Ô nhập liệu (TextField)
            //UIManager.put("ProgressBar.arc", 100);  // Thanh tiến trình
        } catch (Exception e) {
            e.printStackTrace();
        }
        SwingUtilities.invokeLater(() -> new QuanLySanPhamView().setVisible(true));
        //Nó giúp ứng dụng chạy mượt mà và an toàn, không bị xung đột luồng, gọi khởi tạo và true để nó được bật trên màn hình khi mở
    }

    private void initUI() {
        setTitle("Giao Diện Tìm Kiếm Sản Phẩm"); // Đặt tên cửa sổ
        setSize(1800, 1000); // Nới rộng xíu cho nút sort
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE); // Bấm X là tắt app luôn
        setLocationRelativeTo(null); // Hiện cửa sổ ở giữa màn hình/ nếu không null thì nó sẽ hiện trong giao diện mẹ
        setLayout(new BorderLayout()); // Sử dụng layout chính là BorderLayout

        // ================= PHẦN 1: HEADER + TÌM KIẾM =================
        JPanel mainTopPanel = new JPanel();
        mainTopPanel.setLayout(new BoxLayout(mainTopPanel, BoxLayout.Y_AXIS)); // Sắp xếp các phần tử con theo chiều DỌC (từ trên xuống dưới)
        mainTopPanel.setBackground(new Color(230, 240, 255)); // Tô màu nền xanh dương nhạt
        mainTopPanel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));// Tạo khoảng đệm (padding) 10px ở 4 phía để nội dung không bị dính sát mép

        // --- Header ---
        JPanel headerPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));// Sắp xếp nội dung bên trong theo dòng ngang, canh lề TRÁI (LEFT)
        headerPanel.setOpaque(false);// Làm cho panel này trong suốt (để nhìn xuyên qua thấy màu nền xanh của mainTopPanel)

        JLabel lblTitle = new JLabel("  DANH SÁCH SẢN PHẨM");
        lblTitle.setFont(new Font("Arial", Font.BOLD, 24));
        lblTitle.setForeground(new Color(0, 51, 102));// Chỉnh màu chữ: Xanh đậm (để nổi bật trên nền xanh nhạt)
        headerPanel.add(lblTitle);// 1. Bỏ chữ vào dòng tiêu đề
        mainTopPanel.add(headerPanel);// 2. Bỏ dòng tiêu đề vào khung chứa chính
        mainTopPanel.add(Box.createRigidArea(new Dimension(0, 10)));// 3. Tạo một khoảng trống vô hình cao 10px ở dưới tiêu đề
        // (Để tí nữa thêm thanh tìm kiếm vào nó không bị dính sát lên tiêu đề)

        // --- Tìm kiếm nhanh ---
        JPanel searchPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        searchPanel.setOpaque(false); // Làm cho panel này trong suốt (để nhìn xuyên qua thấy màu nền xanh của mainTopPanel)
        searchPanel.add(createStyledLabel("Tìm kiếm: ")); // Gọi hàm mới
        txtTimKiem = new JTextField();
        txtTimKiem.setPreferredSize(new Dimension(1350, 25)); // Rộng 600px, Cao 30px

        txtTimKiem.setFont(new Font("Arial", Font.PLAIN, 15));
        JButton btnTimKiem = new JButton("Tìm Kiếm");
        btnTimKiem.setBackground(new Color(0, 102, 204));
        btnTimKiem.setForeground(Color.WHITE);
        searchPanel.add(txtTimKiem); // Bỏ ô nhập vào bảng
        searchPanel.add(btnTimKiem); // Bỏ nút bấm vào bảng (nằm ngay sau ô nhập)
        mainTopPanel.add(searchPanel); // Bỏ nguyên cái bảng tìm kiếm này vào giao diện chính

        // --- Chi tiết & Lọc (CÓ NÚT SORT) ---
        JPanel detailPanel = new JPanel(new GridLayout(0, 4, 10, 5));
        detailPanel.setBorder(BorderFactory.createTitledBorder("Thông tin chi tiết & Lọc sản phẩm "));
        detailPanel.setBackground(Color.WHITE);

        txtMaSP = new JTextField(); txtTenSP = new JTextField();
        txtLoai = new JTextField(); txtMaShop = new JTextField();
        txtGia = new JTextField(); txtGia.setEditable(false); txtGia.setBackground(new Color(245, 245, 245)); // màu xám nhẹ cho ô giá (không cho sửa)
        txtGiaMin = new JTextField(); txtGiaMax = new JTextField();

        // Sử dụng hàm createSortablePanel để tạo ô nhập có kèm nút mũi tên
        // Tham số thứ 2 là index của cột trong bảng (0: Mã, 1: Tên, 2: Giá, 3: Loại, 4: Shop)
        
        detailPanel.add(createStyledLabel("Mã Sản Phẩm:")); // Gọi hàm mới
        detailPanel.add(createSortablePanel(txtMaSP, 0));

        detailPanel.add(createStyledLabel("Tên Sản Phẩm:"));
        detailPanel.add(createSortablePanel(txtTenSP, 1));

        detailPanel.add(createStyledLabel("Loại Hàng:"));
        detailPanel.add(createSortablePanel(txtLoai, 3));

        detailPanel.add(createStyledLabel("Tên Cửa Hàng:"));
        detailPanel.add(createSortablePanel(txtMaShop, 4));

        detailPanel.add(createStyledLabel("Giá Thấp Nhất:"));
        detailPanel.add(txtGiaMin);

        detailPanel.add(createStyledLabel("Giá Cao Nhất:"));
        detailPanel.add(txtGiaMax);

        detailPanel.add(createStyledLabel("Giá Sản Phẩm (VNĐ):"));
        detailPanel.add(createSortablePanel(txtGia, 2));

        mainTopPanel.add(Box.createRigidArea(new Dimension(0, 5)));
        mainTopPanel.add(detailPanel);
        
        JPanel reloadPanel = new JPanel(new FlowLayout(FlowLayout.RIGHT));
        reloadPanel.setOpaque(false);
        JButton btnReload = new JButton("Làm Mới / Hiện Tất Cả");
        btnReload.setBackground(new Color(40, 167, 69)); btnReload.setForeground(Color.WHITE);
        btnLinkToFriend = new JButton("Quản lý chi tiết (Thêm/Sửa/Xóa) >>");
        btnLinkToFriend.setBackground(new Color(255, 140, 0)); btnLinkToFriend.setForeground(Color.WHITE);
        
        reloadPanel.add(btnReload);
        reloadPanel.add(Box.createHorizontalStrut(10));
        reloadPanel.add(btnLinkToFriend);
        mainTopPanel.add(reloadPanel);

        add(mainTopPanel, BorderLayout.NORTH);

        // ================= PHẦN 2: BẢNG DỮ LIỆU =================
        String[] columnNames = {"Mã Sản Phẩm", "Tên Sản Phẩm", "Giá Bán", "Loại Hàng", "Tên Cửa Hàng"};
        
        tableModel = new DefaultTableModel(columnNames, 0) {
            @Override
            public Class<?> getColumnClass(int columnIndex) {
                if (columnIndex == 2) return Double.class; // Cột Giá là số
                return String.class;
            }
            @Override
            public boolean isCellEditable(int row, int column) {
                return false;
            }
        };

        table = new JTable(tableModel);
        
        // Cấu hình Sorter
        sorter = new TableRowSorter<>(tableModel);
        // --- 👇 THÊM ĐOẠN NÀY ĐỂ SẮP XẾP TIẾNG VIỆT CHUẨN ---
        Collator viCollator = Collator.getInstance(new Locale("vi", "VN")); // Bộ so sánh tiếng Việt
        // Gán bộ so sánh này cho các cột chứa chữ (Tên, Loại, Shop)
        //sorter.setComparator(0, viCollator); // Cột 0: Mã Sản Phẩm
        sorter.setComparator(1, viCollator); // Cột 1: Tên Sản Phẩm
        sorter.setComparator(3, viCollator); // Cột 3: Loại Hàng
        sorter.setComparator(4, viCollator); // Cột 4: Tên Shop
        // -----------------------------------------------------

        table.setRowSorter(sorter); // Gán bộ sắp xếp vào bảng
        
        // 👇 THÊM ĐOẠN NÀY ĐỂ MẶC ĐỊNH SẮP XẾP GIẢM DẦN THEO MÃ SP (CỘT 0)
        List<RowSorter.SortKey> sortKeys = new ArrayList<>();
        sortKeys.add(new RowSorter.SortKey(0, SortOrder.ASCENDING)); // 0 là cột Mã, DESCENDING là giảm dần
        sorter.setSortKeys(sortKeys);
        // -----------------------------------------------------------

        table.setFont(new Font("Segoe UI", Font.PLAIN, 14));
        table.setRowHeight(28);
        table.getTableHeader().setFont(new Font("Segoe UI", Font.BOLD, 14));
        table.getTableHeader().setBackground(new Color(220, 220, 220));

        DefaultTableCellRenderer centerRenderer = new DefaultTableCellRenderer();
        centerRenderer.setHorizontalAlignment(JLabel.CENTER);
        table.getColumnModel().getColumn(0).setCellRenderer(centerRenderer); 
        
        table.getColumnModel().getColumn(2).setCellRenderer(new DefaultTableCellRenderer() {
            DecimalFormat formatter = new DecimalFormat("#,###");
            @Override
            public Component getTableCellRendererComponent(JTable table, Object value, boolean isSelected, boolean hasFocus, int row, int column) {
                if (value instanceof Number) {
                    value = formatter.format(value);
                }
                setHorizontalAlignment(JLabel.CENTER);
                return super.getTableCellRendererComponent(table, value, isSelected, hasFocus, row, column);
            }
        });

        table.getColumnModel().getColumn(1).setPreferredWidth(250); 
        table.getColumnModel().getColumn(4).setPreferredWidth(150); 

        JScrollPane scrollPane = new JScrollPane(table);
        scrollPane.setBorder(BorderFactory.createEmptyBorder(0, 10, 10, 10));
        add(scrollPane, BorderLayout.CENTER);

        // ================= PHẦN 3: XỬ LÝ SỰ KIỆN =================

        ActionListener actionKetHop = e -> loadData();
        btnTimKiem.addActionListener(actionKetHop);
        txtTimKiem.addActionListener(actionKetHop);
        txtMaSP.addActionListener(actionKetHop);
        txtTenSP.addActionListener(actionKetHop);
        txtLoai.addActionListener(actionKetHop);
        txtMaShop.addActionListener(actionKetHop);
        txtGiaMin.addActionListener(actionKetHop);
        txtGiaMax.addActionListener(actionKetHop);

        btnReload.addActionListener(e -> {// Xóa trắng tất cả ô nhập liệu
            txtTimKiem.setText("");
            txtMaSP.setText(""); txtTenSP.setText(""); txtLoai.setText(""); txtMaShop.setText("");
            txtGia.setText(""); txtGiaMin.setText(""); txtGiaMax.setText("");
            // 👇 SỬA LẠI ĐOẠN NÀY
            // Thay vì sorter.setSortKeys(null); hãy dùng code này:
            List<RowSorter.SortKey> defaultSort = new ArrayList<>();
            defaultSort.add(new RowSorter.SortKey(0, SortOrder.ASCENDING));
            sorter.setSortKeys(defaultSort);
            loadData();
        });

        btnLinkToFriend.addActionListener(e -> { // Chuyển giao diện
            JOptionPane.showMessageDialog(this, "Đang chuyển hướng sang giao diện Quản Lý Chi Tiết...", "Thông báo", JOptionPane.INFORMATION_MESSAGE);
        });

        table.addMouseListener(new MouseAdapter() {// Đổ dữ liệu từ bảng lên ô nhập liệu khi click
            @Override
            public void mouseClicked(MouseEvent e) {
                int selectedRow = table.getSelectedRow();
                if (selectedRow >= 0) {
                    selectedRow = table.convertRowIndexToModel(selectedRow);
                    txtMaSP.setText(tableModel.getValueAt(selectedRow, 0).toString());
                    txtTenSP.setText(tableModel.getValueAt(selectedRow, 1).toString());
                    Object priceObj = tableModel.getValueAt(selectedRow, 2);
                    if (priceObj instanceof Number) {
                        txtGia.setText(new DecimalFormat("#,###").format(priceObj));
                    }
                    txtLoai.setText(tableModel.getValueAt(selectedRow, 3).toString());
                    txtMaShop.setText(tableModel.getValueAt(selectedRow, 4).toString());
                }
            }
        });
    }

    // --- HÀM HỖ TRỢ TẠO Ô NHẬP LIỆU CÓ NÚT SORT ---
    private JPanel createSortablePanel(JTextField textField, int columnIndex) {
        JPanel panel = new JPanel(new BorderLayout()); 
        panel.setBackground(Color.WHITE);
        panel.add(textField, BorderLayout.CENTER); // tạo panel chứa các ô nhập liệu nằm ở giữa co giãn tự do

        // Panel chứa 2 nút nhỏ
        JPanel btnPanel = new JPanel(new GridLayout(2, 1)); // 2 hàng 1 cột cho 2 nút sort
        
        // Nút Tăng dần (Mũi tên lên)
        JButton btnUp = new JButton("▲");  
        btnUp.setMargin(new Insets(0, 2, 0, 2)); // Thu nhỏ lề nút
        btnUp.setFont(new Font("Arial", Font.PLAIN, 8)); // Font nhỏ
        btnUp.setFocusable(false); // Bỏ viền focus khi click (để nhìn đỡ rối)
        btnUp.setToolTipText("Sắp xếp tăng dần (A-Z)");// tip
        
        // Nút Giảm dần (Mũi tên xuống)
        JButton btnDown = new JButton("▼");
        btnDown.setMargin(new Insets(0, 2, 0, 2)); // Thu nhỏ lề nút
        btnDown.setFont(new Font("Arial", Font.PLAIN, 8)); // Font nhỏ
        btnDown.setFocusable(false); // Bỏ viền focus khi click (để nhìn đỡ rối)
        btnDown.setToolTipText("Sắp xếp giảm dần (Z-A)");// tip

        // Xử lý sự kiện Sort
        btnUp.addActionListener(e -> {// Tạo quy tắc: Sắp xếp cột 'columnIndex' theo chiều ASCENDING (Tăng dần) A-Z
            List<RowSorter.SortKey> sortKeys = new ArrayList<>();
            sortKeys.add(new RowSorter.SortKey(columnIndex, SortOrder.ASCENDING));
            sorter.setSortKeys(sortKeys); // Ra lệnh cho bộ lọc (sorter) thực thi quy tắc này
        });

        btnDown.addActionListener(e -> {// Tạo quy tắc: Sắp xếp cột 'columnIndex' theo chiều DESCENDING (Giảm dần) Z-A
            List<RowSorter.SortKey> sortKeys = new ArrayList<>();
            sortKeys.add(new RowSorter.SortKey(columnIndex, SortOrder.DESCENDING));
            sorter.setSortKeys(sortKeys); // Ra lệnh cho bộ lọc (sorter) thực thi quy tắc này
        });

        btnPanel.add(btnUp); // Bỏ nút Lên vào hộp nút
        btnPanel.add(btnDown); // Bỏ nút Xuống vào hộp nút
        
        panel.add(btnPanel, BorderLayout.EAST); // Đặt hộp nút sang bên PHẢI (East)
        return panel; // Trả về nguyên cái cụm đã lắp ghép xong
    }

    private void loadData() {
        tableModel.setRowCount(0); // Xóa dữ liệu cũ đi
        String tuKhoaNhanh = txtTimKiem.getText(); // Các từ khóa tìm kiếm
        String ma = txtMaSP.getText();
        String ten = txtTenSP.getText();
        String loai = txtLoai.getText();
        String shop = txtMaShop.getText();
        String giaMin = txtGiaMin.getText().trim(); // trim để xóa bỏ khoảng trắng thừa nếu có
        String giaMax = txtGiaMax.getText().trim();

        if (giaMin.isEmpty()) giaMin = "0"; // Mặc địnnh Giá Thấp Nhất bằng 0 nếu empty

        try {
            double min = Double.parseDouble(giaMin);
            if (min < 0) { JOptionPane.showMessageDialog(this, "Giá phải lớn hơn không!"); return; }
            if (!giaMax.isEmpty()) {
                double max = Double.parseDouble(giaMax);
                if (max < 0) { JOptionPane.showMessageDialog(this, "Giá phải lớn hơn không!"); return; }
                if (min > max) { JOptionPane.showMessageDialog(this, "Giá thấp nhất phải nhỏ hơn Giá cao nhất!"); return; }
            }
        } catch (NumberFormatException e) {
            JOptionPane.showMessageDialog(this, "Vui lòng nhập số hợp lệ vào ô giá!", "Lỗi", JOptionPane.ERROR_MESSAGE);
            return; // Không bao h có dụ này âu
        }

        List<SanPham> list = sanPhamDAO.timKiemKetHop(tuKhoaNhanh, ma, ten, loai, giaMin, giaMax, shop); // Gọi hàm tìm kiếm kết hợp trong DAO

        if (list.isEmpty()) { // Hổng tìm thấy gì thì thông báo
            JOptionPane.showMessageDialog(this,
                "Không tìm thấy sản phẩm nào khớp!",
                "THÔNG BÁO",
                JOptionPane.INFORMATION_MESSAGE);
        }

        for (SanPham sp : list) {
            Object[] row = {
                    sp.getMaSanPham(),
                    sp.getTenSanPham(),
                    sp.getGiaHienThi(), // Đổ giá trị vào ô
                    sp.getLoai(),
                    sp.getTenShop()
            };
            tableModel.addRow(row);
        }
    }
    private JLabel createStyledLabel(String text) { // hàm tạo đề mục đồng bộ
        JLabel label = new JLabel(text, SwingConstants.RIGHT);
        label.setFont(new Font("Segoe UI", Font.BOLD, 14));
        return label;
    }
}