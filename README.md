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



## Package *dao* (Data Access Object)
* **Nhiệm vụ:**  Là cầu nối giữa Java và SQL Server. Mọi câu lệnh SQL (SELECT, INSERT, UPDATE, DELETE) đều phải nằm ở đây.
* **Cách hoạt động:**
  Mở kết nối từ database.
  Thực hiện truy vấn thông qua *query*.
  Đóng gói data vào file tương ứng trong package **model** và trả về.
  
* **Ví dụ:** *SanPhamDAO.java* chứa hàm **layDanhSachSanPham()** để lấy dữ liệu từ bảng **SAN_PHAM**, được truyền câu lệnh truy vấn *query* là **SELECT * FROM SAN_PHAM**, trả về List các đối tượng **SanPham**.

## Package *database* (Database Configuration)
* **Nhiệm vụ:** Quản lý việc kết nối đến SQL Server.
* **Class chính:** DatabaseConnection.java.
* **Lưu ý:** Chứa thông tin URL, Username, Password. Vào đây sửa mật khẩu sa cho đúng với máy cá nhân của mình.

```
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
```

## Package *model* (Data model)
* **Nhiệm vụ:**  Chứa các class mô tả dữ liệu, ánh xạ trực tiếp 1-1 với các bảng trong SQL Server.
* **Ví dụ:*** Class *SanPham.java* tương ứng với bảng **SAN_PHAM.**
* **Lưu ý:**  Chỉ chứa thuộc tính *(properties), Constructor, Getter/Setter*. Không viết code xử lý logic hay giao diện ở đây.


## Package *view* (UI)
* **Nhiệm vụ:** Chứa mã nguồn giao diện người dùng (Java Swing).
* **Nhiệm vụ team 1:** Code các *JFrame, JPanel, JTable* tại đây.
* **Quy tắc:** Giao diện **KHÔNG** được gọi trực tiếp SQL. Muốn lấy dữ liệu, View phải gọi thông qua **DAO**.

# Hướng dẫn kết nối Database

### Chạy hàm main trong src/main/java/org/example/Main.java để test thử kết nối tới database. 
<img width="1502" height="573" alt="image" src="https://github.com/user-attachments/assets/181d4944-638b-4bd7-9fb7-9314fe4cb61b" />


### Kết nối thành công 
<img width="1918" height="362" alt="image" src="https://github.com/user-attachments/assets/c92383d1-1fd9-471a-8c2e-901f52c0346e" />


### Hiện lỗi như vầy là cấu hình kết nối thông qua TCP/IP tới SQL Server trên máy chưa thành công.
<img width="1918" height="700" alt="image" src="https://github.com/user-attachments/assets/5f3bf89b-a971-48d3-8f6f-d2fd971d90dd" />


### Gõ chọn compmgmt.msc để mở cấu hình các service 
<img width="448" height="260" alt="image" src="https://github.com/user-attachments/assets/f8f5080b-fcd8-474a-abc5-1f3208ab99ba" />

### Bước 1:

<img width="1226" height="876" alt="image" src="https://github.com/user-attachments/assets/29cd1539-4a15-4d9e-abd8-b62d662fa1e5" />

### Bước 2:
<img width="1220" height="876" alt="image" src="https://github.com/user-attachments/assets/ca9dea48-f662-4891-90a8-f846e7db1214" />

### Bước 3:
* Nếu trong VS Code để **Server name** mặc định là **localhost** thì service đang chạy là **MSSQLSERVER**.
* Chỉ để duy nhất service của nó chạy để tránh xung đột giữa các port.  
<img width="1091" height="556" alt="image" src="https://github.com/user-attachments/assets/64c01ab9-ad3c-4b9d-84f0-eb60386eb4aa" />

### Bước 4:
* Vào mục **SQL Server Network Configuration** phía bên trái.
* Chọn **Protocols for MSSQLSERVER**.
<img width="1222" height="875" alt="image" src="https://github.com/user-attachments/assets/76e1ec5a-6de6-46ba-8577-e32952ddad0d" />

### Bước 5:
* Ban đầu nó đang để *Disable*,
* Chuột phải vào **TCP/IP** chọn *Enable*.
<img width="1227" height="878" alt="image" src="https://github.com/user-attachments/assets/3b742682-338c-4e1f-bcc5-1b88a954a6ab" />

### Bước 6:
* Xong vào **Properties** để cấu hình Port.
<img width="527" height="181" alt="image" src="https://github.com/user-attachments/assets/f7796ae6-4ddf-45af-b9a9-a102d7e2bd94" />

### Bước 7:
* Sang tab **IP Addresses**.
* Ban đầu chỗ **TCP Dynamic Port** có số 0 thì xóa nó đi.
* Nhập vào ô **TCP Port** giá trị *1433* (Hoặc tùy tụi m muốn config cổng nào cũng được).
<img width="677" height="715" alt="image" src="https://github.com/user-attachments/assets/a7cbf5a4-4124-4f22-bc8c-36c3a2089a5f" />


### Bước 8:

* Ra **SQL Server Serives** để *Restart* lại.
* Xong rồi chạy lại hàm **main** phía trên kia.
<img width="1013" height="855" alt="image" src="https://github.com/user-attachments/assets/0b1680e5-6f9f-46f7-bfd8-e2383dfc97ba" />

## Chạy thử tính năng
* Muốn chạy 1 tính năng liên quan đến bảng nào đó, ví dụ bảng **SAN_PHAM** trong file *.sql*, thì vào trong **src/main/java/org/example/view/SanPhamView.java** rồi chạy hàm *main* trong đó, mọi thay đổi trong file *.sql* sẽ được cập nhật trong **model/SanPham.java**, rồi lúc demo sẽ hiện rõ thay đổi trên UI.
* Ở đây tớ có thêm 1 hàng vào trong bảng **SAN_PHAM**.
* Chạy trong **view** thì nó cập nhật ra nhé.
<img width="1272" height="277" alt="image" src="https://github.com/user-attachments/assets/3fdfd493-8d9d-4fb5-b918-39f92d88e6b9" />

<img width="1645" height="933" alt="image" src="https://github.com/user-attachments/assets/c28419c3-ca1b-4c00-826b-2ef40670f9e3" />








