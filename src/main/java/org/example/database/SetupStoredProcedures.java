package org.example.database;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.Statement;

public class SetupStoredProcedures {
    public static void main(String[] args) {
        try {
            // Đọc file SQL từ resources
            InputStream is = SetupStoredProcedures.class.getResourceAsStream("/StoredProcedures.sql");
            if (is == null) {
                System.out.println(" Không tìm thấy file StoredProcedures.sql trong resources!");
                return;
            }

            BufferedReader reader = new BufferedReader(new InputStreamReader(is, "UTF-8"));
            StringBuilder sqlContent = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                sqlContent.append(line).append("\n");
            }
            reader.close();

            // Kết nối và chạy từng stored procedure
            Connection conn = DatabaseConnection.getConnection();
            Statement stmt = conn.createStatement();

            // Tách các thủ tục bằng GO (SQL Server batch separator)
            String[] procedures = sqlContent.toString().split("GO");

            System.out.println(" Bắt đầu tạo Stored Procedures...\n");
            int count = 0;
            for (String procedure : procedures) {
                String trimmed = procedure.trim();
                if (!trimmed.isEmpty()) {
                    try {
                        stmt.execute(trimmed);
                        count++;
                        System.out.println(" Đã tạo thủ tục #" + count);
                    } catch (Exception e) {
                        System.out.println(" Lỗi tại thủ tục #" + (count + 1) + ": " + e.getMessage());
                    }
                }
            }

            stmt.close();
            conn.close();
            System.out.println("\n Hoàn thành! Đã tạo " + count + " stored procedures.");

        } catch (Exception e) {
            e.printStackTrace();
            System.out.println(" Lỗi: " + e.getMessage());
        }
    }
}
