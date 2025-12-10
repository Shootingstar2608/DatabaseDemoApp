package org.example;

import org.example.view.QuanLySanPhamCRUD;
import org.example.view.QuanLySanPhamView;
import org.example.view.ThongKeView;
import javax.swing.*;
import java.awt.*;

public class Main2 {
    public static void main(String[] args) {
        try {
            // Áp dụng giao diện FlatLaf
            UIManager.setLookAndFeel(new com.formdev.flatlaf.FlatLightLaf());
            UIManager.put("Button.arc", 100);
            UIManager.put("Component.arc", 100);
            UIManager.put("TextComponent.arc", 100);
        } catch (Exception e) {
            e.printStackTrace();
        }

        SwingUtilities.invokeLater(() -> showMenu());
    }

    private static void showMenu() {
        // Tạo menu chọn giao diện
        JFrame menuFrame = new JFrame("Menu Chính - Quản Lý Sản Phẩm");
        menuFrame.setSize(500, 400);
        menuFrame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        menuFrame.setLocationRelativeTo(null);
        menuFrame.setLayout(new GridLayout(4, 1, 10, 10));

        JLabel lblTitle = new JLabel("CHỌN GIAO DIỆN", JLabel.CENTER);
        lblTitle.setFont(new Font("Segoe UI", Font.BOLD, 24));
        lblTitle.setForeground(new Color(0, 51, 102));

        JButton btnTimKiem = new JButton("Giao Diện Tìm Kiếm Sản Phẩm");
        btnTimKiem.setFont(new Font("Segoe UI", Font.BOLD, 16));
        btnTimKiem.setBackground(new Color(52, 152, 219));
        btnTimKiem.setForeground(Color.WHITE);
        btnTimKiem.setFocusPainted(false);
        btnTimKiem.setCursor(new Cursor(Cursor.HAND_CURSOR));

        JButton btnCRUD = new JButton("Giao Diện Thêm/Sửa/Xóa (CRUD)");
        btnCRUD.setFont(new Font("Segoe UI", Font.BOLD, 16));
        btnCRUD.setBackground(new Color(46, 204, 113));
        btnCRUD.setForeground(Color.WHITE);
        btnCRUD.setFocusPainted(false);
        btnCRUD.setCursor(new Cursor(Cursor.HAND_CURSOR));

        JButton btnThongKe = new JButton(" Thống Kê & Báo Cáo ");
        btnThongKe.setFont(new Font("Segoe UI", Font.BOLD, 16));
        btnThongKe.setBackground(new Color(155, 89, 182));
        btnThongKe.setForeground(Color.WHITE);
        btnThongKe.setFocusPainted(false);
        btnThongKe.setCursor(new Cursor(Cursor.HAND_CURSOR));

        btnTimKiem.addActionListener(e -> {
            QuanLySanPhamView view = new QuanLySanPhamView();
            view.setOnBackToMenu(() -> showMenu());
            view.setVisible(true);
            menuFrame.dispose();
        });

        btnCRUD.addActionListener(e -> {
            QuanLySanPhamCRUD crud = new QuanLySanPhamCRUD();
            crud.setOnBackToMenu(() -> showMenu());
            crud.setVisible(true);
            menuFrame.dispose();
        });

        btnThongKe.addActionListener(e -> {
            try {
                System.out.println("Đang mở ThongKeView...");
                menuFrame.dispose();
                ThongKeView thongKe = new ThongKeView();
                thongKe.setOnBackToMenu(() -> {
                    System.out.println("Quay lại menu từ ThongKeView...");
                    SwingUtilities.invokeLater(() -> showMenu());
                });
                thongKe.setVisible(true);
            } catch (Exception ex) {
                ex.printStackTrace();
                JOptionPane.showMessageDialog(menuFrame,
                        "Lỗi khi mở giao diện Thống Kê:\n" + ex.getMessage(),
                        "Lỗi",
                        JOptionPane.ERROR_MESSAGE);
            }
        });

        menuFrame.add(lblTitle);
        menuFrame.add(btnTimKiem);
        menuFrame.add(btnCRUD);
        menuFrame.add(btnThongKe);
        menuFrame.setVisible(true);
    }
}