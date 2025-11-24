# Cấu trúc dự án 
```
├── pom.xml
├── src
│   ├── main
│   │   ├── java
│   │   │   └── org
│   │   │       └── example
│   │   │           ├── Main.java
│   │   │           ├── dao           # Chứa các hàm xử lý SQL (CRUD)
│   │   │           ├── database      # Cấu hình kết nối tới cơ sở dữ liệu
│   │   │           ├── model         # Chứa các đối tượng xử lý dữ liệu (POJO)
│   │   │           └── view          # Chứa giao diện người dùng (GUI )
│   │   └── resources
│   └── test
│       └── java
...
```
## Package model (Data model)

## Package database (Database Configuration)

## Package dao (Data Access Object)

## Package view (UI)

# Hướng dẫn kết nối Database

### Chạy hàm main trong src/main/java/org/example/Main.java để test thử kết nối tới database. 
<img width="1918" height="757" alt="image" src="https://github.com/user-attachments/assets/b31fc2f4-d266-4df8-99a2-1aea2af18b63" />
 
### Kết nối thành công 
 <img width="1918" height="667" alt="image" src="https://github.com/user-attachments/assets/56870823-18bb-4916-a543-3161ae24e4c2" />

### Hiện lỗi như vầy là cấu hình kết nối thông qua TCP/IP tới SQL Server trên máy chưa thành công.
<img width="1918" height="968" alt="image" src="https://github.com/user-attachments/assets/38d54948-7a8b-4c89-b451-3ff655dd8216" />

### Gõ chọn compmgmt.msc để mở cấu hình các service 
<img width="448" height="260" alt="image" src="https://github.com/user-attachments/assets/f8f5080b-fcd8-474a-abc5-1f3208ab99ba" />

### Bước 1:

<img width="1226" height="876" alt="image" src="https://github.com/user-attachments/assets/29cd1539-4a15-4d9e-abd8-b62d662fa1e5" />

### Bước 2:
<img width="1220" height="876" alt="image" src="https://github.com/user-attachments/assets/ca9dea48-f662-4891-90a8-f846e7db1214" />

### Bước 3:
* Nếu trong VS Code để **Server name** mặc định là **localhost** thì service đang chạy là **MSSQLSERVER**
* Chỉ để duy nhất service của nó chạy để tránh xung đột giữa các port.  
<img width="1091" height="556" alt="image" src="https://github.com/user-attachments/assets/64c01ab9-ad3c-4b9d-84f0-eb60386eb4aa" />




