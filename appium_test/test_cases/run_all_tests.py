"""
Test Suite - Run all tests
"""
import unittest
import sys
import os

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from test_login import LoginTests
from test_register import RegisterTests


def suite():
    """Create test suite"""
    test_suite = unittest.TestSuite()
    
    # Add Login tests
    test_suite.addTest(unittest.makeSuite(LoginTests))
    
    # Add Register tests
    test_suite.addTest(unittest.makeSuite(RegisterTests))
    
    return test_suite


if __name__ == '__main__':
    # Create screenshots directory
    os.makedirs("screenshots", exist_ok=True)
    
    # Run the test suite
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite())
    
    # Exit with error code if tests failed
    sys.exit(not result.wasSuccessful())
