# aigen Specification

## Overview

A Swift CLI tool that sends prompts to Apple Intelligence Foundation Models. Reads input from files or stdin and prints the model's response.

**Repository:** https://github.com/kristopherjohnson/aigen

## Goals

- Simple Unix-philosophy tool: read input → process with AI → print output
- Support file arguments and stdin for flexible pipeline integration
- Minimal dependencies, leveraging native Apple frameworks

## Target Platforms

- macOS 26+ (Tahoe) — required for Foundation Models framework
- Distributed via Swift Package Manager

## Features

### Core Functionality

- **File input**: Accept one or more file paths as command-line arguments
- **Stdin fallback**: Read from stdin when no files are provided
- **Explicit stdin**: Use `-` as a special file argument to read stdin at a specific position
- **Prompt text option**: Accept inline prompt text via `-p/--prompt` option (can be used multiple times)
- **System instructions**: Accept system instructions via `-i/--instruction` option (can be used multiple times)
- **Prompt concatenation**: Combine contents of multiple files, stdin, and prompt texts in order specified
- **Model invocation**: Send prompt to Apple Intelligence Foundation Model with optional instructions
- **Streaming output**: Stream model response to stdout as it's generated (default behavior)
- **Output**: Print model response to stdout in real-time

### Options

- **Instruction text** (`-i TEXT`, `--instruction TEXT`): Set system instructions for the model (can be used multiple times; multiple instructions are concatenated with newlines)
- **Prompt text** (`-p TEXT`, `--prompt TEXT`): Add inline text to the prompt (can be used multiple times, interspersed with file arguments)
- **Temperature** (`-t VALUE`, `--temperature VALUE`): Set sampling temperature (0.0-1.0) for response generation; if not specified, uses system default
- **No streaming** (`--no-stream`): Disable streaming output; waits for complete response before printing
- **Verbose mode** (`-v`, `--verbose`): Display processing details (files read, token counts, timing)

## User Interface

```
USAGE: aigen [options] [file ...]

ARGUMENTS:
  file                    Input files to read (use '-' to read stdin; reads stdin if no arguments)

OPTIONS:
  -i, --instruction TEXT  Set system instructions for model (can be repeated)
  -p, --prompt TEXT       Add inline text to prompt (can be repeated)
  -t, --temperature VALUE Set sampling temperature 0.0-1.0 (default: system default)
      --no-stream         Disable streaming; wait for complete response
  -v, --verbose           Show processing details
  -h, --help              Show help information
```

### Examples

```bash
# Single file
aigen prompt.txt

# Multiple files concatenated
aigen system.txt context.txt question.txt

# From stdin
echo "What is 2+2?" | aigen

# Pipeline usage
cat document.md | aigen > summary.txt

# Verbose output
aigen -v prompt.txt

# Inline prompt text
aigen -p "What is the capital of France?"

# Mix files and prompt text
aigen -p "Summarize this:" document.txt

# Multiple prompts interspersed with files
aigen -p "Tell me good morning" file.md -p "Tell me good evening"

# System instructions
aigen -i "You are a helpful assistant. Be concise." -p "What is 2+2?"

# Multiple instructions (concatenated)
aigen -i "You are a technical expert." -i "Explain in simple terms." document.txt

# Instructions with file input
aigen -i "Summarize the following in bullet points:" report.txt

# Non-streaming mode (waits for complete response)
aigen --no-stream -p "What is 2+2?"

# Custom temperature for more creative responses
aigen -t 0.8 -p "Write a creative story opening"

# Lower temperature for more focused responses
aigen -t 0.2 -p "What is the capital of France?"

# Explicit stdin with prompt (Unix convention)
man otool | aigen -p "Summarize this for me:" -

# Mix stdin with files in specific order
aigen -p "Context:" - file.txt -p "Question: explain"

# Stdin as first input
echo "test" | aigen - -p "Is this correct?"
```

## Technical Requirements

- Swift 6.0+
- Foundation Models framework (macOS 26+)
- Swift Argument Parser for CLI parsing

## Constraints

- Requires Apple Silicon Mac with Apple Intelligence enabled
- Model availability depends on device and region
- Input size limited by Foundation Models context window

## Out of Scope

- Model selection/switching (use default Foundation Model)
- Conversation history/multi-turn chat
- Configuration files
- Non-streaming mode (always streams)
