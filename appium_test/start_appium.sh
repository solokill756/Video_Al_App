#!/bin/bash
# Script to start Appium server with Android environment variables

export ANDROID_HOME="/usr/lib/android-sdk"
export ANDROID_SDK_ROOT="/usr/lib/android-sdk"
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools"

echo "========================================"
echo "🚀 Starting Appium Server"
echo "========================================"
echo "ANDROID_HOME: $ANDROID_HOME"
echo "ANDROID_SDK_ROOT: $ANDROID_SDK_ROOT"
echo "========================================"
echo ""

appium
