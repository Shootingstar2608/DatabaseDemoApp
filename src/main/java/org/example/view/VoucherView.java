package org.example.view;

import org.example.dao.VoucherDAO;
import org.example.model.VoucherDTO;
import org.example.model.ReceiptDTO;

import javax.swing.*;
import javax.swing.border.CompoundBorder;
import javax.swing.border.EmptyBorder;
import javax.swing.border.LineBorder;
import javax.swing.event.DocumentEvent;
import javax.swing.event.DocumentListener;
import java.awt.*;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.math.BigDecimal;
import java.text.NumberFormat;
import java.util.List;
import java.util.Locale;
import java.util.stream.Collectors;

public class VoucherView extends JFrame {

    // --- MÀU SẮC THEME SHOPEE CHUẨN ---
    private final Color SHOPEE_ORANGE = new Color(238, 77, 45); // Cam đậm chuẩn
    private final Color SHOPEE_ORANGE_HOVER = new Color(255, 90, 60); // Cam sáng hơn khi hover
    private final Color SHOPEE_ORANGE_PRESSED = new Color(200, 50, 30); // Cam đậm khi nhấn
    private final Color BG_COLOR = new Color(245, 245, 245);
    private final Color TEXT_GRAY = new Color(117, 117, 117);
    
    // Màu cho trạng thái Disabled
    private final Color BTN_DISABLED_BG = new Color(200, 200, 200);
    private final Color BTN_DISABLED_TEXT = new Color(150, 150, 150);

    // --- MÀU THEME VOUCHER (ĐẬM ĐÀ HƠN) ---
    // Shop: Đỏ Nâu Đậm
    private final Color SHOP_THEME_COLOR = new Color(139, 0, 0); 
    private final Color SHOP_BG_LIGHT = new Color(255, 235, 235);
    
    // Admin: Cam Shopee Đậm
    private final Color ADMIN_THEME_COLOR = SHOPEE_ORANGE;
    private final Color ADMIN_BG_LIGHT = new Color(255, 242, 235);

    // Transport: Xanh Dương Đậm (Cyan Blue)
    private final Color TRANS_THEME_COLOR = new Color(0, 140, 200); 
    private final Color TRANS_BG_LIGHT = new Color(235, 250, 255);

    // --- LOGIC ---
    private VoucherDAO voucherDAO = new VoucherDAO();
    private String currentMaDon = "";
    private String selectedShopCode = null;
    private String selectedAdminCode = null;
    private String selectedTransCode = null;
    private Timer debounceTimer; // Timer check mã đơn

    // --- COMPONENTS ---
    private JTextField txtMaDonHang;
    private JLabel lblErrorMsg; // Log thông báo lỗi mã đơn
    private JPanel pnlShopSection, pnlAdminSection, pnlTransSection;
    private JLabel lblShopStatus, lblAdminStatus, lblTransStatus;
    private JButton btnOrder; 
    
    // Components hiển thị chi tiết hóa đơn
    private JLabel lblValTienHang, lblValPhiShip, lblValGiamShop, lblValGiamAdmin, lblValGiamShip;
    private JLabel lblTongThanhToan;
    private JPanel pnlDetailRows; 
    private JLabel lblValGiaNiemYet, lblValChietKhau;

    public VoucherView() {
        initUI();
        setupEvents();
    }

    private void initUI() {
        setTitle("Hệ Thống Thanh Toán Hiện Đại");
        setSize(600, 1000); 
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setLocationRelativeTo(null);
        getContentPane().setBackground(BG_COLOR);
        setLayout(new BorderLayout());

        // --- HEADER ---
        JPanel pnlHeader = new JPanel(new FlowLayout(FlowLayout.LEFT));
        pnlHeader.setBackground(Color.WHITE);
        pnlHeader.setBorder(new EmptyBorder(15, 20, 15, 20));
        // Thêm shadow border nhẹ cho header
        pnlHeader.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createMatteBorder(0, 0, 1, 0, new Color(230,230,230)),
            new EmptyBorder(15, 20, 15, 20)
        ));
        
        JLabel lblTitle = new JLabel("Thanh Toán");
        lblTitle.setFont(new Font("Segoe UI", Font.BOLD, 24));
        lblTitle.setForeground(SHOPEE_ORANGE); // Màu cam cho tiêu đề
        pnlHeader.add(lblTitle);
        add(pnlHeader, BorderLayout.NORTH);

        // --- BODY (Scrollable) ---
        JPanel pnlBody = new JPanel();
        pnlBody.setLayout(new BoxLayout(pnlBody, BoxLayout.Y_AXIS));
        pnlBody.setBackground(BG_COLOR);
        pnlBody.setBorder(new EmptyBorder(20, 20, 20, 20));

        // -- INPUT ĐƠN HÀNG --
        JPanel pnlInputContainer = new JPanel(new BorderLayout());
        pnlInputContainer.setBackground(Color.WHITE);
        pnlInputContainer.setBorder(new CompoundBorder(
                new LineBorder(new Color(220, 220, 220), 1, true), // Bo góc nhẹ
                new EmptyBorder(15, 20, 10, 20)
        ));
        pnlInputContainer.setMaximumSize(new Dimension(600, 100));

        JPanel pnlInputRow = new JPanel(new BorderLayout(15, 5));
        pnlInputRow.setBackground(Color.WHITE);
        
        JLabel lblMaDon = new JLabel("Mã Đơn Hàng:");
        lblMaDon.setFont(new Font("Segoe UI", Font.BOLD, 16));
        
        txtMaDonHang = new JTextField(""); 
        txtMaDonHang.setFont(new Font("Segoe UI", Font.PLAIN, 16));
        txtMaDonHang.setBorder(BorderFactory.createMatteBorder(0, 0, 1, 0, Color.LIGHT_GRAY)); // Chỉ viền dưới
        
        pnlInputRow.add(lblMaDon, BorderLayout.WEST);
        pnlInputRow.add(txtMaDonHang, BorderLayout.CENTER);
        
        // Log báo lỗi ngay dưới ô input
        lblErrorMsg = new JLabel("Nhập mã đơn hàng để tiếp tục...");
        lblErrorMsg.setForeground(TEXT_GRAY);
        lblErrorMsg.setFont(new Font("Segoe UI", Font.ITALIC, 13));
        lblErrorMsg.setBorder(new EmptyBorder(5, 0, 0, 0));

        pnlInputContainer.add(pnlInputRow, BorderLayout.CENTER);
        pnlInputContainer.add(lblErrorMsg, BorderLayout.SOUTH);

        pnlBody.add(pnlInputContainer);
        pnlBody.add(Box.createVerticalStrut(25));

        // -- CÁC MỤC CHỌN VOUCHER --
        pnlShopSection = createVoucherSection("Voucher của Shop", "SHOP", SHOP_THEME_COLOR);
        lblShopStatus = (JLabel) ((JPanel)pnlShopSection.getComponent(1)).getComponent(0);
        setupSectionClick(pnlShopSection, "SHOP");
        pnlBody.add(pnlShopSection);
        pnlBody.add(Box.createVerticalStrut(15));

        // Đổi tên thành "Voucher Hệ thống"
        pnlAdminSection = createVoucherSection("Voucher Hệ thống", "ADMIN", ADMIN_THEME_COLOR);
        lblAdminStatus = (JLabel) ((JPanel)pnlAdminSection.getComponent(1)).getComponent(0);
        setupSectionClick(pnlAdminSection, "ADMIN");
        pnlBody.add(pnlAdminSection);
        pnlBody.add(Box.createVerticalStrut(15));

        pnlTransSection = createVoucherSection("Phương thức vận chuyển", "TRANSPORT", TRANS_THEME_COLOR);
        lblTransStatus = (JLabel) ((JPanel)pnlTransSection.getComponent(1)).getComponent(0);
        setupSectionClick(pnlTransSection, "TRANSPORT");
        pnlBody.add(pnlTransSection);
        
        // -- CHI TIẾT THANH TOÁN --
        pnlBody.add(Box.createVerticalStrut(25));
        JPanel pnlPaymentDetail = createPaymentDetailPanel();
        pnlBody.add(pnlPaymentDetail);

        add(new JScrollPane(pnlBody), BorderLayout.CENTER);

        // --- FOOTER ---
        JPanel pnlFooter = new JPanel(new BorderLayout());
        pnlFooter.setBackground(Color.WHITE);
        // Shadow top border
        pnlFooter.setBorder(BorderFactory.createCompoundBorder(
             BorderFactory.createMatteBorder(1, 0, 0, 0, new Color(230,230,230)),
             new EmptyBorder(20, 25, 20, 25)
        ));

        JPanel pnlTotalText = new JPanel(new FlowLayout(FlowLayout.RIGHT));
        pnlTotalText.setBackground(Color.WHITE);
        JLabel lblLabelTotal = new JLabel("Tổng thanh toán:");
        lblLabelTotal.setFont(new Font("Segoe UI", Font.BOLD, 16));
        
        lblTongThanhToan = new JLabel("0 đ");
        lblTongThanhToan.setFont(new Font("Segoe UI", Font.BOLD, 26));
        lblTongThanhToan.setForeground(SHOPEE_ORANGE);
        
        pnlTotalText.add(lblLabelTotal);
        pnlTotalText.add(lblTongThanhToan);

        //btnOrder = new JButton("Đặt Hàng");
        btnOrder = new JButton("Đặt Hàng") {
            @Override
            protected void paintComponent(Graphics g) {
                Graphics2D g2 = (Graphics2D) g.create();
                // Khử răng cưa cho đẹp
                g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        
                // LOGIC CHỌN MÀU (TỰ ĐỘNG)
                if (!isEnabled()) {
                    g2.setColor(BTN_DISABLED_BG); // Màu khi disable
                } else if (getModel().isPressed()) {
                    g2.setColor(SHOPEE_ORANGE_PRESSED); // Màu khi đang nhấn (Click giữ)
                } else if (getModel().isRollover()) {
                    g2.setColor(SHOPEE_ORANGE_HOVER); // Màu khi chuột lướt qua
                } else {
                    g2.setColor(SHOPEE_ORANGE); // Màu bình thường
                }
        
                // Vẽ hình chữ nhật full nút (nếu thích bo góc thì dùng fillRoundRect)
                g2.fillRect(0, 0, getWidth(), getHeight()); 
                
                g2.dispose();
                
                // Gọi super để nó vẽ chữ "Đặt Hàng" lên trên cái nền mình vừa vẽ
                super.paintComponent(g);
            }
        };
        btnOrder.setContentAreaFilled(false);
        btnOrder.setFocusPainted(false);   
        btnOrder.setBorderPainted(false);    
        btnOrder.setOpaque(false); 

        btnOrder.setFont(new Font("Segoe UI", Font.BOLD, 18));
        btnOrder.setForeground(Color.WHITE); // Màu chữ luôn trắng
        btnOrder.setPreferredSize(new Dimension(180, 55));
        btnOrder.setCursor(new Cursor(Cursor.HAND_CURSOR)); // Thêm icon bàn tay chỉ vào

        setButtonStyle(btnOrder, false); 
        btnOrder.setFont(new Font("Segoe UI", Font.BOLD, 18));
        btnOrder.setPreferredSize(new Dimension(180, 55));
        
        // --- SỰ KIỆN NÚT ĐẶT HÀNG ĐÃ SỬA ---
        btnOrder.addActionListener(e -> {
            if (currentMaDon.isEmpty()) return;
            
            // Disable nút để tránh click đúp
            btnOrder.setEnabled(false);
            
            new SwingWorker<Boolean, Void>() {
                @Override
                protected Boolean doInBackground() throws Exception {
                    // Gọi xuống DB để lưu voucher bằng hàm placeOrder
                    return voucherDAO.placeOrder(currentMaDon, selectedShopCode, selectedAdminCode, selectedTransCode);
                }

                @Override
                protected void done() {
                    try {
                        boolean success = get();
                        if (success) {
                            String msg = "Đặt hàng thành công!\n" +
                                         "Đơn hàng: " + currentMaDon + "\n" +
                                         "Voucher đã lưu: " + 
                                         (selectedShopCode != null ? selectedShopCode + ", " : "") +
                                         (selectedAdminCode != null ? selectedAdminCode + ", " : "") +
                                         (selectedTransCode != null ? selectedTransCode : "");
                                         
                            JOptionPane.showMessageDialog(VoucherView.this, msg, "Thành công", JOptionPane.INFORMATION_MESSAGE);
                            btnOrder.setEnabled(true);
                            // Reset sau khi đặt xong
                            //resetData();
                            //txtMaDonHang.setText("");
                        } else {
                            JOptionPane.showMessageDialog(VoucherView.this, "Có lỗi xảy ra khi lưu đơn hàng!", "Lỗi", JOptionPane.ERROR_MESSAGE);
                            btnOrder.setEnabled(true); // Mở lại nút nếu lỗi
                        }
                    } catch (Exception ex) {
                        ex.printStackTrace();
                        btnOrder.setEnabled(true);
                    }
                }
            }.execute();
        });

        pnlFooter.add(pnlTotalText, BorderLayout.CENTER);
        pnlFooter.add(btnOrder, BorderLayout.EAST);

        add(pnlFooter, BorderLayout.SOUTH);
    }

    // --- SETUP EVENTS ---
    private void setupEvents() {
        // Debounce Timer (0.5s = 500ms) - Tự động check khi ngừng gõ
        debounceTimer = new Timer(500, e -> checkMaDonTonTai());
        debounceTimer.setRepeats(false);

        txtMaDonHang.getDocument().addDocumentListener(new DocumentListener() {
            public void insertUpdate(DocumentEvent e) { handleInput(); }
            public void removeUpdate(DocumentEvent e) { handleInput(); }
            public void changedUpdate(DocumentEvent e) { handleInput(); }
            void handleInput() {
                String text = txtMaDonHang.getText().trim();
                if (!text.isEmpty()) {
                    lblErrorMsg.setText("Đang kiểm tra...");
                    lblErrorMsg.setForeground(Color.BLUE);
                    debounceTimer.restart(); // Reset timer khi gõ
                } else {
                    lblErrorMsg.setText("Nhập mã đơn hàng để tiếp tục...");
                    lblErrorMsg.setForeground(TEXT_GRAY);
                    resetData(); // Xóa data nếu ô trống
                }
            }
        });
    }

    private void resetData() {
        currentMaDon = "";
        selectedShopCode = null;
        selectedAdminCode = null;
        selectedTransCode = null;
        lblShopStatus.setText("Chọn hoặc nhập mã >");
        lblAdminStatus.setText("Chọn hoặc nhập mã >");
        lblTransStatus.setText("Chọn hoặc nhập mã >");
        setButtonStyle(btnOrder, false);
        // Reset bảng giá về 0
        updatePaymentDetails(new ReceiptDTO() {{
            setGiaNiemYet(java.math.BigDecimal.ZERO);
            setTienChietKhau(java.math.BigDecimal.ZERO);
            setGiaGoc(java.math.BigDecimal.ZERO);
            setGiaGoc(java.math.BigDecimal.ZERO);
            setPhiVanChuyen(java.math.BigDecimal.ZERO);
            setGiamGiaShop(java.math.BigDecimal.ZERO);
            setGiamGiaAdmin(java.math.BigDecimal.ZERO);
            setGiamGiaShip(java.math.BigDecimal.ZERO);
            setTongThanhToan(java.math.BigDecimal.ZERO);
        }});
    }

    // --- LOGIC CHECK MÃ ĐƠN & AUTO LOAD ---
    private void checkMaDonTonTai() {
        String maDon = txtMaDonHang.getText().trim();
        if (maDon.isEmpty()) return;

        // Chạy ngầm để không lag UI
        new SwingWorker<Boolean, Void>() {
            @Override
            protected Boolean doInBackground() throws Exception {
                // Gọi thử hàm tính tiền với null params để check đơn
                ReceiptDTO r = voucherDAO.getReceiptDetails(maDon, null, null, null);
                return r != null && r.getMaDonHang() != null;
            }

            @Override
            protected void done() {
                try {
                    boolean exists = get();
                    if (!exists) {
                        lblErrorMsg.setText("Mã đơn hàng không tồn tại!");
                        lblErrorMsg.setForeground(Color.RED);
                        setButtonStyle(btnOrder, false);
                    } else {
                        lblErrorMsg.setText("Đơn hàng hợp lệ.");
                        lblErrorMsg.setForeground(new Color(0, 128, 0)); // Xanh lá
                        // TỰ ĐỘNG LOAD DỮ LIỆU
                        resetAndLoad(maDon);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }.execute();
    }

    // --- HÀM SET STYLE BUTTON (FIX LỖI ĐỔI MÀU) ---
    private void setButtonStyle(JButton btn, boolean isActive) {
        btn.setEnabled(isActive);
        if (isActive) {
            btn.setForeground(Color.WHITE);
        } else {
            btn.setForeground(BTN_DISABLED_TEXT);
        }
    }

    private JPanel createPaymentDetailPanel() {
        JPanel panel = new JPanel(new BorderLayout());
        panel.setBackground(Color.WHITE);
        panel.setBorder(new CompoundBorder(
                new LineBorder(new Color(220, 220, 220), 1, true),
                new EmptyBorder(20, 20, 20, 20)
        ));
        // Tăng chiều cao tối đa lên xíu để chứa đủ dòng mới
        panel.setMaximumSize(new Dimension(600, 350)); 

        JLabel lblTitle = new JLabel("Chi tiết thanh toán");
        lblTitle.setFont(new Font("Segoe UI", Font.BOLD, 16));
        lblTitle.setBorder(new EmptyBorder(0, 0, 15, 0));
        panel.add(lblTitle, BorderLayout.NORTH);

        pnlDetailRows = new JPanel(new GridLayout(0, 1, 12, 10)); 
        pnlDetailRows.setBackground(Color.WHITE);

        // Khởi tạo các label mới
        lblValGiaNiemYet = createValueLabel();
        lblValChietKhau = createValueLabel(); // Label cho chiết khấu
        
        lblValTienHang = createValueLabel(); // Cái này giờ là Giá sau chiết khấu (Tạm tính)
        lblValPhiShip = createValueLabel();
        lblValGiamShop = createValueLabel();
        lblValGiamAdmin = createValueLabel();
        lblValGiamShip = createValueLabel();

        // THÊM DÒNG VÀO UI
        pnlDetailRows.add(createRow("Giá ban đầu", lblValGiaNiemYet));
        pnlDetailRows.add(createRow("Giá chiết khấu (%)", lblValChietKhau));
        // Dòng kẻ phân cách nhẹ (Optional, nếu muốn đẹp)
        
        pnlDetailRows.add(createRow("Tổng tiền hàng (Sau CK)", lblValTienHang));
        pnlDetailRows.add(createRow("Phí vận chuyển", lblValPhiShip));
        pnlDetailRows.add(createRow("Voucher của Shop", lblValGiamShop));
        pnlDetailRows.add(createRow("Voucher Hệ thống", lblValGiamAdmin));
        pnlDetailRows.add(createRow("Giảm giá phí vận chuyển", lblValGiamShip));

        panel.add(pnlDetailRows, BorderLayout.CENTER);
        return panel;
    }

    private JPanel createRow(String title, JLabel valLabel) {
        JPanel row = new JPanel(new BorderLayout());
        row.setBackground(Color.WHITE);
        JLabel lbl = new JLabel(title);
        lbl.setFont(new Font("Segoe UI", Font.PLAIN, 15));
        lbl.setForeground(TEXT_GRAY);
        row.add(lbl, BorderLayout.WEST);
        row.add(valLabel, BorderLayout.EAST);
        return row;
    }

    private JLabel createValueLabel() {
        JLabel lbl = new JLabel("0 đ");
        lbl.setFont(new Font("Segoe UI", Font.PLAIN, 15));
        lbl.setHorizontalAlignment(SwingConstants.RIGHT);
        return lbl;
    }

    // --- CẬP NHẬT GIAO DIỆN MỤC CHỌN VOUCHER ---
    private JPanel createVoucherSection(String title, String type, Color themeColor) {
        JPanel panel = new JPanel(new BorderLayout());
        panel.setBackground(Color.WHITE);
        panel.setMaximumSize(new Dimension(600, 75)); 
        
        // Viền hiện đại, shadow giả
        panel.setBorder(new CompoundBorder(
                BorderFactory.createMatteBorder(0, 0, 2, 0, new Color(240, 240, 240)), // Separator line dưới
                new CompoundBorder(
                    new LineBorder(new Color(230, 230, 230), 1, true), // Viền bo nhẹ
                    BorderFactory.createCompoundBorder(
                        BorderFactory.createMatteBorder(0, 6, 0, 0, themeColor), // Color indicator trái
                        new EmptyBorder(15, 20, 15, 20)
                    )
                )
        ));
        panel.setCursor(new Cursor(Cursor.HAND_CURSOR));

        JLabel lblTitle = new JLabel(title);
        lblTitle.setFont(new Font("Segoe UI", Font.BOLD, 16)); 

        JPanel pnlRight = new JPanel(new FlowLayout(FlowLayout.RIGHT));
        pnlRight.setOpaque(false);
        
        JLabel lblStatus = new JLabel("Chọn hoặc nhập mã >");
        lblStatus.setFont(new Font("Segoe UI", Font.PLAIN, 15));
        lblStatus.setForeground(TEXT_GRAY);
        pnlRight.add(lblStatus);

        panel.add(lblTitle, BorderLayout.WEST);
        panel.add(pnlRight, BorderLayout.EAST);

        return panel;
    }

    private void resetAndLoad(String maDon) {
        currentMaDon = maDon;
        
        // Reset selections mỗi khi nhập mã đơn mới
        selectedShopCode = null;
        selectedAdminCode = null;
        selectedTransCode = null;
        
        lblShopStatus.setText("Chọn hoặc nhập mã >");
        lblShopStatus.setForeground(TEXT_GRAY);
        lblAdminStatus.setText("Chọn hoặc nhập mã >");
        lblAdminStatus.setForeground(TEXT_GRAY);
        lblTransStatus.setText("Chọn hoặc nhập mã >");
        lblTransStatus.setForeground(TEXT_GRAY);

        reCalculate();
        setButtonStyle(btnOrder, true); // Kích hoạt nút đặt hàng
    }

    private void setupSectionClick(JPanel panel, String type) {
        panel.addMouseListener(new MouseAdapter() {
            @Override
            public void mouseClicked(MouseEvent e) {
                // Logic click section
                if (currentMaDon.isEmpty() || !lblErrorMsg.getText().contains("hợp lệ")) {
                    // Chặn nếu mã đơn chưa hợp lệ
                    return;
                }
                showVoucherPopup(type);
            }
        });
    }

    private void showVoucherPopup(String type) {
        JDialog dialog = new JDialog(this, "Chọn Voucher", true);
        dialog.setSize(550, 750);
        dialog.setLocationRelativeTo(this);
        dialog.setLayout(new BorderLayout());
        dialog.getContentPane().setBackground(BG_COLOR);

        List<VoucherDTO> list = voucherDAO.getVoucherKhaDung(currentMaDon, selectedShopCode, selectedAdminCode, selectedTransCode);
        List<VoucherDTO> filteredList = list.stream()
                .filter(v -> v.getLoaiVoucher().equalsIgnoreCase(type))
                .collect(Collectors.toList());

        JPanel pnlList = new JPanel();
        pnlList.setLayout(new BoxLayout(pnlList, BoxLayout.Y_AXIS));
        pnlList.setBackground(BG_COLOR);
        pnlList.setBorder(new EmptyBorder(15, 15, 15, 15));

        for (VoucherDTO v : filteredList) {
            JPanel card = createVoucherCard(v, type, dialog);
            pnlList.add(card);
            pnlList.add(Box.createVerticalStrut(15));
        }

        if (filteredList.isEmpty()) {
            JLabel lblEmpty = new JLabel("Không tìm thấy voucher nào");
            lblEmpty.setAlignmentX(Component.CENTER_ALIGNMENT);
            lblEmpty.setFont(new Font("Segoe UI", Font.PLAIN, 16));
            pnlList.add(lblEmpty);
        }

        dialog.add(new JScrollPane(pnlList), BorderLayout.CENTER);
        
        JButton btnNoUse = new JButton("Không sử dụng voucher loại này");
        btnNoUse.setBackground(Color.WHITE);
        btnNoUse.setForeground(TEXT_GRAY);
        btnNoUse.setPreferredSize(new Dimension(450, 50));
        btnNoUse.setFont(new Font("Segoe UI", Font.PLAIN, 14));
        btnNoUse.setFocusPainted(false);
        btnNoUse.addActionListener(e -> {
            updateSelection(type, null, "Chọn hoặc nhập mã >");
            dialog.dispose();
            reCalculate();
        });
        dialog.add(btnNoUse, BorderLayout.SOUTH);
        dialog.setVisible(true);
    }

    // --- CẬP NHẬT GIAO DIỆN THẺ VOUCHER (ĐẸP HƠN & FIX TRÀN CHỮ) ---
    private JPanel createVoucherCard(VoucherDTO v, String type, JDialog parentDialog) {
        boolean isUsable = v.isCoTheApDung();
        
        Color themeColor;
        Color bgLightColor;
        String typeLabel;
        
        if ("SHOP".equals(type)) {
            themeColor = SHOP_THEME_COLOR;
            bgLightColor = SHOP_BG_LIGHT;
            typeLabel = "Shop";
        } else if ("ADMIN".equals(type)) {
            themeColor = ADMIN_THEME_COLOR;
            bgLightColor = ADMIN_BG_LIGHT;
            typeLabel = "Hệ thống";
        } else {
            themeColor = TRANS_THEME_COLOR;
            bgLightColor = TRANS_BG_LIGHT;
            typeLabel = "Ship";
        }
        
        Color borderColor = isUsable ? themeColor : new Color(200, 200, 200);
        
        JPanel card = new JPanel(new BorderLayout(0, 0));
        card.setBackground(Color.WHITE);
        card.setBorder(new CompoundBorder(
                new LineBorder(borderColor, isUsable ? 2 : 1), 
                new EmptyBorder(0, 0, 0, 0)
        ));
        // Cho phép card cao tự động để chứa đủ nội dung
        card.setMaximumSize(new Dimension(500, isUsable ? 110 : 130)); 

        // PHẦN TRÁI: ICON
        JPanel pnlLeft = new JPanel(new GridBagLayout());
        pnlLeft.setPreferredSize(new Dimension(110, 110)); // Fixed size
        pnlLeft.setBackground(isUsable ? bgLightColor : new Color(245, 245, 245));
        
        pnlLeft.setBorder(BorderFactory.createMatteBorder(0, 0, 0, 1, new Color(220, 220, 220))); 
        
        JLabel lblType = new JLabel("<html><div style='text-align:center'>" + typeLabel + "</div></html>");
        lblType.setFont(new Font("Segoe UI", Font.BOLD, 18));
        lblType.setForeground(isUsable ? themeColor : Color.GRAY);
        pnlLeft.add(lblType);

        // PHẦN GIỮA: NỘI DUNG -> SỬ DỤNG BOX LAYOUT ĐỂ XẾP DỌC
        JPanel pnlContent = new JPanel();
        pnlContent.setLayout(new BoxLayout(pnlContent, BoxLayout.Y_AXIS));
        pnlContent.setBackground(Color.WHITE);
        pnlContent.setBorder(new EmptyBorder(10, 15, 10, 5));
        
        JLabel lblCode = new JLabel(v.getMaVoucher());
        lblCode.setFont(new Font("Segoe UI", Font.BOLD, 16));
        lblCode.setForeground(isUsable ? Color.BLACK : Color.GRAY);
        lblCode.setAlignmentX(Component.LEFT_ALIGNMENT);
        
        JLabel lblDesc = new JLabel("<html>" + v.getMoTaGiamGia() + "</html>");
        lblDesc.setFont(new Font("Segoe UI", Font.PLAIN, 14));
        lblDesc.setAlignmentX(Component.LEFT_ALIGNMENT);
        
        JLabel lblCondition = new JLabel(v.getDieuKienApDung());
        lblCondition.setFont(new Font("Segoe UI", Font.PLAIN, 12));
        lblCondition.setForeground(TEXT_GRAY);
        lblCondition.setAlignmentX(Component.LEFT_ALIGNMENT);

        pnlContent.add(lblCode);
        pnlContent.add(Box.createVerticalStrut(5));
        pnlContent.add(lblDesc);
        pnlContent.add(Box.createVerticalStrut(5));
        pnlContent.add(lblCondition);

        // NẾU KHÔNG DÙNG ĐƯỢC -> THÊM LÝ DO MÀU ĐỎ NGAY DƯỚI
        if (!isUsable) {
            pnlContent.add(Box.createVerticalStrut(8));
            JLabel lblError = new JLabel("<html>" + v.getLyDoKhongApDung() + "</html>");
            lblError.setFont(new Font("Segoe UI", Font.BOLD, 12));
            lblError.setForeground(Color.RED);
            lblError.setAlignmentX(Component.LEFT_ALIGNMENT);
            pnlContent.add(lblError);
        }

        // PHẦN PHẢI: CHỈ CHỨA RADIO HOẶC TRỐNG
        JPanel pnlRight = new JPanel(new GridBagLayout());
        pnlRight.setBackground(Color.WHITE);
        pnlRight.setPreferredSize(new Dimension(50, 110)); // Thu nhỏ lại vì ko chứa chữ nữa
        pnlRight.setBorder(new EmptyBorder(0, 0, 0, 10)); 
        
        if (isUsable) {
            JRadioButton radio = new JRadioButton();
            radio.setBackground(Color.WHITE);
            String currentSelected = "SHOP".equals(type) ? selectedShopCode : ("ADMIN".equals(type) ? selectedAdminCode : selectedTransCode);
            if (v.getMaVoucher().equals(currentSelected)) radio.setSelected(true);
            pnlRight.add(radio);
            
            card.setCursor(new Cursor(Cursor.HAND_CURSOR));
            card.addMouseListener(new MouseAdapter() {
                @Override
                public void mouseClicked(MouseEvent e) {
                    updateSelection(type, v.getMaVoucher(), "Đã chọn: " + v.getMaVoucher());
                    parentDialog.dispose();
                    reCalculate();
                }
            });
        }

        card.add(pnlLeft, BorderLayout.WEST);
        card.add(pnlContent, BorderLayout.CENTER);
        card.add(pnlRight, BorderLayout.EAST);
        return card;
    }

    private void updateSelection(String type, String code, String displayText) {
        if ("SHOP".equals(type)) {
            selectedShopCode = code;
            lblShopStatus.setText(displayText);
            lblShopStatus.setForeground(code != null ? SHOPEE_ORANGE : TEXT_GRAY);
        } else if ("ADMIN".equals(type)) {
            selectedAdminCode = code;
            lblAdminStatus.setText(displayText);
            lblAdminStatus.setForeground(code != null ? SHOPEE_ORANGE : TEXT_GRAY);
        } else if ("TRANSPORT".equals(type)) {
            selectedTransCode = code;
            lblTransStatus.setText(displayText);
            lblTransStatus.setForeground(code != null ? SHOPEE_ORANGE : TEXT_GRAY);
        }
    }

    private void reCalculate() {
        if (currentMaDon.isEmpty()) return;

        new SwingWorker<ReceiptDTO, Void>() {
            @Override
            protected ReceiptDTO doInBackground() throws Exception {
                return voucherDAO.getReceiptDetails(currentMaDon, selectedShopCode, selectedAdminCode, selectedTransCode);
            }

            @Override
            protected void done() {
                try {
                    ReceiptDTO r = get();
                    if (r != null) {
                        // LOGIC MỚI: KIỂM TRA VÀ RESET VOUCHER VI PHẠM
                        checkAndResetVouchers(r);
                        
                        updatePaymentDetails(r);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }.execute();
    }

    // --- LOGIC: TỰ ĐỘNG RESET VOUCHER NẾU KHÔNG CÒN HIỆU LỰC (GIẢM GIÁ = 0) ---
    private void checkAndResetVouchers(ReceiptDTO r) {
        boolean changed = false;
        StringBuilder msg = new StringBuilder();

        // 1. Check Voucher Shop
        if (selectedShopCode != null && r.getGiamGiaShop().compareTo(java.math.BigDecimal.ZERO) == 0) {
            msg.append("- Voucher Shop ").append(selectedShopCode).append(" không còn hợp lệ.\n");
            selectedShopCode = null;
            lblShopStatus.setText("Chọn hoặc nhập mã >");
            lblShopStatus.setForeground(TEXT_GRAY);
            changed = true;
        }

        // 2. Check Voucher Admin (Hệ thống)
        if (selectedAdminCode != null && r.getGiamGiaAdmin().compareTo(java.math.BigDecimal.ZERO) == 0) {
            msg.append("- Voucher Hệ thống ").append(selectedAdminCode).append(" không đủ điều kiện.\n");
            selectedAdminCode = null;
            lblAdminStatus.setText("Chọn hoặc nhập mã >");
            lblAdminStatus.setForeground(TEXT_GRAY);
            changed = true;
        }

        // 3. Check Voucher Vận chuyển
        if (selectedTransCode != null && r.getGiamGiaShip().compareTo(java.math.BigDecimal.ZERO) == 0) {
            msg.append("- Mã Freeship ").append(selectedTransCode).append(" không đủ điều kiện.\n");
            selectedTransCode = null;
            lblTransStatus.setText("Chọn hoặc nhập mã >");
            lblTransStatus.setForeground(TEXT_GRAY);
            changed = true;
        }

        if (changed) {
            JOptionPane.showMessageDialog(this, 
                "Một số voucher đã bị hủy do thay đổi giá trị đơn hàng:\n" + msg.toString(),
                "Thông báo thay đổi", JOptionPane.WARNING_MESSAGE);
        }
    }

   private void updatePaymentDetails(ReceiptDTO r) {
        NumberFormat vnCurrency = NumberFormat.getCurrencyInstance(Locale.forLanguageTag("vi-VN"));

        // 1. Hiển thị Giá Niêm Yết
        lblValGiaNiemYet.setText(vnCurrency.format(r.getGiaNiemYet() != null ? r.getGiaNiemYet() : BigDecimal.ZERO));
        
        // 2. Hiển thị Chiết Khấu (Màu cam, có dấu trừ)
        if (r.getTienChietKhau() != null && r.getTienChietKhau().compareTo(BigDecimal.ZERO) > 0) {
             lblValChietKhau.setText("- " + vnCurrency.format(r.getTienChietKhau()));
             lblValChietKhau.setForeground(SHOPEE_ORANGE);
        } else {
             lblValChietKhau.setText("0 đ");
             lblValChietKhau.setForeground(Color.BLACK);
        }

        // 3. Các thông số cũ
        lblValTienHang.setText(vnCurrency.format(r.getGiaGoc())); // Đây là giá sau khi trừ chiết khấu
        lblValPhiShip.setText(vnCurrency.format(r.getPhiVanChuyen()));
        
        lblValGiamShop.setText(r.getGiamGiaShop().intValue() > 0 ? "- " + vnCurrency.format(r.getGiamGiaShop()) : "0 đ");
        lblValGiamAdmin.setText(r.getGiamGiaAdmin().intValue() > 0 ? "- " + vnCurrency.format(r.getGiamGiaAdmin()) : "0 đ");
        lblValGiamShip.setText(r.getGiamGiaShip().intValue() > 0 ? "- " + vnCurrency.format(r.getGiamGiaShip()) : "0 đ");

        lblValGiamShop.setForeground(r.getGiamGiaShop().intValue() > 0 ? SHOPEE_ORANGE : Color.BLACK);
        lblValGiamAdmin.setForeground(r.getGiamGiaAdmin().intValue() > 0 ? SHOPEE_ORANGE : Color.BLACK);
        lblValGiamShip.setForeground(r.getGiamGiaShip().intValue() > 0 ? SHOPEE_ORANGE : Color.BLACK);

        lblTongThanhToan.setText(vnCurrency.format(r.getTongThanhToan()));
    }
    public static void main(String[] args) {
        try {
            // Kích hoạt FlatLaf (Giao diện phẳng hiện đại)
            UIManager.setLookAndFeel(new com.formdev.flatlaf.FlatLightLaf());
        } catch (Exception e) {
            e.printStackTrace();
        }
        SwingUtilities.invokeLater(() -> new VoucherView().setVisible(true));
    }
}