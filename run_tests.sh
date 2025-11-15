#!/bin/bash
# ✅ Patrol Tests Setup & Run Script
# =================================

echo "🚀 PATROL E2E TESTS - SETUP & RUN"
echo "=================================="
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check 1: Patrol CLI
echo -e "${BLUE}[1/5]${NC} Checking Patrol CLI..."
if command -v patrol &> /dev/null
then
    PATROL_VERSION=$(patrol --version 2>&1 | grep -oP 'v\K[\d.]+' || echo "unknown")
    echo -e "${GREEN}✅ Patrol CLI installed (version: $PATROL_VERSION)${NC}"
else
    echo -e "${YELLOW}⚠️  Patrol CLI not found in PATH${NC}"
    echo "Setting up PATH..."
    export PATH="$PATH":"$HOME/.pub-cache/bin"
    if command -v patrol &> /dev/null; then
        echo -e "${GREEN}✅ Patrol CLI now available${NC}"
    else
        echo "❌ Failed to setup Patrol CLI"
        exit 1
    fi
fi

# Check 2: Flutter
echo ""
echo -e "${BLUE}[2/5]${NC} Checking Flutter..."
if command -v flutter &> /dev/null
then
    FLUTTER_VERSION=$(flutter --version | grep -oP 'Flutter \K[\d.]+' || echo "unknown")
    echo -e "${GREEN}✅ Flutter installed (version: $FLUTTER_VERSION)${NC}"
else
    echo "❌ Flutter not found"
    exit 1
fi

# Check 3: Android Device
echo ""
echo -e "${BLUE}[3/5]${NC} Checking Android devices..."
DEVICES=$(flutter devices 2>/dev/null | grep -c "android")
if [ "$DEVICES" -gt 0 ]
then
    echo -e "${GREEN}✅ Android device(s) found${NC}"
    flutter devices | grep android
else
    echo -e "${YELLOW}⚠️  No Android devices found${NC}"
    echo "Please connect an Android device or start an emulator"
fi

# Check 4: Dependencies
echo ""
echo -e "${BLUE}[4/5]${NC} Checking dependencies..."
if grep -q "patrol:" pubspec.yaml
then
    echo -e "${GREEN}✅ Patrol dependency exists${NC}"
else
    echo -e "${YELLOW}⚠️  Patrol dependency not in pubspec.yaml${NC}"
fi

# Check 5: Test Files
echo ""
echo -e "${BLUE}[5/5]${NC} Checking test files..."
TEST_COUNT=$(find test_driver -name "*_test.dart" -type f 2>/dev/null | wc -l)
if [ "$TEST_COUNT" -gt 0 ]
then
    echo -e "${GREEN}✅ Found $TEST_COUNT test files${NC}"
    ls -1 test_driver/*_test.dart 2>/dev/null | sed 's/^/   - /'
else
    echo "❌ No test files found"
    exit 1
fi

# Summary
echo ""
echo "=================================="
echo -e "${GREEN}✅ ALL CHECKS PASSED!${NC}"
echo "=================================="
echo ""

# Ask to run tests
read -p "Would you like to run tests now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo ""
    echo -e "${BLUE}Running Patrol tests...${NC}"
    echo ""
    patrol test --target android
else
    echo ""
    echo "To run tests later, use:"
    echo "  patrol test --target android"
    echo ""
fi
