# TCL Search Module - Learning Summary

## Overview
This module covers various string searching, matching, and comparison techniques in TCL. It demonstrates different approaches for pattern matching, regular expressions, file globbing, and text substitution operations.

## Key Files and Learning Outcomes

### 1. String Equality and Comparison (`equality.tcl`, `string_compare.tcl`, `string_equal.tcl`)

**Key Points:**
- **`==` operator**: Basic equality comparison (numerical context)
- **`eq` operator**: String equality comparison (recommended for strings)
- **`string compare`**: Returns -1, 0, or 1 for lexicographic comparison
- **`string equal`**: Returns boolean true/false for string equality

**Options Available:**
- `-nocase`: Case-insensitive comparison
- `-length n`: Compare only first n characters

**Learning Outcome:** Understanding different string comparison methods and when to use each approach for exact matches, case-insensitive comparisons, and prefix matching.

### 2. Regular Expressions (`string_exp1.tcl` to `string_exp5.tcl`)

#### Basic Regular Expressions (`string_exp1.tcl`)
**Key Points:**
- **`regexp`** command for pattern matching
- Basic pattern matching with exact strings
- Case-insensitive matching with `-nocase`
- Substring and prefix matching using variable interpolation

#### Complex Pattern Grouping (`string_exp2.tcl`)
**Key Points:**
- **Capture groups** using parentheses `()`
- Character classes: `[A-Za-z]`, `[[:alpha:]]`
- Pattern quantifiers: `*` (zero or more), `{n}` (exactly n), `{n,}` (n or more)
- Multiple capture groups for extracting different parts

**Pattern Examples:**
```tcl
{([A-Za-z]*).([A-Za-z]*)}     # Two word groups separated by any character
{([[:alpha:]]{4}).([[:alpha:]]{2,})} # First word exactly 4 chars, second 2+
```

#### Newline Handling (`string_exp3.tcl`)
**Key Points:**
- **`-line`** flag for line-aware matching
- **`-start n`** to begin matching from position n
- Impact of newlines on pattern matching
- Different behavior with and without line mode

#### Advanced Pattern Features (`string_exp4.tcl`)
**Key Points:**
- **`-all`**: Find all matches, not just the first
- **`-inline`**: Return matched strings directly
- **`-indices`**: Return position indices of matches
- Complex patterns with word boundaries `\w` and whitespace `\s`
- Nested pattern extraction (extracting numbers from matched text)

#### Anchors and Character Classes (`string_exp5.tcl`)
**Key Points:**
- **`^`**: Start of string anchor
- **`$`**: End of string anchor
- **`[^abc]`**: Negated character class (not a, b, or c)
- Combining anchors with patterns for precise matching

### 3. String Matching (`string_match.tcl`)

**Key Points:**
- **`string match`**: Glob-style pattern matching (simpler than regex)
- **Glob patterns**:
  - `*`: Match any number of characters
  - `?`: Match exactly one character
  - `[abc]`: Character set matching
- **`-nocase`**: Case-insensitive matching
- Escape sequences for literal matching

**Learning Outcome:** Understanding when to use simple glob patterns vs complex regular expressions.

### 4. File System Globbing (`string_glob1.tcl`, `string_glob2.tcl`)

#### Basic Globbing (`string_glob1.tcl`)
**Key Points:**
- **`glob`** command for file system pattern matching
- **File type filtering**: `-type d` for directories
- **Pattern combinations**: `*{.tcl,.txt}` for multiple extensions
- **Directory specification**: `-d dirname` to search in specific directory
- **Path options**: `-tail` to omit directory path from results

#### Recursive Directory Traversal (`string_glob2.tcl`)
**Key Points:**
- Recursive directory traversal using procedures
- Combining `glob` with loops for complex file operations
- Pattern `{[A-Za-z]*}` to match directories starting with letters
- `-nocomplain` to handle missing matches gracefully

### 5. List Searching (`string_lsearch.tcl`)

**Key Points:**
- **`lsearch`**: Search within TCL lists
- **Search modes**:
  - `-glob`: Glob pattern matching in lists
  - `-regexp`: Regular expression matching in lists
  - `-exact`: Exact string matching (default)
- **Result options**:
  - `-all`: Return all matching indices
  - `-inline`: Return matching elements instead of indices
- **Important distinction**: Regex `{M*}` vs Glob `{M*}` patterns behave differently

**Practical Application:** Finding and replacing elements in lists using `lsearch` + `lreplace`.

### 6. String Substitution (`string_sub.tcl`)

**Key Points:**
- **`regsub`**: Regular expression-based substitution
- **Replacement patterns**:
  - `&`: Represents the entire matched string
  - `\1`, `\2`: Represent captured groups
- **`-all`**: Replace all occurrences, not just the first
- Advanced replacement with grouping for complex transformations

## Overall Learning Outcomes

### 1. **Pattern Matching Hierarchy**
- **Simple comparisons**: Use `eq`, `==`, `string equal`, `string compare`
- **Glob patterns**: Use `string match` for simple wildcards
- **Regular expressions**: Use `regexp` for complex pattern matching
- **File system**: Use `glob` for file/directory patterns

### 2. **When to Use Each Approach**
- **Exact matching**: `string equal` or `eq`
- **Simple wildcards**: `string match` with glob patterns
- **Complex patterns**: `regexp` with regular expressions
- **File operations**: `glob` for file system searches
- **List operations**: `lsearch` for searching within lists

### 3. **Performance Considerations**
- Simple string operations are fastest
- Glob patterns are faster than regular expressions
- Regular expressions provide most flexibility but with performance cost

### 4. **Common Options Across Commands**
- **`-nocase`**: Available in most commands for case-insensitive operations
- **`-all`**: Find all matches instead of just the first
- **`-inline`**: Return matched content instead of indices/boolean

### 5. **Pattern Syntax Differences**
- **Glob**: `*` (any chars), `?` (one char), `[abc]` (char sets)
- **Regex**: Much more complex with `^$.*+?{}[]()|\` having special meanings
- **Understanding the difference prevents common mistakes**

## Best Practices

1. **Choose the simplest tool** that meets your requirements
2. **Use case-insensitive options** when user input is involved
3. **Test patterns thoroughly** with edge cases
4. **Escape special characters** when matching literal text
5. **Consider performance** for operations on large datasets
6. **Use capture groups** in regex for extracting specific parts
7. **Combine commands** (like `lsearch` + `lreplace`) for complex operations

## Reference Links
- [TCL Regular Expression Syntax](https://www.tcl-lang.org/man/tcl/TclCmd/re_syntax.htm) - Referenced in multiple files for advanced regex patterns
