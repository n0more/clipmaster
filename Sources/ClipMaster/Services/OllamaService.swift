import Foundation

// Service for interacting with the Ollama API.
@MainActor
class OllamaService {
    
    private let generateUrl = URL(string: "http://localhost:11434/api/generate")!
    private let tagsUrl = URL(string: "http://localhost:11434/api/tags")!
    
    // Request/Response for the 'generate' endpoint.
    private struct OllamaRequest: Codable {
        let model: String
        let prompt: String
        let stream: Bool
        let options: [String: Double]
    }
    
    private struct OllamaResponse: Codable {
        let response: String
    }
    
    // Response structure for the 'tags' endpoint.
    private struct OllamaTagsResponse: Codable {
        let models: [OllamaModel]
    }
    
    struct OllamaModel: Codable {
        let name: String
    }
    
    // The generate function now accepts a model and temperature.
    func generate(prompt: String, model: String, temperature: Double) async throws -> String {
        print("[OllamaService] Sending prompt to Ollama with model \(model) and temperature \(temperature)...")
        
        var request = URLRequest(url: generateUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = OllamaRequest(
            model: model,
            prompt: prompt,
            stream: false,
            options: ["temperature": temperature]
        )
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            let responseBody = String(data: data, encoding: .utf8) ?? "No response body"
            print("[OllamaService] Error: Received non-2xx HTTP status: \(httpResponse.statusCode). Response: \(responseBody)")
            throw URLError(.badServerResponse)
        }
        
        let decodedResponse = try JSONDecoder().decode(OllamaResponse.self, from: data)
        return self.cleanResponse(decodedResponse.response)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // Fetches the list of available models from the Ollama API.
    func fetchAvailableModels() async -> [String] {
        print("[OllamaService] Fetching available models...")
        do {
            let (data, _) = try await URLSession.shared.data(from: tagsUrl)
            let decodedResponse = try JSONDecoder().decode(OllamaTagsResponse.self, from: data)
            let modelNames = decodedResponse.models.map { $0.name }
            print("[OllamaService] Found models: \(modelNames)")
            return modelNames
        } catch {
            print("[OllamaService] Error fetching or decoding models: \(error)")
            return []
        }
    }
    
    private func cleanResponse(_ text: String) -> String {
        do {
            let regex = try NSRegularExpression(pattern: "<think>.*?</think>", options: .dotMatchesLineSeparators)
            let range = NSRange(text.startIndex..., in: text)
            return regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: "")
        } catch {
            print("[OllamaService] Error creating regex for cleaning: \(error)")
            return text
        }
    }
}
