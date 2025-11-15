#!/bin/bash
# Run Login Tests with timing

echo "=========================================="
echo "🚀 RUNNING LOGIN TESTS - FAST MODE"
echo "=========================================="
echo ""

# Navigate to test directory
cd /home/thao/Video_Al_App/appium_test

# Activate virtual environment
source venv/bin/activate

# Record start time
START_TIME=$(date +%s)

# Run tests
python3 -m unittest test_cases.test_login -v

# Record end time
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "=========================================="
echo "✅ TESTS COMPLETED"
echo "⏱️  Total time: ${DURATION} seconds"
echo "=========================================="
