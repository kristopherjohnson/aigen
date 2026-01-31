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
            """
    )

    @Flag(name: [.short, .long], help: "Show processing details")
    var verbose = false

    @Option(name: [.short, .long], help: "Add inline text to prompt (can be repeated)")
    var prompt: [String] = []

    @Argument(help: "Input files to read (reads stdin if none provided)")
    var files: [String] = []

    mutating func run() async throws {
        let startTime = Date()
        let input = try readInput()

        if verbose {
            print("Read \(input.count) characters", to: &standardError)
        }

        let response = try await sendToModel(input)
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

        for (index, promptText) in prompt.enumerated() {
            if verbose {
                print("Adding prompt text #\(index + 1)...", to: &standardError)
            }
            contents.append(promptText)
        }

        for filePath in files {
            if verbose {
                print("Reading \(filePath)...", to: &standardError)
            }
            guard FileManager.default.fileExists(atPath: filePath) else {
                throw ValidationError("File not found: \(filePath)")
            }
            let fileURL = URL(fileURLWithPath: filePath)
            do {
                let content = try String(contentsOf: fileURL, encoding: .utf8)
                contents.append(content)
            } catch {
                throw ValidationError("Failed to read file '\(filePath)': \(error.localizedDescription)")
            }
        }

        return contents.joined(separator: "\n")
    }

    private func readStdin() throws -> String {
        var lines: [String] = []
        while let line = readLine(strippingNewline: false) {
            lines.append(line)
        }
        return lines.joined()
    }

    private func sendToModel(_ prompt: String) async throws -> String {
        guard #available(macOS 26, *) else {
            throw ValidationError("Foundation Models requires macOS 26 or newer.")
        }

        let model = SystemLanguageModel.default

        switch model.availability {
        case .available:
            break
        case .unavailable(.appleIntelligenceNotEnabled):
            throw ValidationError("Apple Intelligence must be enabled in System Settings.")
        case .unavailable(.modelNotReady):
            throw ValidationError("The on-device model isn't ready yet.")
        case .unavailable(.deviceNotEligible):
            throw ValidationError("Your device doesn't support Apple Intelligence.")
        case .unavailable(_):
            throw ValidationError("Foundation Models is unavailable.")
        }

        let session = LanguageModelSession()
        let response = try await session.respond(to: prompt)
        return response.content
    }
}

// Helper to write to stderr
struct StandardError: TextOutputStream {
    mutating func write(_ string: String) {
        fputs(string, stderr)
    }
}

nonisolated(unsafe) var standardError = StandardError()
