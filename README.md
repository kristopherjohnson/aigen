# aigen

A Swift CLI tool that sends prompts to Apple Intelligence Foundation Models. Reads input from files, inline prompt text, or stdin and prints the model's response.

## Requirements

- macOS 26+ (Tahoe)
- Apple Silicon Mac (M1 or later)
- Apple Intelligence enabled in System Settings
- Swift 6.0+

## Installation

Build from source using Swift Package Manager:

```bash
git clone <repository-url>
cd aigen
swift build -c release
cp .build/release/aigen /usr/local/bin/
```

## Usage

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

**Verbose output:**
```bash
aigen -v prompt.txt
```

## How It Works

1. Reads input from inline prompt texts (`-p`), files, or stdin
2. Concatenates prompt texts and file contents with newlines
3. Sends the combined prompt to Apple's on-device Foundation Model
4. Prints the model's response to stdout

Note: When using both `-p` and file arguments, all prompt texts are concatenated first, followed by all file contents.

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
