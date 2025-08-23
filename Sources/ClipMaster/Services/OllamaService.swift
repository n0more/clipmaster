import Foundation

// Service for interacting with the Ollama API.
@MainActor
class OllamaService {
    
    private let url = URL(string: "http://localhost:11434/api/generate")!
    
    private struct OllamaRequest: Codable {
        let model: String
        let prompt: String
        let stream: Bool
    }
    
    private struct OllamaResponse: Codable {
        let response: String
    }
    
    func generate(prompt: String) async throws -> String {
        print("[OllamaService] Sending prompt to Ollama...")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = OllamaRequest(model: "gemma3:1b", prompt: prompt, stream: false)
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            print("[OllamaService] Error: Failed to encode request body: \(error)")
            throw error
        }
        
        let data: Data
        let response: URLResponse
        
        do {
            // Perform the network request.
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            // This will catch network errors like "Connection refused".
            print("[OllamaService] Error: Network request failed: \(error.localizedDescription)")
            throw error
        }
        
        // Check for a successful HTTP status code.
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            print("[OllamaService] Error: Received non-2xx HTTP status: \(httpResponse.statusCode)")
            // Log the server's response for debugging.
            if let responseBody = String(data: data, encoding: .utf8) {
                print("[OllamaService] Server response: \(responseBody)")
            }
            throw URLError(.badServerResponse)
        }
        
        // Decode the JSON response.
        do {
            let decodedResponse = try JSONDecoder().decode(OllamaResponse.self, from: data)
            print("[OllamaService] Received successful response.")
            return decodedResponse.response
        } catch {
            print("[OllamaService] Error: Failed to decode JSON response: \(error)")
            // Log the raw data as a string to see what we actually received.
            if let responseBody = String(data: data, encoding: .utf8) {
                print("[OllamaService] Raw response body: \(responseBody)")
            }
            throw error
        }
    }
}
