# Cấu trúc dự án 
```
├── pom.xml
├── src
│   ├── main
│   │   ├── java
│   │   │   └── org
│   │   │       └── example
│   │   │           ├── Main.java
│   │   │           ├── dao
│   │   │           │   └── SanPhamDAO.java
│   │   │           ├── database
│   │   │           │   └── DatabaseConnection.java
│   │   │           ├── model
│   │   │           │   └── SanPham.java
│   │   │           └── view
│   │   │               └── SanPhamView.java
│   │   └── resources
│   └──
...
```


# Hướng dẫn kết nối Database
<img width="1918" height="757" alt="image" src="https://github.com/user-attachments/assets/b31fc2f4-d266-4df8-99a2-1aea2af18b63" />
Chạy hàm **main** trong **src/main/java/org/example/Main.java** để test thử kết nối tới database. 

<img width="1918" height="968" alt="image" src="https://github.com/user-attachments/assets/38d54948-7a8b-4c89-b451-3ff655dd8216" />
Hiện lỗi như vầy là cấu hình kết nối thông qua TCP/IP tới SQL Server trên máy chưa thành công.

