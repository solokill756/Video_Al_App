#!/bin/bash
# Simple test runner for profile edit tests
cd /home/thao/Video_Al_App/appium_test
source venv/bin/activate

echo "Starting profile edit tests..."
python3 -m unittest test_cases.test_edit_profile.ProfileEditTests -v
