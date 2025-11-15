#!/usr/bin/env python3
"""
Run profile tests with timeout management
"""
import sys
import os
sys.path.insert(0, '/home/thao/Video_Al_App/appium_test')

import unittest
import signal

def timeout_handler(signum, frame):
    print("\n⏱️  Test execution timeout!")
    sys.exit(1)

# Set timeout of 5 minutes
signal.signal(signal.SIGALRM, timeout_handler)
signal.alarm(300)

try:
    # Import test class
    from test_cases.test_edit_profile import ProfileEditTests
    
    # Create test suite
    loader = unittest.TestLoader()
    suite = loader.loadTestsFromTestCase(ProfileEditTests)
    
    # Run with verbose output
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    # Cancel alarm
    signal.alarm(0)
    
    # Exit with appropriate code
    sys.exit(0 if result.wasSuccessful() else 1)
    
except Exception as e:
    print(f"\n❌ Error: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
