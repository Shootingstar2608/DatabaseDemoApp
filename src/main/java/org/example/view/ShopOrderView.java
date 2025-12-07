package org.example.view;

import org.example.dao.ShopOrderDAO;
import org.example.model.OrderDTO;

import javax.swing.*;
import javax.swing.border.CompoundBorder;
import javax.swing.border.EmptyBorder;
import javax.swing.border.LineBorder;
import javax.swing.event.DocumentEvent;
import javax.swing.event.DocumentListener;
import javax.swing.table.DefaultTableCellRenderer;
import javax.swing.table.DefaultTableModel;
import javax.swing.table.JTableHeader;
import java.awt.*;
import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Locale;

public class ShopOrderView extends JFrame {

    // --- MÀU SẮC THEME SHOPEE CHUẨN ---
    private final Color SHOPEE_ORANGE = new Color(238, 77, 45); 
    private final Color SHOPEE_ORANGE_DARK = new Color(200, 50, 30);
    private final Color BG_COLOR = new Color(245, 245, 245);
    private final Color TABLE_HEADER_BG = new Color(250, 250, 250);
    private final Color TEXT_GRAY = new Color(117, 117, 117);
    private final Color SUCCESS_GREEN = new Color(0, 150, 0);
    private final Color ERROR_RED = new Color(220, 53, 69);

    // --- LOGIC ---
    private ShopOrderDAO orderDAO = new ShopOrderDAO();
    private Timer debounceTimer;

    // --- COMPONENTS ---
    private JTextField txtMaShop;
    private JLabel lblStatusLog; // Log thông báo trạng thái
    private JTable tableOrders;
    private DefaultTableModel tableModel;
    private JLabel lblTotalOrders;

    public ShopOrderView() {
        initUI();
        setupEvents();
    }

    private void initUI() {
        setTitle("Quản Lý Đơn Hàng - Kênh Người Bán");
        // 1. KÍCH THƯỚC BỰ 1280x720
        setSize(1980, 1080);
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setLocationRelativeTo(null);
        getContentPane().setBackground(BG_COLOR);
        setLayout(new BorderLayout());

        // --- HEADER ---
        JPanel pnlHeader = new JPanel(new BorderLayout());
        pnlHeader.setBackground(Color.WHITE);
        // Viền cam dưới header tạo điểm nhấn
        pnlHeader.setBorder(new CompoundBorder(
            BorderFactory.createMatteBorder(0, 0, 4, 0, SHOPEE_ORANGE), 
            new EmptyBorder(15, 25, 15, 25)
        ));
        
        JLabel lblTitle = new JLabel("Kênh Người Bán");
        lblTitle.setFont(new Font("Segoe UI", Font.BOLD, 24));
        lblTitle.setForeground(SHOPEE_ORANGE);
        
        // INPUT PANEL (Góc phải header)
        JPanel pnlInputContainer = new JPanel(new BorderLayout());
        pnlInputContainer.setBackground(Color.WHITE);
        
        JPanel pnlInput = new JPanel(new FlowLayout(FlowLayout.RIGHT, 10, 0));
        pnlInput.setBackground(Color.WHITE);
        
        JLabel lblShop = new JLabel("Mã Shop: ");
        lblShop.setFont(new Font("Segoe UI", Font.BOLD, 15));
        
        txtMaShop = new JTextField("", 12);
        txtMaShop.setFont(new Font("Segoe UI", Font.PLAIN, 15));
        txtMaShop.setBorder(BorderFactory.createCompoundBorder(
            new LineBorder(new Color(200, 200, 200)),
            new EmptyBorder(5, 8, 5, 8)
        ));
        
        // Log thông báo nằm ngay dưới ô nhập (hoặc bên cạnh)
        lblStatusLog = new JLabel("Nhập mã shop để xem đơn hàng...");
        lblStatusLog.setFont(new Font("Segoe UI", Font.ITALIC, 12));
        lblStatusLog.setForeground(TEXT_GRAY);
        lblStatusLog.setHorizontalAlignment(SwingConstants.RIGHT);
        lblStatusLog.setBorder(new EmptyBorder(5, 0, 0, 5)); // Padding chút

        pnlInput.add(lblShop);
        pnlInput.add(txtMaShop);
        // Đã bỏ button "Xem Đơn" theo yêu cầu

        pnlInputContainer.add(pnlInput, BorderLayout.CENTER);
        pnlInputContainer.add(lblStatusLog, BorderLayout.SOUTH);

        pnlHeader.add(lblTitle, BorderLayout.WEST);
        pnlHeader.add(pnlInputContainer, BorderLayout.EAST);
        add(pnlHeader, BorderLayout.NORTH);

        // --- BODY (TABLE) ---
        JPanel pnlBody = new JPanel(new BorderLayout());
        pnlBody.setBackground(BG_COLOR);
        pnlBody.setBorder(new EmptyBorder(20, 20, 20, 20));

        // Setup Table
        String[] columns = {
            "STT", 
            "Mã Đơn", 
            "Người Mua",           
            "Sản Phẩm (Phân loại)", 
            "Đơn giá",                // Lấy từ DB
            "SL", 
            "Thành tiền",             // GiaBanDau của đơn hàng
            "Khách Trả", 
            "Shop thực sự nhận",      // Thực thu
            "Trạng Thái", 
            "Ngày Đặt", 
            "Hạn Giao"
        };
        tableModel = new DefaultTableModel(columns, 0) {
            @Override // Không cho sửa
            public boolean isCellEditable(int row, int column) { return false; }
        };
        
        tableOrders = new JTable(tableModel);
        styleTable(tableOrders);
        
        JScrollPane scrollPane = new JScrollPane(tableOrders);
        scrollPane.setBorder(BorderFactory.createLineBorder(new Color(230, 230, 230)));
        scrollPane.getViewport().setBackground(Color.WHITE);
        pnlBody.add(scrollPane, BorderLayout.CENTER);
        
        add(pnlBody, BorderLayout.CENTER);

        // --- FOOTER ---
        JPanel pnlFooter = new JPanel(new FlowLayout(FlowLayout.LEFT));
        pnlFooter.setBackground(Color.WHITE);
        pnlFooter.setBorder(new CompoundBorder(
            BorderFactory.createMatteBorder(1, 0, 0, 0, new Color(220, 220, 220)),
            new EmptyBorder(15, 25, 15, 25)
        ));
        
        lblTotalOrders = new JLabel("Tổng số đơn hàng: 0");
        lblTotalOrders.setFont(new Font("Segoe UI", Font.BOLD, 15));
        lblTotalOrders.setForeground(TEXT_GRAY);
        
        pnlFooter.add(lblTotalOrders);
        add(pnlFooter, BorderLayout.SOUTH);
    }

    // --- LOGIC AUTO CHECK ---
    private void setupEvents() {
        // Debounce timer: Chờ 600ms sau khi ngừng gõ mới load dữ liệu
        debounceTimer = new Timer(600, e -> loadData());
        debounceTimer.setRepeats(false);

        txtMaShop.getDocument().addDocumentListener(new DocumentListener() {
            public void insertUpdate(DocumentEvent e) { restartTimer(); }
            public void removeUpdate(DocumentEvent e) { restartTimer(); }
            public void changedUpdate(DocumentEvent e) { restartTimer(); }
        });
    }

    private void restartTimer() {
        if (txtMaShop.getText().trim().isEmpty()) {
            lblStatusLog.setText("Vui lòng nhập mã shop");
            lblStatusLog.setForeground(TEXT_GRAY);
            tableModel.setRowCount(0);
            lblTotalOrders.setText("Tổng số đơn hàng: 0");
            return;
        }
        
        lblStatusLog.setText("Đang tìm kiếm...");
        lblStatusLog.setForeground(SHOPEE_ORANGE);
        debounceTimer.restart();
    }

    private void loadData() {
        String maShop = txtMaShop.getText().trim();
        if (maShop.isEmpty()) return;

        new SwingWorker<List<OrderDTO>, Void>() {
            @Override
            protected List<OrderDTO> doInBackground() throws Exception {
                return orderDAO.getOrdersByShop(maShop);
            }

            @Override
            protected void done() {
                try {
                    List<OrderDTO> list = get();
                    updateTable(list);
                    
                    // Logic LOG thông báo
                    if (list.isEmpty()) {
                        lblStatusLog.setText("Không tìm thấy đơn hàng hoặc Mã Shop sai!");
                        lblStatusLog.setForeground(ERROR_RED);
                    } else {
                        lblStatusLog.setText("Cập nhật thành công: " + list.size() + " đơn hàng");
                        lblStatusLog.setForeground(SUCCESS_GREEN);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    lblStatusLog.setText("Lỗi kết nối cơ sở dữ liệu!");
                    lblStatusLog.setForeground(ERROR_RED);
                }
            }
        }.execute();
    }

    private void updateTable(List<OrderDTO> list) {
        tableModel.setRowCount(0);
        
        NumberFormat vnFormat = NumberFormat.getCurrencyInstance(Locale.forLanguageTag("vi-VN"));
        SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
        SimpleDateFormat dateOnlyFormat = new SimpleDateFormat("dd/MM/yyyy");

        for (OrderDTO o : list) {
            // Không tính toán ở đây nữa, lấy trực tiếp getter
            tableModel.addRow(new Object[]{
                o.getStt(),
                o.getMaDonHang(),
                o.getTenNguoiMua(),                
                o.getTenSanPhamHienThi(),          
                vnFormat.format(o.getDonGia()),    //(Đơn giá từ DB)
                o.getSoLuong(),                    
                vnFormat.format(o.getGiaBanDau()), // Cột 6 (Thành tiền)
                vnFormat.format(o.getThanhTien()), // Cột 7 (Khách trả)
                vnFormat.format(o.getThucThu()),   // Cột 8 (Shop nhận được á)
                o.getTrangThai(),
                o.getNgayDat() != null ? dateFormat.format(o.getNgayDat()) : "",
                o.getNgayDuKienGiao() != null ? dateOnlyFormat.format(o.getNgayDuKienGiao()) : ""
            });
        }
        
        lblTotalOrders.setText("Tổng số đơn hàng: " + list.size());
    }

    // --- STYLING METHODS ---

    private void styleTable(JTable table) {
        table.setRowHeight(45); // Dòng cao hơn cho thoáng
        table.setFont(new Font("Segoe UI", Font.PLAIN, 14));
        table.setGridColor(new Color(230, 230, 230));
        table.setShowVerticalLines(false);
        table.setIntercellSpacing(new Dimension(0, 1));
        // Màu nền khi chọn dòng
        table.setSelectionBackground(new Color(255, 240, 230)); 
        table.setSelectionForeground(Color.BLACK);

        JTableHeader header = table.getTableHeader();
        header.setFont(new Font("Segoe UI", Font.BOLD, 14));
        header.setBackground(TABLE_HEADER_BG);
        header.setForeground(new Color(80, 80, 80));
        header.setPreferredSize(new Dimension(0, 50));
        header.setBorder(BorderFactory.createMatteBorder(0, 0, 1, 0, new Color(200, 200, 200)));
        
        // Căn chỉnh cột
        DefaultTableCellRenderer centerRenderer = new DefaultTableCellRenderer();
        centerRenderer.setHorizontalAlignment(JLabel.CENTER);
        
        DefaultTableCellRenderer rightRenderer = new DefaultTableCellRenderer();
        rightRenderer.setHorizontalAlignment(JLabel.RIGHT);
        
        // Màu chữ cho cột trạng thái và tiền
        DefaultTableCellRenderer statusRenderer = new DefaultTableCellRenderer() {
            @Override
            public Component getTableCellRendererComponent(JTable table, Object value, boolean isSelected, boolean hasFocus, int row, int column) {
                Component c = super.getTableCellRendererComponent(table, value, isSelected, hasFocus, row, column);
                if (!isSelected) {
                    String status = (String) value;
                    if ("Đã hoàn thành".equals(status)) {
                        c.setForeground(SUCCESS_GREEN);
                        c.setFont(c.getFont().deriveFont(Font.BOLD));
                    }
                    else if ("Đã hủy".equals(status)) c.setForeground(ERROR_RED);
                    else if ("Đang xử lý".equals(status)) c.setForeground(SHOPEE_ORANGE);
                    else c.setForeground(Color.BLACK);
                }
                setHorizontalAlignment(JLabel.CENTER);
                return c;
            }
        };
        
        // Tiền thực thu in đậm
        DefaultTableCellRenderer moneyRenderer = new DefaultTableCellRenderer() {
             @Override
            public Component getTableCellRendererComponent(JTable table, Object value, boolean isSelected, boolean hasFocus, int row, int column) {
                Component c = super.getTableCellRendererComponent(table, value, isSelected, hasFocus, row, column);
                if (!isSelected) {
                    c.setForeground(SHOPEE_ORANGE);
                    c.setFont(c.getFont().deriveFont(Font.BOLD));
                }
                setHorizontalAlignment(JLabel.RIGHT);
                return c;
            }
        };

        // --- Căn lề loại cho từng cột ---
        table.getColumnModel().getColumn(0).setCellRenderer(centerRenderer); // STT
        table.getColumnModel().getColumn(1).setCellRenderer(centerRenderer); // Mã
        table.getColumnModel().getColumn(2).setCellRenderer(centerRenderer); // Người mua
        table.getColumnModel().getColumn(4).setCellRenderer(rightRenderer);  // Đơn giá
        table.getColumnModel().getColumn(5).setCellRenderer(centerRenderer); // SL
        table.getColumnModel().getColumn(6).setCellRenderer(rightRenderer);  // Thành tiền
        table.getColumnModel().getColumn(7).setCellRenderer(rightRenderer);  // Khách trả
        table.getColumnModel().getColumn(8).setCellRenderer(moneyRenderer);  // Shop nhận (Đậm)
        table.getColumnModel().getColumn(9).setCellRenderer(statusRenderer); // Trạng thái
        table.getColumnModel().getColumn(10).setCellRenderer(centerRenderer);// Ngày đặt
        table.getColumnModel().getColumn(11).setCellRenderer(centerRenderer);// Hạn giao

        // --- SET ĐỘ RỘNG (RESPONSIVE 1920x1080) ---
        // Tổng chiều rộng 
        table.getColumnModel().getColumn(0).setPreferredWidth(50);   // STT
        table.getColumnModel().getColumn(1).setPreferredWidth(110);  // Mã Đơn
        table.getColumnModel().getColumn(2).setPreferredWidth(250);  // Người Mua
        table.getColumnModel().getColumn(3).setPreferredWidth(310);  // Sản Phẩm (Rộng nhất)
        table.getColumnModel().getColumn(4).setPreferredWidth(120);  // Đơn giá
        table.getColumnModel().getColumn(5).setPreferredWidth(50);   // SL
        table.getColumnModel().getColumn(6).setPreferredWidth(140);  // Thành tiền
        table.getColumnModel().getColumn(7).setPreferredWidth(140);  // Khách trả
        table.getColumnModel().getColumn(8).setPreferredWidth(140);  // Shop nhận
        table.getColumnModel().getColumn(9).setPreferredWidth(150);  // Trạng thái
        table.getColumnModel().getColumn(10).setPreferredWidth(180); // Ngày đặt (Rộng)
        table.getColumnModel().getColumn(11).setPreferredWidth(180); // Hạn giao (Rộng)
    }

    public static void main(String[] args) {
        try {
            // Kích hoạt FlatLaf (Giao diện phẳng hiện đại)
            UIManager.setLookAndFeel(new com.formdev.flatlaf.FlatLightLaf());
        } catch (Exception e) {
            e.printStackTrace();
        }
        SwingUtilities.invokeLater(() -> new ShopOrderView().setVisible(true));
    }
}