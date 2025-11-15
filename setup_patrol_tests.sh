#!/bin/bash

# Script để chạy Patrol E2E tests

echo "🚀 Bắt đầu cài đặt Patrol E2E Tests"
echo "=================================="

# Kiểm tra xem Patrol CLI đã được cài đặt
if ! command -v patrol &> /dev/null
then
    echo "❌ Patrol CLI chưa được cài đặt"
    echo "📦 Đang cài đặt Patrol CLI..."
    dart pub global activate patrol_cli
    echo "✅ Patrol CLI đã được cài đặt"
else
    echo "✅ Patrol CLI đã có sẵn"
fi

# Cài đặt dependencies
echo ""
echo "📥 Cài đặt dependencies..."
flutter pub get

echo ""
echo "✨ Cài đặt hoàn tất!"
echo ""
echo "📝 Lệnh để chạy tests:"
echo ""
echo "  Android:"
echo "    patrol test --target android"
echo "    patrol test -t test_driver/login_test.dart --target android"
echo "    patrol test -t test_driver/register_test.dart --target android"
echo ""
echo "  iOS:"
echo "    patrol test --target ios"
echo ""
echo "💡 Để chi tiết hơn, xem: test_driver/README.md"
