@echo off
cd /d "%~dp0"
echo ==========================================
echo   CHAY TRUC TIEP THONGKEVIEW
echo ==========================================
echo.

java -cp "target/classes;%USERPROFILE%\.m2\repository\com\microsoft\sqlserver\mssql-jdbc\12.4.2.jre11\mssql-jdbc-12.4.2.jre11.jar" ^
  org.example.view.ThongKeView

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Khong the chay!
    echo.
    echo Giai phap: Mo IntelliJ IDEA
    echo 1. Open project DatabaseDemoApp
    echo 2. Right-click ThongKeView.java
    echo 3. Run ThongKeView.main()
    pause
)
