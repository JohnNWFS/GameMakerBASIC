# NW-BASIC Autotest Workflow

## Overview

The autotest system validates the NW-BASIC interpreter by running comprehensive test programs and checking their output against expected results. This document explains how the automation works, how to run tests, and how to add new test cases.

## How It Works

### Architecture

```
autotest.bas → run_program() → obj_basic_interpreter → global.output_lines
                                                      ↓
                                              Validation Logic
                                                      ↓
                                              Pass/Fail Report
```

### Key Components

1. **Test Program (`autotest.bas`)**
   - Comprehensive BASIC program testing all implemented features
   - Outputs results in parseable format: `TEST: <name> = <result>`
   - Self-documenting with comments
   - Organized by feature area

2. **Automation Hooks (Already Built)**
   - `global.output_lines` - Captures all PRINT output
   - `global.output_colors` - Captures text colors
   - `global.program_has_ended` - Flag set when program completes
   - `global._abort_after_validation` - Early exit for validation failures

3. **Execution Flow**
   - Load test program via `load_program_from("autotest.bas")`
   - Run program via `run_program()`
   - Monitor `global.program_has_ended` flag
   - Extract output from `global.output_lines`
   - Compare against expected results

## Running Autotests

### Manual Method

1. Launch NW-BASIC
2. Type: `LOAD "autotest.bas"`
3. Type: `RUN`
4. Review output for any `FAIL` markers
5. All tests should show `PASS`

### Automated Method (External Script)

The automation loop (built by Codex) handles:
- Loading the test program
- Running it to completion
- Capturing output
- Validating results
- Reporting pass/fail status
- Iterating on failures

## Test Output Format

Each test in `autotest.bas` outputs results in a standard format:

```basic
PRINT "TEST: feature_name = "; result_value
```

Examples:
```
TEST: ABS(-5) = 5
TEST: INT(3.7) = 3
TEST: LEN(HELLO) = 5
TEST: IF_BASIC = PASS
```

### Validation Markers

- `PASS` - Test passed
- `FAIL` - Test failed
- `SKIP` - Test skipped (feature not implemented)
- `ERROR` - Syntax or runtime error

## Test Organization

Tests in `autotest.bas` are organized by feature area:

1. **Basic Math** - Arithmetic operators, precedence
2. **Math Functions** - ABS, INT, SGN, SIN, COS, TAN, EXP, LOG, SQR, RND
3. **String Operations** - Concatenation, LEFT$, RIGHT$, MID$, LEN, CHR$, ASC, STR$
4. **Variables** - Numeric, string, arrays
5. **Control Flow** - IF/THEN/ELSE, FOR/NEXT, WHILE/WEND, GOTO, GOSUB/RETURN
6. **Data Handling** - DATA/READ/RESTORE, including named streams
7. **Arrays** - DIM, indexing, bounds
8. **I/O** - PRINT, INPUT (simulated), CLS
9. **System Functions** - TIME$, DATE$, TIMER (current date dependent)
10. **Mode 1** - Graphics commands (PSET, CHARAT, PRINTAT, etc.)
11. **Sound** - BEEP sequences (visual validation only)

## Known Gotchas

### 1. INPUT Commands Can't Be Fully Automated
**Issue:** `INPUT` requires user interaction  
**Workaround:** Tests use pre-set variables instead of actual INPUT  
**Example:**
```basic
10 REM Instead of: INPUT "Name: ", N$
20 N$ = "TEST"  ' Pre-set for automation
30 PRINT "TEST: INPUT_SIMULATION = "; N$
```

### 2. INKEY$ Timing Issues
**Issue:** `INKEY$` is non-blocking and timing-dependent  
**Workaround:** Tests verify the function exists but don't rely on actual keypress  
**Example:**
```basic
10 K$ = INKEY$  ' Returns "" if no key
20 PRINT "TEST: INKEY$_EXISTS = PASS"
```

### 3. Random Number Testing
**Issue:** `RND()` produces different values each run  
**Workaround:** Use `RANDOMIZE` with fixed seed for deterministic tests  
**Example:**
```basic
10 RANDOMIZE 42  ' Fixed seed
20 R = RND(1, 10)  ' Now deterministic
30 PRINT "TEST: RND_SEEDED = "; R
```

### 4. Time/Date Functions
**Issue:** `TIME$`, `DATE$`, `TIMER` return current time  
**Workaround:** Test format validity, not exact values  
**Example:**
```basic
10 T$ = TIME$
20 IF LEN(T$) = 8 THEN PRINT "TEST: TIME$_FORMAT = PASS"
```

### 5. MODE 1 Graphics Tests
**Issue:** Visual output can't be easily validated programmatically  
**Workaround:** Test that commands execute without error  
**Example:**
```basic
10 MODE 1
20 PSET 10, 10, 65, 15, 0  ' Should not crash
30 PRINT "TEST: MODE1_PSET = PASS"
40 MODE 0
```

### 6. BEEP Sound Tests
**Issue:** Audio can't be validated programmatically  
**Workaround:** Test that BEEP parses and executes without error  
**Example:**
```basic
10 BEEP C1  ' Should play without crashing
20 PRINT "TEST: BEEP_BASIC = PASS"
```

### 7. Error Handling Tests
**Issue:** Intentional errors would halt the test suite  
**Workaround:** Error tests are in separate test files  
**Note:** `autotest.bas` only tests valid code paths

### 8. Multi-line IF/ENDIF Blocks
**Issue:** Complex nested structures need careful validation  
**Workaround:** Tests include various nesting levels and ELSEIF cases  

### 9. Array Bounds
**Issue:** Out-of-bounds access should error  
**Workaround:** Positive tests only; error tests in separate suite  

### 10. Floating Point Precision
**Issue:** Floating point math may have rounding errors  
**Workaround:** Test with integers or use tolerance checks  
**Example:**
```basic
10 X = SIN(0)  ' Should be 0
20 IF ABS(X) < 0.0001 THEN PRINT "TEST: SIN_ZERO = PASS"
```

## Adding New Test Cases

When adding a new feature to NW-BASIC:

1. **Update `autotest.bas`**
   - Add test section for the new feature
   - Use standard `TEST: name = result` format
   - Include edge cases

2. **Update `PROJECT_STATUS.md`**
   - Mark feature as implemented
   - Add any known limitations

3. **Document Gotchas**
   - If the feature has automation challenges, document here
   - Provide workarounds

### Test Template

```basic
1000 REM ========================================
1010 REM TEST: FEATURE_NAME
1020 REM ========================================
1030 REM Test basic functionality
1040 result = FEATURE_FUNCTION(args)
1050 IF result = expected THEN PRINT "TEST: FEATURE_BASIC = PASS" ELSE PRINT "TEST: FEATURE_BASIC = FAIL"
1060 REM
1070 REM Test edge case 1
1080 result = FEATURE_FUNCTION(edge_case)
1090 PRINT "TEST: FEATURE_EDGE1 = "; result
1100 REM
1110 REM Test edge case 2
1120 REM ... etc
```

## Expected Test Output Structure

The complete test run should produce output like:

```
NW-BASIC AUTOTEST SUITE v1.0
========================================
TEST: ABS_POSITIVE = PASS
TEST: ABS_NEGATIVE = PASS
TEST: ABS_ZERO = PASS
TEST: INT_POSITIVE = PASS
TEST: INT_NEGATIVE = PASS
...
TEST: MODE1_PSET = PASS
TEST: BEEP_BASIC = PASS
========================================
TOTAL TESTS: 150
PASSED: 150
FAILED: 0
========================================
```

## Automation Integration Points

For external automation scripts:

### 1. Program Loading
```gml
load_program_from("autotest.bas");
```

### 2. Execution
```gml
run_program();
```

### 3. Completion Check
```gml
if (global.program_has_ended) {
    // Extract results
}
```

### 4. Output Capture
```gml
var output = "";
for (var i = 0; i < ds_list_size(global.output_lines); i++) {
    output += global.output_lines[| i] + "\n";
}
```

### 5. Result Parsing
Parse output for:
- `TEST:` lines
- `PASS`/`FAIL` markers
- Total counts

### 6. Validation
```gml
// Count passes/fails
var passes = string_count("PASS", output);
var fails = string_count("FAIL", output);
var success = (fails == 0);
```

## Best Practices

1. **Keep Tests Atomic** - Each test should be independent
2. **Use Fixed Seeds** - For any randomization
3. **Test Positive Paths** - Error testing in separate suite
4. **Clear Output** - Make results easy to parse
5. **Document Assumptions** - Explain what each test validates
6. **Version Tests** - Update version number when adding tests
7. **Organize Logically** - Group related tests together
8. **Avoid Side Effects** - Tests shouldn't affect each other

## Troubleshooting

### Test Suite Won't Load
- Check file path
- Verify `autotest.bas` syntax
- Check for BASIC syntax errors

### Test Suite Hangs
- Look for infinite loops
- Check for INPUT commands that need user interaction
- Verify WHILE/FOR loops have proper exit conditions

### Unexpected Failures
- Check for floating point precision issues
- Verify expected results are correct
- Look for order-dependent tests

### Automation Won't Trigger
- Verify `global.program_has_ended` flag is set
- Check that program reaches END statement
- Ensure no runtime errors

## Future Enhancements

- [ ] Separate error-case test suite
- [ ] Performance benchmarking tests
- [ ] Stress tests (large arrays, deep nesting)
- [ ] Regression test archive
- [ ] Test coverage metrics
- [ ] Automated test generation from spec

---

**Last Updated:** 2026-06-07  
**Author:** Claude (continuing Codex's work)  
**Version:** 1.0
