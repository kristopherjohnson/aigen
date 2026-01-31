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
            """
    )

    @Flag(name: [.short, .long], help: "Show processing details")
    var verbose = false

    @Option(name: [.short, .long], help: "Set system instructions for model (can be repeated)")
    var instruction: [String] = []

    @Option(name: [.short, .long], help: "Add inline text to prompt (can be repeated)")
    var prompt: [String] = []

    @Argument(help: "Input files to read (reads stdin if none provided)")
    var files: [String] = []

    mutating func run() async throws {
        let startTime = Date()
        let input = try readInput()

        if verbose {
            print("Read \(input.count) characters", to: &standardError)
            if !instruction.isEmpty {
                print("Using \(instruction.count) instruction(s)", to: &standardError)
            }
        }

        let instructionsText = instruction.isEmpty ? nil : instruction.joined(separator: "\n")

        let response = try await sendToModel(input, instructions: instructionsText)
        print(response)

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
            return try readStdin()
        }

        var contents: [String] = []

        for promptText in prompt {
            if verbose {
                print("Adding prompt text...", to: &standardError)
            }
            contents.append(promptText)
        }

        for filePath in files {
            if verbose {
                print("Reading \(filePath)...", to: &standardError)
            }
            contents.append(try readFile(at: filePath))
        }

        return contents.joined(separator: "\n")
    }

    private func readFile(at path: String) throws -> String {
        guard FileManager.default.fileExists(atPath: path) else {
            throw ValidationError("File not found: \(path)")
        }
        do {
            return try String(contentsOf: URL(fileURLWithPath: path), encoding: .utf8)
        } catch {
            throw ValidationError("Failed to read file '\(path)': \(error.localizedDescription)")
        }
    }

    private func readStdin() throws -> String {
        var lines: [String] = []
        while let line = readLine(strippingNewline: false) {
            lines.append(line)
        }
        return lines.joined()
    }

    private func sendToModel(_ prompt: String, instructions: String?) async throws -> String {
        guard #available(macOS 26, *) else {
            throw ValidationError("Foundation Models requires macOS 26 or newer.")
        }

        let model = SystemLanguageModel.default

        guard case .available = model.availability else {
            throw ValidationError(availabilityMessage(for: model.availability))
        }

        let session: LanguageModelSession
        if let instructions {
            session = LanguageModelSession { instructions }
        } else {
            session = LanguageModelSession()
        }

        let response = try await session.respond(to: prompt)
        return response.content
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
