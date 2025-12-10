@echo off
echo ====================================
echo      TEST GIAO DIEN THONG KE 2.3
echo ====================================
echo.

cd /d "%~dp0"

echo [1/2] Compiling source files...
javac -encoding UTF-8 -cp "target/classes" ^
  src/main/java/org/example/model/SanPhamBanChay.java ^
  src/main/java/org/example/model/TopKhachHang.java ^
  src/main/java/org/example/dao/ThongKeDAO.java ^
  src/main/java/org/example/view/ThongKeView.java ^
  -d target/classes

if %errorlevel% neq 0 (
    echo [ERROR] Compilation failed!
    pause
    exit /b 1
)

echo [2/2] Running ThongKeView...
echo.
echo ==== INSTRUCTIONS ====
echo 1. Tab "San Pham Ban Chay": Test thu tuc sp_ThongKeSanPhamBanChay
echo 2. Tab "Top Khach Hang VIP": Test thu tuc sp_ThongKeTopKhachHang  
echo 3. Co cac nut THEM/SUA/XOA san pham (yeu cau 2.3)
echo ======================
echo.

java -cp "target/classes" org.example.view.ThongKeView

pause
