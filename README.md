# aigen

A Swift CLI tool that sends prompts to Apple Intelligence Foundation Models. Reads input from files, inline prompt text, or stdin, optionally with system instructions, and prints the model's response.

## Requirements

- macOS 26+ (Tahoe)
- Apple Silicon Mac (M1 or later)
- Apple Intelligence enabled in System Settings
- Swift 6.0+

## Installation

Build from source using Swift Package Manager:

```bash
git clone https://github.com/kristopherjohnson/aigen.git
cd aigen
swift build -c release
cp .build/release/aigen /usr/local/bin/  # may need 'sudo'
```

## Usage

```
USAGE: aigen [options] [file ...]

ARGUMENTS:
  file                    Input files to read (reads stdin if none provided)

OPTIONS:
  -i, --instruction TEXT  Set system instructions for model (can be repeated)
  -p, --prompt TEXT       Add inline text to prompt (can be repeated)
  -t, --temperature VALUE Set sampling temperature 0.0-1.0 (default: system default)
      --no-stream         Disable streaming; wait for complete response
  -v, --verbose           Show processing details
  -h, --help              Show help information
```

### Examples

**Single file:**
```bash
aigen prompt.txt
```

**Multiple files (concatenated):**
```bash
aigen system.txt context.txt question.txt
```

**From stdin:**
```bash
echo "What is 2+2?" | aigen
```

**Pipeline usage:**
```bash
cat document.md | aigen > summary.txt
```

**Inline prompt text:**
```bash
aigen -p "What is the capital of France?"
```

**Mix prompt text with files:**
```bash
aigen -p "Summarize this document:" report.txt
```

**Multiple prompt texts:**
```bash
aigen -p "You are a helpful assistant." -p "What is 2+2?"
```

**Complex combinations:**
```bash
aigen -p "System: Be concise" context.txt -p "Question: Explain"
```

**System instructions:**
```bash
aigen -i "Be concise" -p "What is 2+2?"
```

**Multiple instructions (concatenated):**
```bash
aigen -i "You are a helpful assistant." -i "Use bullet points." document.txt
```

**Instructions with prompts and files:**
```bash
aigen -i "Summarize in 5 sentences" -p "Key points:" report.txt
```

**Verbose output:**
```bash
aigen -v prompt.txt
```

**Non-streaming mode:**
```bash
aigen --no-stream -p "What is 2+2?"
```

**Custom temperature:**
```bash
# Lower temperature (0.0-0.3) for more focused, deterministic responses
aigen -t 0.2 -p "What is the capital of France?"

# Higher temperature (0.7-1.0) for more creative, varied responses
aigen -t 0.8 -p "Write a creative story opening"

# Mid-range temperature (0.4-0.6) for balanced responses
aigen -t 0.5 -p "Explain quantum computing"
```

## How It Works

1. Reads input from inline prompt texts (`-p`), files, or stdin
2. Optionally sets system instructions (`-i`) for the model
3. Concatenates prompt texts and file contents with newlines
4. Sends the combined prompt to Apple's on-device Foundation Model with instructions
5. **Streams** the model's response to stdout in real-time as it's generated (or waits for complete response with `--no-stream`)

Notes:
- When using both `-p` and file arguments, all prompt texts are concatenated first, followed by all file contents
- Multiple instructions are concatenated with newlines and passed to the LanguageModelSession
- By default, output is streamed incrementally so you see the response as it's being generated
- Use `--no-stream` to wait for the complete response before printing (non-streaming mode)

## Error Handling

The tool provides clear error messages for common issues:
- File not found
- File read permission errors
- Apple Intelligence not enabled
- Device not eligible for Apple Intelligence
- Model not ready

Exit codes:
- `0` - Success
- `1` - Validation or runtime error

## Development

Run tests:
```bash
swift test
```

Build for debugging:
```bash
swift build
```

Run directly:
```bash
swift run aigen prompt.txt
```

## License

MIT License - see [LICENSE](LICENSE) file for details.
