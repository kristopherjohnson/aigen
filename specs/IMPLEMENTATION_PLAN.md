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

## Milestones

1. **M1**: CLI accepts files/stdin and prints concatenated content
2. **M2**: Foundation Models integration working, prints AI response
3. **M3**: Verbose mode and error handling complete
4. **M4**: Prompt text option (-p/--prompt) working with files
