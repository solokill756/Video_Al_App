#!/bin/bash

# Quick Start Script - Chạy Appium Tests
# Hướng dẫn: chmod +x quick_start.sh && ./quick_start.sh

echo "🚀 Video AI - Appium E2E Test Quick Start"
echo "=========================================="
echo ""

# Check if Appium is running
echo "📝 Bước 1: Kiểm tra Appium server..."
if curl -s http://127.0.0.1:4723/status > /dev/null 2>&1; then
    echo "✅ Appium server đang chạy"
else
    echo "❌ Appium server CHƯA chạy!"
    echo ""
    echo "👉 Vui lòng mở terminal mới và chạy:"
    echo "   appium"
    echo ""
    echo "Sau đó chạy lại script này."
    exit 1
fi

# Check device
echo ""
echo "📝 Bước 2: Kiểm tra thiết bị Android..."
DEVICES=$(adb devices | grep -v "List" | grep device | wc -l)
if [ "$DEVICES" -gt 0 ]; then
    echo "✅ Tìm thấy $DEVICES thiết bị"
    adb devices
else
    echo "❌ Không tìm thấy thiết bị Android!"
    echo ""
    echo "👉 Vui lòng:"
    echo "   1. Kết nối thiết bị hoặc khởi động emulator"
    echo "   2. Bật USB debugging"
    echo "   3. Chạy: adb devices"
    exit 1
fi

# Activate venv
echo ""
echo "📝 Bước 3: Kích hoạt Python virtual environment..."
cd /home/thao/Video_Al_App/appium_test
if [ -d "venv" ]; then
    source venv/bin/activate
    echo "✅ Virtual environment đã kích hoạt"
else
    echo "❌ Virtual environment không tồn tại!"
    echo ""
    echo "👉 Tạo venv bằng lệnh:"
    echo "   python3 -m venv venv"
    echo "   source venv/bin/activate"
    echo "   pip3 install -r requirements.txt"
    exit 1
fi

# Menu
echo ""
echo "=========================================="
echo "🧪 CHỌN TEST MUỐN CHẠY:"
echo "=========================================="
echo "1. Chạy TẤT CẢ tests (17 tests - ~20 phút)"
echo "2. Chạy CHỈ Login tests (8 tests - ~10 phút)"
echo "3. Chạy CHỈ Register tests (9 tests - ~10 phút)"
echo "4. Thoát"
echo ""
read -p "Nhập lựa chọn (1-4): " choice

cd test_cases

case $choice in
    1)
        echo ""
        echo "🚀 Chạy TẤT CẢ tests..."
        python3 run_all_tests.py
        ;;
    2)
        echo ""
        echo "🚀 Chạy Login tests..."
        python3 test_login.py
        ;;
    3)
        echo ""
        echo "🚀 Chạy Register tests..."
        python3 test_register.py
        ;;
    4)
        echo "👋 Thoát!"
        exit 0
        ;;
    *)
        echo "❌ Lựa chọn không hợp lệ!"
        exit 1
        ;;
esac

echo ""
echo "=========================================="
echo "✅ HOÀN TẤT!"
echo "=========================================="
echo ""
echo "📸 Screenshots (nếu có test fail): test_cases/screenshots/"
echo ""
