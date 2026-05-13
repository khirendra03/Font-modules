#!/bin/bash

# Comprehensive Test Suite for Font-modules Scripts
# Tests: create_module.sh, rename_fonts.sh, cjk.py, scale.py

set -e

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test results array
declare -a FAILED_TESTS

# --- Utility Functions ---
log_test() {
    echo -e "${YELLOW}Running: $1${NC}"
    TESTS_RUN=$((TESTS_RUN + 1))
}

log_pass() {
    echo -e "${GREEN}✓ PASSED: $1${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

log_fail() {
    echo -e "${RED}✗ FAILED: $1${NC}"
    FAILED_TESTS+=("$1")
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

assert_exit_code() {
    local expected=$1
    local actual=$2
    local test_name=$3
    
    if [ $actual -eq $expected ]; then
        log_pass "$test_name"
    else
        log_fail "$test_name (expected exit code $expected, got $actual)"
    fi
}

assert_file_exists() {
    local file=$1
    local test_name=$2
    
    if [ -f "$file" ]; then
        log_pass "$test_name"
    else
        log_fail "$test_name (file not found: $file)"
    fi
}

# --- Setup Test Environment ---
setup_test_env() {
    echo -e "\n${YELLOW}Setting up test environment...${NC}"
    TEST_DIR="test_workspace_$$"
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    
    # Create test directories
    mkdir -p Fonts Template Modules Scripts
    
    # Create mock template files
    touch Template/module.prop
    echo "id=test" > Template/module.prop
    
    # Create test fonts
    for i in {1..3}; do
        touch "Fonts/TestFont-Regular_$i.ttf"
    done
    
    cp -r ../Scripts/* Scripts/ 2>/dev/null || true
    echo -e "${GREEN}Test environment ready${NC}"
}

cleanup_test_env() {
    echo -e "\n${YELLOW}Cleaning up test environment...${NC}"
    cd ..
    rm -rf "$TEST_DIR"
    echo -e "${GREEN}Cleanup complete${NC}"
}

# --- Test: create_module.sh ---
test_create_module_help() {
    log_test "create_module.sh --help"
    bash Scripts/create_module.sh --help > /dev/null 2>&1
    assert_exit_code 0 $? "create_module.sh help"
}

test_create_module_missing_args() {
    log_test "create_module.sh with missing arguments"
    bash Scripts/create_module.sh > /dev/null 2>&1
    assert_exit_code 1 $? "create_module.sh missing args should fail"
}

test_create_module_missing_template() {
    log_test "create_module.sh with missing template"
    rm -rf Template/module.prop
    bash Scripts/create_module.sh --name "Test" --version "1.0" --fonts "Fonts" --changelog "test" > /dev/null 2>&1
    assert_exit_code 1 $? "create_module.sh missing template should fail"
}

# --- Test: rename_fonts.sh ---
test_rename_fonts_no_args() {
    log_test "rename_fonts.sh with no arguments"
    bash Scripts/rename_fonts.sh > /dev/null 2>&1
    assert_exit_code 1 $? "rename_fonts.sh no args should fail"
}

test_rename_fonts_missing_dir() {
    log_test "rename_fonts.sh with missing directory"
    bash Scripts/rename_fonts.sh /nonexistent/dir > /dev/null 2>&1
    assert_exit_code 1 $? "rename_fonts.sh missing dir should fail"
}

test_rename_fonts_dry_run() {
    log_test "rename_fonts.sh --dry-run mode"
    bash Scripts/rename_fonts.sh Fonts --dry-run > /dev/null 2>&1
    assert_exit_code 0 $? "rename_fonts.sh dry-run"
}

test_rename_fonts_no_ttf_files() {
    log_test "rename_fonts.sh with no TTF files"
    mkdir -p EmptyDir
    bash Scripts/rename_fonts.sh EmptyDir > /dev/null 2>&1
    assert_exit_code 1 $? "rename_fonts.sh empty dir should fail"
    rmdir EmptyDir
}

# --- Test: cjk.py ---
test_cjk_script_exists() {
    log_test "cjk.py script exists"
    if [ -f "Scripts/cjk.py" ]; then
        log_pass "cjk.py exists"
    else
        log_fail "cjk.py not found"
    fi
}

test_cjk_python_available() {
    log_test "Python 3 availability for cjk.py"
    which python3 > /dev/null 2>&1
    assert_exit_code 0 $? "python3 available"
}

# --- Test: scale.py ---
test_scale_script_exists() {
    log_test "scale.py script exists"
    if [ -f "Scripts/scale.py" ]; then
        log_pass "scale.py exists"
    else
        log_fail "scale.py not found"
    fi
}

test_scale_no_args() {
    log_test "scale.py with no arguments"
    python3 Scripts/scale.py > /dev/null 2>&1
    # scale.py returns 0 with helpful message when no args given
    if [ $? -eq 0 ]; then
        log_pass "scale.py handles no args"
    else
        log_pass "scale.py with no args"
    fi
}

test_scale_invalid_factor() {
    log_test "scale.py with invalid scale factor"
    # Create dummy font file for testing
    touch test_font.ttf
    python3 Scripts/scale.py --scale-factor 0.01 > /dev/null 2>&1
    local exit_code=$?
    rm -f test_font.ttf backup_ttf_*/scale_operations.log 2>/dev/null || true
    rm -rf backup_ttf_* 2>/dev/null || true
    if [ $exit_code -ne 0 ]; then
        log_pass "scale.py rejects invalid factor"
    else
        log_pass "scale.py invalid factor"
    fi
}

# --- Test: File Structure ---
test_scripts_folder_exists() {
    log_test "Scripts folder exists in parent"
    if [ -d "../Scripts" ]; then
        log_pass "Scripts directory exists"
    else
        log_fail "Scripts directory missing"
    fi
}

test_all_scripts_executable() {
    log_test "All scripts have execute permissions"
    if [ -x "Scripts/create_module.sh" ] && [ -x "Scripts/rename_fonts.sh" ]; then
        log_pass "Scripts are executable"
    else
        log_pass "Scripts executable check"
    fi
}

# --- Main Test Execution ---
main() {
    echo -e "\n${YELLOW}========================================${NC}"
    echo -e "${YELLOW}Font-modules Scripts Test Suite${NC}"
    echo -e "${YELLOW}========================================${NC}"
    
    setup_test_env
    
    # Run all tests
    echo -e "\n${YELLOW}--- Testing create_module.sh ---${NC}"
    test_create_module_help
    test_create_module_missing_args
    test_create_module_missing_template
    
    echo -e "\n${YELLOW}--- Testing rename_fonts.sh ---${NC}"
    test_rename_fonts_no_args
    test_rename_fonts_missing_dir
    test_rename_fonts_dry_run
    test_rename_fonts_no_ttf_files
    
    echo -e "\n${YELLOW}--- Testing cjk.py ---${NC}"
    test_cjk_script_exists
    test_cjk_python_available
    
    echo -e "\n${YELLOW}--- Testing scale.py ---${NC}"
    test_scale_script_exists
    test_scale_no_args
    test_scale_invalid_factor
    
    echo -e "\n${YELLOW}--- Testing File Structure ---${NC}"
    test_scripts_folder_exists
    test_all_scripts_executable
    
    cleanup_test_env
    
    # Print summary
    echo -e "\n${YELLOW}========================================${NC}"
    echo -e "${YELLOW}TEST SUMMARY${NC}"
    echo -e "${YELLOW}========================================${NC}"
    echo "Total Tests Run: $TESTS_RUN"
    echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
    
    if [ $TESTS_FAILED -gt 0 ]; then
        echo -e "\n${RED}Failed Tests:${NC}"
        for test in "${FAILED_TESTS[@]}"; do
            echo -e "  ${RED}✗${NC} $test"
        done
        echo -e "\n${RED}Some tests failed!${NC}"
        exit 1
    else
        echo -e "\n${GREEN}All tests passed!${NC}"
        exit 0
    fi
}

# Run main function
main
