import ArgumentParser
import Foundation
import FoundationModels

@main
struct Aigen: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "aigen",
        abstract: "Send prompts to Apple Intelligence Foundation Models",
        discussion: """
            Reads input from files, prompt texts, or stdin and prints the model's response.

            Examples:
              aigen prompt.txt
              echo "What is 2+2?" | aigen
              aigen system.txt context.txt question.txt
              aigen -p "What is the capital of France?"
              aigen -p "Summarize this:" document.txt
              aigen -p "Good morning" file.md -p "Good evening"
              aigen -i "You are a helpful assistant" -p "What is 2+2?"
              aigen -i "Be concise" -i "Use bullet points" document.txt
              man otool | aigen -p "Summarize this for me:" -
            """
    )

    @Flag(name: [.short, .long], help: "Show processing details")
    var verbose = false

    @Option(name: [.short, .long], help: "Set system instructions for model (can be repeated)")
    var instruction: [String] = []

    @Option(name: [.short, .long], help: "Add inline text to prompt (can be repeated)")
    var prompt: [String] = []

    @Option(name: [.short, .long], help: "Set sampling temperature 0.0-1.0 (default: system default)")
    var temperature: Double?

    @Flag(name: .long, help: "Disable streaming; wait for complete response")
    var noStream = false

    @Argument(help: "Input files to read (use '-' to read stdin; reads stdin if no arguments)")
    var files: [String] = []

    mutating func run() async throws {
        // Validate temperature range
        if let temp = temperature {
            guard temp >= 0.0 && temp <= 1.0 else {
                throw ValidationError("Temperature must be between 0.0 and 1.0 (got \(temp))")
            }
        }

        let startTime = Date()
        let input = try readInput()

        if verbose {
            print("Read \(input.count) characters", to: &standardError)
            if !instruction.isEmpty {
                print("Using \(instruction.count) instruction(s)", to: &standardError)
            }
            if let temp = temperature {
                print("Temperature: \(temp)", to: &standardError)
            }
        }

        let instructionsText = instruction.isEmpty ? nil : instruction.joined(separator: "\n")

        try await sendToModel(input, instructions: instructionsText, temperature: temperature, stream: !noStream)
        print()  // Final newline after response

        if verbose {
            let duration = Date().timeIntervalSince(startTime)
            print("Completed in \(String(format: "%.2f", duration))s", to: &standardError)
        }
    }

    private func readInput() throws -> String {
        if prompt.isEmpty && files.isEmpty {
            if verbose {
                print("Reading from stdin...", to: &standardError)
            }
            return readStdin()
        }

        var contents: [String] = []
        var stdinRead = false

        if !prompt.isEmpty {
            if verbose {
                let countText = prompt.count == 1 ? "prompt text" : "prompt texts"
                print("Adding \(prompt.count) \(countText)...", to: &standardError)
            }
            contents.append(contentsOf: prompt)
        }

        for filePath in files {
            if filePath == "-" {
                if !stdinRead {
                    if verbose {
                        print("Reading from stdin (-)...", to: &standardError)
                    }
                    contents.append(readStdin())
                    stdinRead = true
                }
            } else {
                if verbose {
                    print("Reading \(filePath)...", to: &standardError)
                }
                contents.append(try readFile(at: filePath))
            }
        }

        return contents.joined(separator: "\n")
    }

    private func readFile(at path: String) throws -> String {
        do {
            return try String(contentsOf: URL(fileURLWithPath: path), encoding: .utf8)
        } catch let error as NSError where error.domain == NSCocoaErrorDomain && error.code == NSFileReadNoSuchFileError {
            throw ValidationError("File not found: \(path)")
        } catch {
            throw ValidationError("Failed to read file '\(path)': \(error.localizedDescription)")
        }
    }

    private func readStdin() -> String {
        var lines: [String] = []
        while let line = readLine(strippingNewline: false) {
            lines.append(line)
        }
        return lines.joined()
    }

    private func sendToModel(_ prompt: String, instructions: String?, temperature: Double?, stream: Bool) async throws {
        guard #available(macOS 26, *) else {
            throw ValidationError("Foundation Models requires macOS 26 or newer.")
        }

        let model = SystemLanguageModel.default

        guard case .available = model.availability else {
            throw ValidationError(availabilityMessage(for: model.availability))
        }

        let session = if let instructions {
            LanguageModelSession { instructions }
        } else {
            LanguageModelSession()
        }

        let options = temperature.map { GenerationOptions(temperature: $0) }

        if stream {
            try await streamResponse(session: session, prompt: prompt, options: options)
        } else {
            try await bufferedResponse(session: session, prompt: prompt, options: options)
        }
    }

    @available(macOS 26, *)
    private func streamResponse(session: LanguageModelSession, prompt: String, options: GenerationOptions?) async throws {
        let responseStream = if let options {
            session.streamResponse(to: prompt, options: options)
        } else {
            session.streamResponse(to: prompt)
        }
        var previousLength = 0
        for try await snapshot in responseStream {
            let fullContent = snapshot.content
            if fullContent.count > previousLength {
                let newContent = String(fullContent.dropFirst(previousLength))
                print(newContent, terminator: "")
                fflush(stdout)
                previousLength = fullContent.count
            }
        }
    }

    @available(macOS 26, *)
    private func bufferedResponse(session: LanguageModelSession, prompt: String, options: GenerationOptions?) async throws {
        let response = if let options {
            try await session.respond(to: prompt, options: options)
        } else {
            try await session.respond(to: prompt)
        }
        print(response.content, terminator: "")
    }

    @available(macOS 26, *)
    private func availabilityMessage(for availability: SystemLanguageModel.Availability) -> String {
        switch availability {
        case .available:
            return "Model is available."
        case .unavailable(.appleIntelligenceNotEnabled):
            return "Apple Intelligence must be enabled in System Settings."
        case .unavailable(.modelNotReady):
            return "The on-device model isn't ready yet."
        case .unavailable(.deviceNotEligible):
            return "Your device doesn't support Apple Intelligence."
        case .unavailable(_):
            return "Foundation Models is unavailable."
        }
    }
}

// Helper to write to stderr
struct StandardError: TextOutputStream {
    mutating func write(_ string: String) {
        fputs(string, stderr)
    }
}

nonisolated(unsafe) var standardError = StandardError()
