package org.example.database;

import java.sql.Connection;
import java.sql.DriverManager;

public class DatabaseConnection {
    public static Connection getConnection() {
        String dbURL = "jdbc:sqlserver://localhost:1433;databaseName=HeThongBanHang;encrypt=true;trustServerCertificate=true;";
        String dbUser = "sa";
        String dbPassword = "12345678";

        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
            System.out.println("Ket noi database thanh cong"); // In ra để biết là OK
            return conn;
        } catch (Exception ex) {
            System.out.println("Ket noi that bai: " + ex.getMessage());
            ex.printStackTrace();
        }
        return null;
    }
}