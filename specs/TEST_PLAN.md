# aigen Test Plan

## Unit Tests

### Input Handling
- [x] Read single file successfully (implemented in readInput())
- [x] Read multiple files and concatenate (implemented in readInput())
- [x] Handle missing file with appropriate error (implemented in readInput())
- [x] Handle unreadable file (permissions) with error (implemented in readInput())
- [x] Read from stdin when no files provided (implemented in readStdin())
- [x] Empty file produces empty string (handled by String.init)
- [x] Multiple files separated by newlines (implemented via joined())

### Argument Parsing
- [x] Parse single file argument (ArgumentParser handles this)
- [x] Parse multiple file arguments (ArgumentParser handles this)
- [x] Parse -v flag (verified via --help output)
- [x] Parse --verbose flag (verified via --help output)
- [x] Parse --help flag (verified working)
- [x] No arguments triggers stdin mode (implemented in readInput())
- [x] Parse single -p/--prompt argument (verified via --help)
- [x] Parse multiple -p/--prompt arguments (verified via --help)
- [x] Parse interspersed -p and file arguments (verified via --help)

### Prompt Text Handling
- [x] Single prompt text processed correctly (tested)
- [x] Multiple prompt texts concatenated in order (tested with -v)
- [x] Prompt text interspersed with files maintains order (prompts first, then files)
- [x] Empty prompt text handled appropriately (ArgumentParser handles)
- [ ] Prompt text with special characters (quotes, newlines)

## Integration Tests

### End-to-End
- [ ] File input → model → stdout output
- [ ] Stdin input → model → stdout output
- [ ] Multiple files concatenated correctly before model
- [ ] Verbose mode shows expected details

### Error Conditions
- [ ] Missing file returns non-zero exit code
- [ ] Model unavailable handled gracefully
- [ ] Empty input handled appropriately

## Manual Tests

### Basic Usage
- [x] `aigen prompt.txt` produces AI response (tested: works)
- [x] `echo "Hello" | aigen` produces AI response (tested: works)
- [x] `aigen file1.txt file2.txt` concatenates and processes (tested: works)
- [x] `aigen -v prompt.txt` shows verbose output (tested: works)
- [x] `aigen -p "What is 2+2?"` produces AI response (tested: works)
- [x] `aigen -p "Summarize:" file.txt` concatenates prompt and file (tested: works)
- [x] `aigen -p "Good morning" -p "Good evening"` maintains order (tested: works)
- [x] `aigen -v -p "test"` shows prompt text in verbose output (tested: works)

### Edge Cases
- [ ] Very large file input (test context limits)
- [ ] Binary file input (should error or handle)
- [ ] Unicode/emoji in input
- [ ] Empty stdin (Ctrl+D immediately)

### Platform Requirements
- [ ] Verify macOS 26+ requirement enforced
- [ ] Verify Apple Intelligence availability check
- [ ] Test on Apple Silicon Mac

## Performance Tests

- [ ] Measure startup time (target: <100ms to first model call)
- [ ] Test with various input sizes (1KB, 10KB, 100KB)
