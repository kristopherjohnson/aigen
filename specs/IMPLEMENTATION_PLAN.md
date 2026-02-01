# aigen Implementation Plan

## Phase 1: Project Setup

### 1.1 Initialize Swift Package
- [x] Create Package.swift with executable target [agent: swift-expert]
- [x] Add Swift Argument Parser dependency [agent: swift-expert]
- [x] Configure minimum macOS 26 deployment target [agent: swift-expert]
- [x] Create basic directory structure (Sources/aigen/) [agent: swift-expert]

## Phase 2: Core Implementation

### 2.1 CLI Argument Parsing
- [x] Define main command struct with ArgumentParser [agent: swift-expert]
- [x] Add file arguments (zero or more paths) [agent: swift-expert]
- [x] Add verbose flag (-v, --verbose) [agent: swift-expert]

### 2.2 Input Handling
- [x] Implement file reading for provided paths [agent: swift-expert]
- [x] Implement stdin reading when no files provided [agent: swift-expert]
- [x] Concatenate multiple file contents with newlines [agent: swift-expert]
- [x] Add error handling for missing/unreadable files [agent: swift-expert]

### 2.3 Foundation Models Integration
- [x] Import FoundationModels framework [agent: swift-expert]
- [x] Create language model session [agent: swift-expert]
- [x] Send concatenated prompt to model [agent: swift-expert]
- [x] Receive and extract response text [agent: swift-expert]
- [x] Handle model availability/errors gracefully [agent: swift-expert]

### 2.4 Output
- [x] Print model response to stdout [agent: swift-expert]
- [x] Implement verbose output (files read, timing) [agent: swift-expert]

## Phase 3: Polish

### 3.1 Error Handling
- [x] User-friendly error messages for common failures [agent: swift-expert]
- [x] Exit codes for different error conditions [agent: swift-expert]

### 3.2 Documentation
- [x] Add README.md with usage examples
- [x] Add inline code documentation [agent: swift-expert]

## Dependencies

| Dependency | Version | Purpose |
|------------|---------|---------|
| Swift Argument Parser | 1.3+ | CLI argument parsing |
| Foundation Models | macOS 26+ | Apple Intelligence integration |

## Phase 4: Prompt Text Option

### 4.1 Argument Parsing Enhancement
- [x] Add -p/--prompt option to accept text arguments [agent: swift-expert]
- [x] Support multiple instances of -p/--prompt [agent: swift-expert]
- [x] Allow interspersing with file arguments [agent: swift-expert]

### 4.2 Input Processing Update
- [x] Track order of files and prompt texts as specified [agent: swift-expert]
- [x] Concatenate files and prompts in correct order [agent: swift-expert]
- [x] Update verbose output to show prompt texts [agent: swift-expert]

### 4.3 Testing and Documentation
- [x] Add tests for prompt text option [agent: swift-expert]
- [x] Update README.md with new examples
- [x] Update help text and documentation [agent: swift-expert]

## Phase 5: System Instructions Option

### 5.1 Argument Parsing for Instructions
- [x] Add -i/--instruction option to accept text arguments [agent: swift-expert]
- [x] Support multiple instances of -i/--instruction [agent: swift-expert]
- [x] Store instructions separately from prompts [agent: swift-expert]

### 5.2 LanguageModelSession Integration
- [x] Modify sendToModel() to accept optional instructions parameter [agent: swift-expert]
- [x] Concatenate multiple instructions with newlines [agent: swift-expert]
- [x] Create LanguageModelSession with instructions using trailing closure [agent: swift-expert]
- [x] Update verbose output to show instruction count [agent: swift-expert]

### 5.3 Testing and Documentation
- [x] Test single instruction option [agent: swift-expert]
- [x] Test multiple instructions concatenation [agent: swift-expert]
- [x] Update README.md with instruction examples
- [x] Update CLAUDE.md with instructions API usage

## Phase 6: Streaming Output

### 6.1 Replace respond() with streamResponse()
- [x] Change sendToModel() to use streamResponse() instead of respond() [agent: swift-expert]
- [x] Iterate over async stream with for-await loop [agent: swift-expert]
- [x] Print each partial response as it arrives [agent: swift-expert]

### 6.2 Handle Streaming Edge Cases
- [x] Handle stream errors gracefully [agent: swift-expert]
- [x] Ensure final newline after complete response [agent: swift-expert]
- [x] Update timing measurement to reflect streaming behavior [agent: swift-expert]

### 6.3 Testing and Documentation
- [x] Test streaming output visually [agent: swift-expert]
- [x] Update README.md to reflect streaming behavior
- [x] Update CLAUDE.md with streamResponse API usage

## Phase 7: No-Stream Option

### 7.1 Add --no-stream Flag
- [x] Add --no-stream flag to ArgumentParser [agent: swift-expert]
- [x] Pass flag to sendToModel() method [agent: swift-expert]

### 7.2 Implement Conditional Output
- [x] Check no-stream flag in sendToModel() [agent: swift-expert]
- [x] Use respond() when --no-stream is set [agent: swift-expert]
- [x] Use streamResponse() when --no-stream is not set (default) [agent: swift-expert]

### 7.3 Testing and Documentation
- [x] Test --no-stream mode [agent: swift-expert]
- [x] Update README.md with --no-stream example
- [x] Update help text documentation

## Phase 8: Temperature Option

### 8.1 Add --temperature Flag
- [x] Add -t/--temperature option to ArgumentParser [agent: swift-expert]
- [x] Validate temperature range (0.0-1.0) [agent: swift-expert]
- [x] Store as optional Double (nil if not specified) [agent: swift-expert]

### 8.2 Integrate with GenerationOptions
- [x] Create GenerationOptions with temperature when specified [agent: swift-expert]
- [x] Pass GenerationOptions to respond() method [agent: swift-expert]
- [x] Pass GenerationOptions to streamResponse() method [agent: swift-expert]
- [x] Use nil GenerationOptions when temperature not specified (system default) [agent: swift-expert]

### 8.3 Testing and Documentation
- [x] Test with various temperature values (0.0, 0.5, 1.0) [agent: swift-expert]
- [x] Test default behavior (no temperature specified) [agent: swift-expert]
- [x] Update README.md with temperature examples
- [x] Update CLAUDE.md with GenerationOptions API usage
- [x] Update verbose output to show temperature when specified [agent: swift-expert]

## Phase 9: Explicit Stdin with `-` Argument

### 9.1 Implement `-` File Argument Recognition
- [x] Detect when `-` appears in files array [agent: swift-expert]
- [x] Read stdin when `-` is encountered [agent: swift-expert]
- [x] Maintain order: process `-` at its position among other inputs [agent: swift-expert]

### 9.2 Update Input Processing Logic
- [x] Modify readInput() to handle `-` in files array [agent: swift-expert]
- [x] Ensure stdin is only read once even if `-` appears multiple times [agent: swift-expert]
- [x] Update verbose output to show "Reading from stdin (-)" [agent: swift-expert]

### 9.3 Testing and Documentation
- [x] Test `-` with prompt text: `echo "test" \| aigen -p "Prompt:" -` [agent: swift-expert]
- [x] Test `-` mixed with files: `aigen -p "Start:" - file.txt` [agent: swift-expert]
- [x] Test multiple `-` (should only read stdin once) [agent: swift-expert]
- [x] Update README.md with stdin `-` examples
- [x] Update help text to document `-` argument
- [x] Update CLAUDE.md with `-` usage pattern

## Milestones

1. **M1**: CLI accepts files/stdin and prints concatenated content
2. **M2**: Foundation Models integration working, prints AI response
3. **M3**: Verbose mode and error handling complete
4. **M4**: Prompt text option (-p/--prompt) working with files
5. **M5**: System instructions option (-i/--instruction) integrated with LanguageModelSession
6. **M6**: Streaming output implemented using streamResponse()
7. **M7**: --no-stream option for buffered output using respond()
8. **M8**: Temperature control option (-t/--temperature) with GenerationOptions
9. **M9**: Explicit stdin support using `-` as file argument (Unix convention)
