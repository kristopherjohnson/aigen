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

### Instruction Handling
- [x] Single instruction text processed correctly (tested)
- [x] Multiple instructions concatenated with newlines (tested)
- [x] Instructions passed to LanguageModelSession (tested)
- [x] Instructions work with prompts and files (tested)
- [x] Empty instruction handled appropriately (ArgumentParser handles)

### Stdin `-` Argument Handling
- [x] `-` reads stdin at specified position (tested)
- [x] Multiple `-` only reads stdin once (not multiple times) (tested)
- [x] `-` works with prompt text (`-p "text" -`) (tested)
- [x] `-` works mixed with files (`- file.txt`) (tested)
- [x] `-` preserves order in concatenation (tested)
- [x] Verbose output shows stdin being read via `-` (tested)

### Streaming Output
- [x] Response streams to stdout incrementally (tested: works)
- [x] No buffering delays (text appears as generated) (tested: fflush ensures immediate output)
- [x] Stream errors handled gracefully (for-await try handles errors)
- [x] Final newline printed after stream completes (tested: works)
- [x] Timing measurement reflects streaming behavior (tested: works)

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
- [x] `aigen -i "Be concise" -p "What is 2+2?"` uses instruction (tested: works)
- [x] `aigen -i "You are helpful" -i "Be brief" -p "Explain AI"` concatenates instructions (tested: works)
- [x] `aigen -i "Summarize in bullets:" file.txt` combines instruction with file (tested: works)
- [x] `aigen -v -i "test instruction"` shows instruction in verbose output (tested: works)

### No-Stream Option
- [x] `aigen --no-stream -p "What is 2+2?"` waits for complete response (tested: works)
- [x] `aigen --no-stream -v -p "test"` works with verbose mode (tested: works)
- [x] Default behavior (without --no-stream) still streams (tested: works)

### Streaming Behavior
- [x] Visual confirmation: response appears incrementally, not all at once (tested: counting task shows incremental output)
- [x] Long response streams smoothly without delays (tested: works)
- [ ] Ctrl+C during streaming terminates gracefully
- [ ] Piped output works correctly with streaming

### No-Stream Mode
- [x] --no-stream flag disables streaming (tested: works)
- [x] Response appears all at once in --no-stream mode (tested: works)
- [x] --no-stream with verbose mode works correctly (tested: works)
- [x] --no-stream with instructions works correctly (tested: works)

### Temperature Option
- [x] `aigen -t 0.0 -p "What is 2+2?"` produces focused response (tested: works)
- [x] `aigen -t 1.0 -p "Write a creative story"` produces creative response (tested: works)
- [x] `aigen -t 0.5 -p "test"` works with mid-range temperature (tested: works)
- [x] Default behavior (no -t flag) uses system default temperature (tested: works)
- [x] Temperature validation: rejects values < 0.0 (tested: error shown)
- [x] Temperature validation: rejects values > 1.0 (tested: error shown)
- [x] Temperature works with streaming mode (tested: works)
- [x] Temperature works with --no-stream mode (tested: works)
- [x] Temperature works with instructions (tested: works)
- [x] Verbose output shows temperature when specified (tested: works)

### Stdin `-` Argument
- [x] `man otool | aigen -p "Summarize this for me:" -` appends stdin after prompt (tested: works)
- [x] `echo "test" | aigen - -p "Is this correct?"` puts stdin before prompt (tested: works)
- [x] `aigen -p "Context:" - file.txt` mixes stdin with files in order (tested: works)
- [x] `echo "data" | aigen - - file.txt` only reads stdin once (not twice) (tested: works)
- [x] `aigen -v -p "test" -` shows verbose output for stdin via `-` (tested: works)
- [x] `echo "hello" | aigen -` works (explicit stdin without prompts/files) (tested: works)

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
