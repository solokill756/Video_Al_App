#!/usr/bin/env python3
"""
Simple test runner for profile edit tests
"""
import sys
import os
sys.path.insert(0, '/home/thao/Video_Al_App/appium_test')

import unittest
from test_cases.test_edit_profile import ProfileEditTests

# Create test suite
suite = unittest.TestSuite()

# Add tests in order
suite.addTest(ProfileEditTests('test_01_profile_page_elements'))
suite.addTest(ProfileEditTests('test_02_tap_edit_button'))
suite.addTest(ProfileEditTests('test_03_edit_name_field'))
suite.addTest(ProfileEditTests('test_04_edit_phone_field'))
suite.addTest(ProfileEditTests('test_05_empty_name_validation'))
suite.addTest(ProfileEditTests('test_06_invalid_phone_validation'))
suite.addTest(ProfileEditTests('test_07_save_valid_profile'))
suite.addTest(ProfileEditTests('test_08_upload_profile_avatar'))

# Run with verbose output
runner = unittest.TextTestRunner(verbosity=2, stream=sys.stdout)
result = runner.run(suite)

# Print summary
print("\n" + "="*70)
print(f"Tests run: {result.testsRun}")
print(f"Passed: {result.testsRun - len(result.failures) - len(result.errors)}")
print(f"Failed: {len(result.failures)}")
print(f"Errors: {len(result.errors)}")
print("="*70)

# Exit with appropriate code
sys.exit(0 if result.wasSuccessful() else 1)
