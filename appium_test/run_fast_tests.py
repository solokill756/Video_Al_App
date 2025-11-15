#!/usr/bin/env python3
"""
Fast Test Runner - Run all tests with optimized speed
"""
import sys
import os

# Add config to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'config'))

# Set fast mode BEFORE importing any page objects
from speed_config import SpeedConfig
SpeedConfig.set_mode('fast')

print("=" * 60)
print("🚀 FAST MODE ENABLED")
print(f"   - Element timeout: {SpeedConfig.get_timeout()}s")
print(f"   - After action delay: {SpeedConfig.get_delay('after_action')}s")
print(f"   - After keyboard delay: {SpeedConfig.get_delay('after_keyboard')}s")
print("=" * 60)

import unittest

if __name__ == '__main__':
    # Discover and run all tests
    loader = unittest.TestLoader()
    start_dir = 'test_cases'
    suite = loader.discover(start_dir, pattern='test_*.py')
    
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    # Exit with error code if tests failed
    sys.exit(not result.wasSuccessful())
