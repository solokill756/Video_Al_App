#!/bin/bash

# Script to run Appium E2E Tests
# Author: VideoAI Team
# Description: Automated script to setup and run Appium tests

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE}    VideoAI - Appium E2E Test Runner${NC}"
echo -e "${BLUE}==================================================${NC}\n"

# Check if Appium server is running
check_appium_server() {
    echo -e "${YELLOW}Checking Appium server...${NC}"
    if curl -s http://127.0.0.1:4723/status > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Appium server is running${NC}\n"
        return 0
    else
        echo -e "${RED}✗ Appium server is not running${NC}"
        echo -e "${YELLOW}Please start Appium server: appium${NC}\n"
        return 1
    fi
}

# Check if ADB is available
check_adb() {
    echo -e "${YELLOW}Checking ADB...${NC}"
    if command -v adb &> /dev/null; then
        echo -e "${GREEN}✓ ADB is installed${NC}"
        
        # Check for connected devices
        DEVICES=$(adb devices | grep -v "List" | grep -v "^$" | wc -l)
        if [ "$DEVICES" -gt 0 ]; then
            echo -e "${GREEN}✓ Found $DEVICES connected device(s)${NC}\n"
            adb devices
            echo ""
            return 0
        else
            echo -e "${RED}✗ No devices connected${NC}"
            echo -e "${YELLOW}Please connect a device or start an emulator${NC}\n"
            return 1
        fi
    else
        echo -e "${RED}✗ ADB is not installed${NC}\n"
        return 1
    fi
}

# Check Python dependencies
check_python_deps() {
    echo -e "${YELLOW}Checking Python dependencies...${NC}"
    if python3 -c "import appium" 2>/dev/null; then
        echo -e "${GREEN}✓ Python dependencies are installed${NC}\n"
        return 0
    else
        echo -e "${RED}✗ Python dependencies are missing${NC}"
        echo -e "${YELLOW}Installing dependencies...${NC}"
        pip3 install -r appium_test/requirements.txt
        echo -e "${GREEN}✓ Dependencies installed${NC}\n"
        return 0
    fi
}

# Build Flutter app
build_app() {
    echo -e "${YELLOW}Building Flutter app...${NC}"
    if flutter build apk --debug; then
        echo -e "${GREEN}✓ App built successfully${NC}\n"
        return 0
    else
        echo -e "${RED}✗ Failed to build app${NC}\n"
        return 1
    fi
}

# Run tests
run_tests() {
    local test_file=$1
    
    echo -e "${BLUE}==================================================${NC}"
    echo -e "${BLUE}Running Tests: $test_file${NC}"
    echo -e "${BLUE}==================================================${NC}\n"
    
    cd appium_test/test_cases
    
    # Create screenshots directory
    mkdir -p screenshots
    
    if python3 "$test_file"; then
        echo -e "\n${GREEN}==================================================${NC}"
        echo -e "${GREEN}✓ All tests passed!${NC}"
        echo -e "${GREEN}==================================================${NC}\n"
        return 0
    else
        echo -e "\n${RED}==================================================${NC}"
        echo -e "${RED}✗ Some tests failed${NC}"
        echo -e "${RED}Check screenshots in: appium_test/test_cases/screenshots/${NC}"
        echo -e "${RED}==================================================${NC}\n"
        return 1
    fi
}

# Main menu
show_menu() {
    echo -e "${BLUE}Select test to run:${NC}"
    echo -e "  ${GREEN}1)${NC} Run All Tests"
    echo -e "  ${GREEN}2)${NC} Run Login Tests Only"
    echo -e "  ${GREEN}3)${NC} Run Register Tests Only"
    echo -e "  ${GREEN}4)${NC} Build App Only"
    echo -e "  ${GREEN}5)${NC} Check Prerequisites Only"
    echo -e "  ${GREEN}6)${NC} Exit"
    echo -e "\n${YELLOW}Enter your choice [1-6]:${NC} "
}

# Main execution
main() {
    # Check prerequisites
    echo -e "${BLUE}Checking prerequisites...${NC}\n"
    
    PREREQ_OK=true
    
    if ! check_appium_server; then
        PREREQ_OK=false
    fi
    
    if ! check_adb; then
        PREREQ_OK=false
    fi
    
    if ! check_python_deps; then
        PREREQ_OK=false
    fi
    
    if [ "$PREREQ_OK" = false ]; then
        echo -e "${RED}Prerequisites check failed. Please fix the issues above.${NC}"
        exit 1
    fi
    
    # Show menu
    while true; do
        show_menu
        read -r choice
        
        case $choice in
            1)
                run_tests "run_all_tests.py"
                ;;
            2)
                run_tests "test_login.py"
                ;;
            3)
                run_tests "test_register.py"
                ;;
            4)
                build_app
                ;;
            5)
                check_appium_server
                check_adb
                check_python_deps
                ;;
            6)
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice. Please select 1-6.${NC}\n"
                ;;
        esac
        
        echo -e "\n${YELLOW}Press Enter to continue...${NC}"
        read -r
        echo -e "\n"
    done
}

# Run main
main
