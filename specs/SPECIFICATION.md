# aigen Specification

## Overview

A Swift CLI tool that sends prompts to Apple Intelligence Foundation Models. Reads input from files or stdin and prints the model's response.

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
- **Prompt text option**: Accept inline prompt text via `-p/--prompt` option (can be used multiple times)
- **Prompt concatenation**: Combine contents of multiple files and prompt texts in order specified
- **Model invocation**: Send prompt to Apple Intelligence Foundation Model
- **Output**: Print model response to stdout

### Options

- **Prompt text** (`-p TEXT`, `--prompt TEXT`): Add inline text to the prompt (can be used multiple times, interspersed with file arguments)
- **Verbose mode** (`-v`, `--verbose`): Display processing details (files read, token counts, timing)

## User Interface

```
USAGE: aigen [options] [file ...]

ARGUMENTS:
  file                    Input files to read (reads stdin if none provided)

OPTIONS:
  -p, --prompt TEXT       Add inline text to prompt (can be repeated)
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

# Complex combination
aigen -p "System: You are helpful" context.txt -p "Question: Explain this"
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
- Streaming output (print complete response)
- Configuration files
- Custom system prompts (may add later)
