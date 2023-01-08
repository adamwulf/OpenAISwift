import Foundation
#if canImport(FoundationNetworking) && canImport(FoundationXML)
import FoundationNetworking
import FoundationXML
#endif

public enum OpenAIError: Error {
    case genericError(error: Error)
    case decodingError(error: Error)
    case serverError(type: String, error: String)
    case invalidContentLength(error: String)
}

public enum OpenAIImageSize: String {
    case x256 = "256x256"
    case x512 = "512x512"
    case x1024 = "1024x1024"
}

public enum OpenAIImageResponesFormat: String {
    case url
    case b64JSON = "b64_json"
}

public class OpenAISwift {
    fileprivate(set) var token: String?

    public init(authToken: String) {
        self.token = authToken
    }
}

extension OpenAISwift {
    /// Send an Image Generation to the OpenAI API
    /// - Parameters:
    ///   - prompt: A text description of the desired image(s). The maximum length is 1000 characters.
    ///   - n: The number of images to generate. Must be between 1 and 10.
    ///   - model: The AI Model to Use. Set to `OpenAIModelType.gpt3(.davinci)` by default which is the most capable model
    ///   - maxTokens: The limit character for the returned response, defaults to 16 as per the API
    ///   - completionHandler: Returns an OpenAI Data Model
    public func sendImageGeneration(with prompt: String,
                                    n: Int = 1,
                                    size: OpenAIImageSize = .x256,
                                    responseFormat: OpenAIImageResponesFormat = .url,
                                    user: String? = nil,
                                    completionHandler: @escaping (Result<OpenAIImageResponse, OpenAIError>) -> Void) {
        assert(prompt.count < 1000, "prompt must be less than 1000 characters")
        let endpoint = Endpoint.imageGenerations
        let body = ImageCommand(prompt: prompt, n: n, size: size.rawValue, responseFormat: responseFormat.rawValue, user: user)
        let request = prepareRequest(endpoint, body: body)

        makeRequest(request: request) { result in
            switch result {
            case .success(let success):
                do {
                    let res = try JSONDecoder().decode(OpenAIImageResponse.self, from: success)
                    completionHandler(.success(res))
                } catch {
                    completionHandler(.failure(.decodingError(error: error)))
                }
            case .failure(let failure):
                completionHandler(.failure(.genericError(error: failure)))
            }
        }
    }

    /// Send a Completion to the OpenAI API
    /// - Parameters:
    ///   - prompt: The Text Prompt
    ///   - model: The AI Model to Use. Set to `OpenAIModelType.gpt3(.davinci)` by default which is the most capable model
    ///   - maxTokens: The limit character for the returned response, defaults to 16 as per the API
    ///   - completionHandler: Returns an OpenAI Data Model
    public func sendCompletion(with prompt: String,
                               suffix: String? = nil,
                               model: OpenAIModelType = .gpt3(.davinci),
                               maxTokens: Int = 16,
                               temperature: Float = 1.0,
                               stop: [String]? = nil,
                               user: String? = nil,
                               completionHandler: @escaping (Result<OpenAI, OpenAIError>) -> Void) {
        let endpoint = Endpoint.completions
        let body = Command(prompt: prompt, suffix: suffix, model: model.modelName, maxTokens: maxTokens, temperature: temperature, stop: stop, user: user)
        let request = prepareRequest(endpoint, body: body)
        
        makeRequest(request: request) { result in
            switch result {
            case .success(let success):
                self.handleResponse(success, completionHandler: completionHandler)
            case .failure(let failure):
                completionHandler(.failure(.genericError(error: failure)))
            }
        }
    }
    
    /// Send a Edit request to the OpenAI API
    /// - Parameters:
    ///   - instruction: The Instruction For Example: "Fix the spelling mistake"
    ///   - model: The Model to use, the only support model is `text-davinci-edit-001`
    ///   - input: The Input For Example "My nam is Adam"
    ///   - completionHandler: Returns an OpenAI Data Model
    public func sendEdits(with instruction: String, model: OpenAIModelType = .feature(.davinci), input: String = "", completionHandler: @escaping (Result<OpenAI, OpenAIError>) -> Void) {
        let endpoint = Endpoint.edits
        let body = Instruction(instruction: instruction, model: model.modelName, input: input)
        let request = prepareRequest(endpoint, body: body)
        
        makeRequest(request: request) { result in
            switch result {
            case .success(let success):
                self.handleResponse(success, completionHandler: completionHandler)
            case .failure(let failure):
                completionHandler(.failure(.genericError(error: failure)))
            }
        }
    }
    
    private func makeRequest(request: URLRequest, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completionHandler(.failure(error))
            } else if let data = data {
                completionHandler(.success(data))
            }
        }
        
        task.resume()
    }
    
    private func prepareRequest<BodyType: Encodable>(_ endpoint: Endpoint, body: BodyType) -> URLRequest {
        var urlComponents = URLComponents(url: URL(string: endpoint.baseURL())!, resolvingAgainstBaseURL: true)
        urlComponents?.path = endpoint.path
        var request = URLRequest(url: urlComponents!.url!)
        request.httpMethod = endpoint.method
        
        if let token = self.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(body) {
            request.httpBody = encoded
        }
        
        return request
    }

    private func handleResponse(_ success: Data, completionHandler: @escaping (Result<OpenAI, OpenAIError>) -> Void) {
        do {
            let res = try JSONDecoder().decode(OpenAI.self, from: success)
            completionHandler(.success(res))
        } catch {
            if let json = try? JSONSerialization.jsonObject(with: success) as? [String: Any],
               let error = json["error"] as? [String: Any],
               let message = error["message"] as? String,
               let type = error["type"] as? String {
                if type == "invalid_request_error",
                   message.contains("maximum context length") {
                    completionHandler(.failure(.invalidContentLength(error: message)))
                } else {
                    completionHandler(.failure(.serverError(type: type, error: message)))
                }
            } else {
                completionHandler(.failure(.decodingError(error: error)))
            }
        }
    }
}

extension OpenAISwift {
    /// Send a Completion to the OpenAI API
    /// - Parameters:
    ///   - prompt: The Text Prompt
    ///   - model: The AI Model to Use. Set to `OpenAIModelType.gpt3(.davinci)` by default which is the most capable model
    ///   - maxTokens: The limit character for the returned response, defaults to 16 as per the API
    /// - Returns: Returns an OpenAI Data Model
    @available(swift 5.5)
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    public func sendCompletion(with prompt: String, model: OpenAIModelType = .gpt3(.davinci), maxTokens: Int = 16) async throws -> OpenAI {
        return try await withCheckedThrowingContinuation { continuation in
            sendCompletion(with: prompt, model: model, maxTokens: maxTokens) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    /// Send a Edit request to the OpenAI API
    /// - Parameters:
    ///   - instruction: The Instruction For Example: "Fix the spelling mistake"
    ///   - model: The Model to use, the only support model is `text-davinci-edit-001`
    ///   - input: The Input For Example "My nam is Adam"
    ///   - completionHandler: Returns an OpenAI Data Model
    @available(swift 5.5)
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    public func sendEdits(with instruction: String, model: OpenAIModelType = .feature(.davinci), input: String = "", completionHandler: @escaping (Result<OpenAI, OpenAIError>) -> Void) async throws -> OpenAI {
        return try await withCheckedThrowingContinuation { continuation in
            sendEdits(with: instruction, model: model, input: input) { result in
                continuation.resume(with: result)
            }
        }
    }
}
