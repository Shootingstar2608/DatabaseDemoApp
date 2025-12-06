package org.example.view;

import org.example.dao.SanPhamDAO;
import org.example.model.SanPham;

import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import java.awt.*;
import java.util.List;

public class SanPhamView extends JFrame {
    private JTable table;
    private DefaultTableModel tableModel;
    private SanPhamDAO sanPhamDAO;

    public SanPhamView() {
        sanPhamDAO = new SanPhamDAO();
        initUI();
        loadData();
    }

    private void initUI() {
        setTitle("Quản Lý Sản Phẩm ");
        setSize(900, 500); // Kéo to form ra chút vì nhiều cột
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null);

        String[] columnNames = {
                "Mã SP",
                "Tên Sản Phẩm",
                "Giá Bán",
                "Loại Hàng",
                "Mã Shop"
        };

        tableModel = new DefaultTableModel(columnNames, 0);
        table = new JTable(tableModel);

        table.getColumnModel().getColumn(1).setPreferredWidth(200); // Cột Tên to hơn chút

        JScrollPane scrollPane = new JScrollPane(table);
        add(scrollPane, BorderLayout.CENTER);

        JPanel buttonPanel = new JPanel();
        JButton btnReload = new JButton("Tải lại danh sách");
        btnReload.addActionListener(e -> loadData());
        buttonPanel.add(btnReload);

        // NÚT MỚI: Xem lịch sử thay đổi (AUDIT)
        JButton btnAudit = new JButton("📋 Xem lịch sử thay đổi");
        btnAudit.setForeground(new Color(0, 102, 204));
        btnAudit.addActionListener(e -> {
            AuditSanPhamView auditView = new AuditSanPhamView();
            auditView.setVisible(true);
        });
        buttonPanel.add(btnAudit);

        add(buttonPanel, BorderLayout.SOUTH);
    }

    private void loadData() {
        tableModel.setRowCount(0); // Xóa dữ liệu cũ
        List<SanPham> list = sanPhamDAO.layDanhSachSanPham();

        for (SanPham sp : list) {
            Object[] row = {
                    sp.getMaSanPham(),
                    sp.getTenSanPham(),
                    String.format("%,.0f VNĐ", sp.getGiaHienThi()),
                    sp.getLoai(),
                    sp.getMaSoShop()
            };
            tableModel.addRow(row);
        }
    }

    public static void main(String[] args) {
        try {
            UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
        } catch (Exception e) {
            e.printStackTrace();
        }

        SwingUtilities.invokeLater(() -> {
            new SanPhamView().setVisible(true);
        });
    }
}