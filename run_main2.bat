@echo off
cd /d "%~dp0"
echo ==========================================
echo   CHAY GIAO DIEN MENU CHINH
echo ==========================================
echo.
echo Dang compile va chay...
echo.

REM Xoa file class cu
if exist "target\classes\org\example\Main2.class" del /Q "target\classes\org\example\Main2.class"
if exist "target\classes\org\example\view\ThongKeView.class" del /Q "target\classes\org\example\view\ThongKeView.class"

REM Compile bang javac voi encoding UTF-8
javac -encoding UTF-8 -source 11 -target 11 ^
  -cp "target/classes;%USERPROFILE%\.m2\repository\com\microsoft\sqlserver\mssql-jdbc\12.4.2.jre11\mssql-jdbc-12.4.2.jre11.jar;%USERPROFILE%\.m2\repository\com\formdev\flatlaf\3.5.1\flatlaf-3.5.1.jar" ^
  -d target/classes ^
  src/main/java/org/example/Main2.java ^
  src/main/java/org/example/view/ThongKeView.java ^
  src/main/java/org/example/dao/ThongKeDAO.java ^
  src/main/java/org/example/model/SanPhamBanChay.java ^
  src/main/java/org/example/model/TopKhachHang.java

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Compile that bai!
    echo Hay mo project trong IntelliJ IDEA roi chay tu do.
    pause
    exit /b 1
)

REM Chay ung dung
java -cp "target/classes;%USERPROFILE%\.m2\repository\com\microsoft\sqlserver\mssql-jdbc\12.4.2.jre11\mssql-jdbc-12.4.2.jre11.jar;%USERPROFILE%\.m2\repository\com\formdev\flatlaf\3.5.1\flatlaf-3.5.1.jar" ^
  org.example.Main2

pause
