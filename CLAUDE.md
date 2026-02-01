# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`aigen` is a Swift CLI tool that sends prompts to Apple Intelligence Foundation Models. It's a single-file executable that reads input from files, inline prompt text, or stdin, optionally with system instructions, and prints the AI model's response.

## Requirements

- macOS 26+ (Tahoe) - required for FoundationModels framework
- Apple Silicon Mac (M1 or later)
- Apple Intelligence enabled in System Settings
- Swift 6.0+

## Build and Development Commands

```bash
# Build for debugging
swift build

# Build for release
swift build -c release

# Run directly (development)
swift run aigen <args>

# Run built executable
.build/debug/aigen <args>

# Run tests (when available)
swift test
```

## Architecture

This is a single-file CLI application (`Sources/aigen/main.swift`) with a simple architecture:

**Main Flow:**
1. `Aigen` struct (AsyncParsableCommand) - handles argument parsing via Swift Argument Parser
2. `readInput()` - collects input from three sources in order:
   - All `-p/--prompt` text arguments (concatenated first)
   - All file arguments (read and concatenated)
   - Stdin (if no prompts or files provided)
3. `sendToModel()` - sends prompt to FoundationModels framework with optional instructions
   - By default: streams response in real-time using `streamResponse()`
   - With `--no-stream`: waits for complete response using `respond()`
4. Response printed to stdout (streaming or buffered), verbose info to stderr

**Key Design Decisions:**
- System instructions (`-i`) are stored separately and passed to LanguageModelSession
- Multiple instructions are concatenated with newlines
- Prompt texts (`-p`) are always concatenated before file contents
- All inputs separated by newlines when joined
- Verbose output goes to stderr via custom `StandardError` TextOutputStream
- Uses `guard #available(macOS 26, *)` for platform checking
- Model availability checked via `SystemLanguageModel.default.availability` switch

**Dependencies:**
- `swift-argument-parser` (1.3+) - CLI argument parsing
- `FoundationModels` (macOS 26+) - Apple Intelligence integration

## Testing the Tool

```bash
# Test with inline prompt
.build/debug/aigen -p "What is 2+2?"

# Test with file input
echo "Test content" > test.txt
.build/debug/aigen test.txt

# Test with stdin
echo "Hello" | .build/debug/aigen

# Test with instructions
.build/debug/aigen -i "Be concise" -p "What is 2+2?"

# Test with multiple instructions
.build/debug/aigen -i "You are helpful" -i "Be brief" -p "Explain AI"

# Test with combined inputs
.build/debug/aigen -p "Context:" file.txt -p "Question: Explain"

# Test instructions with file
.build/debug/aigen -i "Summarize in bullets" document.txt

# Test verbose mode
.build/debug/aigen -v -i "Test instruction" -p "Test prompt"

# Test non-streaming mode
.build/debug/aigen --no-stream -p "What is 2+2?"

# Test non-streaming with verbose and instructions
.build/debug/aigen -v --no-stream -i "Be concise" -p "Explain AI"

# Test temperature control
.build/debug/aigen -t 0.2 -p "What is the capital of France?"
.build/debug/aigen -t 0.8 -p "Write a creative story"
.build/debug/aigen -v -t 0.5 -p "test"
```

## Foundation Models API Usage

The tool uses the FoundationModels framework (macOS 26+):

```swift
// Check availability
let model = SystemLanguageModel.default
switch model.availability {
    case .available: // proceed
    case .unavailable(reason): // handle specific reasons
}

// Create session without instructions
let session = LanguageModelSession()

// Create session WITH instructions (using trailing closure)
let session = LanguageModelSession {
    instructionsText  // String containing concatenated instructions
}

// Stream response (default mode in aigen)
let stream = session.streamResponse(to: prompt)
var previousLength = 0
for try await snapshot in stream {
    let fullContent = snapshot.content
    if fullContent.count > previousLength {
        let newContent = String(fullContent.dropFirst(previousLength))
        print(newContent, terminator: "")
        fflush(stdout)
        previousLength = fullContent.count
    }
}

// Note: Snapshots contain full accumulated content, not deltas
// Must track previous length to print only new content

// Buffered response (--no-stream mode in aigen)
let response = try await session.respond(to: prompt)
print(response.content, terminator: "")

// Using GenerationOptions for temperature control
let options = GenerationOptions(temperature: 0.7)

// Stream with options
let stream = session.streamResponse(to: prompt, options: options)
// ... process stream as above

// Buffered response with options
let response = try await session.respond(to: prompt, options: options)

// When temperature is nil, pass no options (uses system default)
if let temperature {
    let options = GenerationOptions(temperature: temperature)
    let stream = session.streamResponse(to: prompt, options: options)
} else {
    let stream = session.streamResponse(to: prompt)
}
```

## Error Handling

All errors throw `ValidationError` from ArgumentParser with user-friendly messages:
- File not found
- File read permission errors
- Apple Intelligence not enabled
- Device not eligible
- Model not ready
- macOS version too old
