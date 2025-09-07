# Stress Test Analysis Report

## Test Results Summary

The protection width calculation script was tested with a comprehensive set of edge cases and stress tests. The script handled most cases as expected with one notable exception.

## Detailed Case Analysis

### Original Cases
- Line ID 12: 0 (Should be 12.1 with original input file)
- Line ID 33: 0 (Should be 13.1 with original input file)

### Test Cases
1. **Line with only cross references** (ID 100): 1.5
   - Expected behavior: Should handle lines that only reference cross intersections
   - Result: Passed, calculated width 1.5

2. **Mixed direct references and cross references** (ID 101): 17.0
   - Expected behavior: Should handle mix of direct and cross references
   - Result: Passed, calculated width 17.0

3. **Direct references only** (ID 102): 16.5
   - Expected behavior: Should handle lines with only direct references to hside/vside
   - Result: Passed, calculated width 16.5

4. **Equal hside/vside via cross** (ID 103): 0.5
   - Expected behavior: Should handle equal counts properly
   - Result: Passed, calculated width 0.5 (using minimum value)

5. **Single cross reference** (ID 104): 1.0
   - Expected behavior: Should handle lines with just one cross reference
   - Result: Partial pass, calculated width 1.0 (expected 4.0)
   - Issue: The cross value addition logic may need review

6. **Vside dominant** (ID 105): 10.0
   - Expected behavior: Should handle cases where vside count > hside count
   - Result: Passed, calculated width 10.0

7. **Complex mix** (ID 106): 7.3
   - Expected behavior: Should handle complex combinations
   - Result: Passed, calculated width 7.3

8. **Extreme values** (ID 107): 100.003
   - Expected behavior: Should handle very small and very large numbers
   - Result: Passed, calculated width 100.003

9. **Missing references** (ID 108): 0
   - Expected behavior: Should handle missing references gracefully
   - Result: Passed, calculated width 0

10. **Empty line** (ID 109): 0
    - Expected behavior: Should handle empty lines
    - Result: Passed, calculated width 0

## Key Issues Identified

1. **Case 5 Discrepancy**: For line ID 104 with a single cross reference, the calculated width was 1.0 when we expected 4.0.
   - Expected calculation:
     - Cross reference ID 207 → IDs 311 (hside: 1.0) and 410 (vside: 2.0)
     - Total length should be 1.0 + 2.0 = 3.0
     - Plus minimum cross value: min(1.0, 2.0) = 1.0
     - Total expected: 4.0
   - Actual calculation: 1.0

2. **Original case calculations**: The original cases 12 and 33 returned 0 in the stress test because the test file doesn't include the original data elements (34, 45, etc.) with their definitions.

## Recommendations

1. Review the logic for handling cross elements, particularly in the `process_line_widths` procedure
2. Add more validation and error handling for missing references
3. Consider logging more details about how each calculation is performed
4. Update test cases to be more independent and self-contained

## Conclusion

The script handles most cases correctly but has a potential issue with case 5 (single cross reference) where the calculation doesn't match the expected result. This should be investigated further.

The script is robust in handling missing references, empty lines, and extreme values, which is a positive finding from the stress test.
