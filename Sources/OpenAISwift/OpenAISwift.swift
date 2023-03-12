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
    fileprivate var taskCache: [DataTaskDelegate] = []

    public init(authToken: String) {
        self.token = authToken
    }
}

public enum OpenAIChatRole: String, Encodable {
    case system
    case user
    case assistant
}

public struct OpenAIChatMessage: Encodable {
    let role: OpenAIChatRole
    let content: String

    public init(role: OpenAIChatRole, content: String) {
        self.role = role
        self.content = content
    }
}

extension OpenAISwift {
    /// Send a Chat Completion to the OpenAI API
    /// - Parameters:
    ///   - messages: The Text Prompt
    ///   - model: The AI Model to Use. Set to `OpenAIModelType.gpt3(.davinci)` by default which is the most capable model
    ///   - maxTokens: The limit character for the returned response, defaults to 16 as per the API
    ///   - completionHandler: Returns an OpenAI Data Model
    public func sendCompletion(with messages: [OpenAIChatMessage],
                               model: CompletionsModel = .gpt35(.stable),
                               maxTokens: Int = 16,
                               temperature: Float = 1.0,
                               stop: [String]? = nil,
                               user: String? = nil,
                               completionHandler: @escaping (Result<ChatResponse, OpenAIError>) -> Void) {
        let endpoint = Endpoint.chat
        let body = ChatCompletionParams(messages: messages, model: model.modelName, maxTokens: maxTokens, temperature: temperature, stop: stop, user: user)
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
                                    completionHandler: @escaping (Result<ImageResponse, OpenAIError>) -> Void) {
        assert(prompt.count < 1000, "prompt must be less than 1000 characters")
        let endpoint = Endpoint.imageGenerations
        let body = ImageParams(prompt: prompt, n: n, size: size.rawValue, responseFormat: responseFormat.rawValue, user: user)
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

    /// Send a Completion to the OpenAI API
    /// - Parameters:
    ///   - prompt: The Text Prompt
    ///   - model: The AI Model to Use. Set to `OpenAIModelType.gpt3(.davinci)` by default which is the most capable model
    ///   - maxTokens: The limit character for the returned response, defaults to 16 as per the API
    ///   - completionHandler: Returns an OpenAI Data Model
    public func sendCompletion(with prompt: String,
                               suffix: String? = nil,
                               model: CompletionsModel = .gpt3(.davinci),
                               maxTokens: Int = 16,
                               temperature: Float = 1.0,
                               stop: [String]? = nil,
                               user: String? = nil,
                               completionHandler: @escaping (Result<TextResponse, OpenAIError>) -> Void) {
        let endpoint = Endpoint.completions
        let body = CompletionParams(prompt: prompt, suffix: suffix, model: model.modelName, maxTokens: maxTokens, temperature: temperature, stop: stop, user: user)
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
    public func sendEdits(with instruction: String,
                          input: String,
                          model: EditsModel = .davinciText,
                          temperature: Float = 1.0,
                          completionHandler: @escaping (Result<TextResponse, OpenAIError>) -> Void) {
        let endpoint = Endpoint.edits
        let body = EditParams(instruction: instruction, input: input, model: model.modelName, temperature: temperature)
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
    public func sendEmbedding(for input: String, model: EmbeddingModel = .adaV2, completionHandler: @escaping (Result<EmbeddingResponse, OpenAIError>) -> Void) {
        let endpoint = Endpoint.embeddings
        let body = EmbeddingParams(input: input, model: model.modelName)
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

    private func handleResponse<T: OpenAIResponse>(_ success: Data, completionHandler: @escaping (Result<T, OpenAIError>) -> Void) {
        do {
            let res = try JSONDecoder().decode(T.self, from: success)
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
    /// Send a Chat Completion to the OpenAI API
    /// - Parameters:
    ///   - messages: The Text Prompt
    ///   - model: The AI Model to Use. Set to `OpenAIModelType.gpt3(.davinci)` by default which is the most capable model
    ///   - maxTokens: The limit character for the returned response, defaults to 16 as per the API
    ///   - completionHandler: Returns an OpenAI Data Model
    public func realtimeCompletion(with messages: [OpenAIChatMessage],
                                   model: CompletionsModel = .gpt35(.stable),
                                   maxTokens: Int = 16,
                                   temperature: Float = 1.0,
                                   stop: [String]? = nil,
                                   user: String? = nil,
                                   updateHandler:  @escaping (String) -> Void,
                                   completionHandler: @escaping (Result<String, OpenAIError>) -> Void) {
        let endpoint = Endpoint.chat
        let body = ChatCompletionParams(messages: messages, model: model.modelName, maxTokens: maxTokens, temperature: temperature, stop: stop, user: user, stream: true)
        let request = prepareRequest(endpoint, body: body)

        let delegate = DataTaskDelegate()
        delegate.didReceiveUpdate = { str in
            updateHandler(str)
        }
        delegate.didComplete = { message, error in
            if let error = error {
                completionHandler(.failure(.genericError(error: error)))
            } else if let message = message {
                completionHandler(.success(message.content))
            }
        }
        let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
        let task = session.dataTask(with: request)
        self.taskCache.append(delegate)
        task.resume()
    }
}

extension OpenAISwift {
    /// Send a Chat Completion to the OpenAI API
    /// - Parameters:
    ///   - messages: The Text Prompt
    ///   - model: The AI Model to Use. Set to `OpenAIModelType.gpt3(.davinci)` by default which is the most capable model
    ///   - maxTokens: The limit character for the returned response, defaults to 16 as per the API
    ///   - completionHandler: Returns an OpenAI Data Model
    public func realtimeCompletion(with messages: [OpenAIChatMessage],
                                   model: CompletionsModel = .gpt35(.stable),
                                   maxTokens: Int = 16,
                                   temperature: Float = 1.0,
                                   stop: [String]? = nil,
                                   user: String? = nil) -> AsyncStream<String> {
        return AsyncStream<String> { continuation in
            realtimeCompletion(with: messages, model: model, maxTokens: maxTokens, temperature: temperature, stop: stop, user: user) { update in
                continuation.yield(update)
            } completionHandler: { result in
                continuation.finish()
            }
        }
    }


    /// Send a Chat Completion to the OpenAI API
    /// - Parameters:
    ///   - messages: The Text Prompt
    ///   - model: The AI Model to Use. Set to `OpenAIModelType.gpt3(.davinci)` by default which is the most capable model
    ///   - maxTokens: The limit character for the returned response, defaults to 16 as per the API
    @available(swift 5.5)
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    public func sendCompletion(with messages: [OpenAIChatMessage],
                               model: CompletionsModel = .gpt35(.stable),
                               maxTokens: Int = 16,
                               temperature: Float = 1.0,
                               stop: [String]? = nil,
                               user: String? = nil) async throws -> ChatResponse {
        return try await withCheckedThrowingContinuation { continuation in
            sendCompletion(with: messages,
                           model: model,
                           maxTokens: maxTokens,
                           temperature: temperature,
                           stop: stop,
                           user: user) { result in
                continuation.resume(with: result)
            }
        }
    }

    /// Send an Image Generation to the OpenAI API
    /// - Parameters:
    ///   - prompt: A text description of the desired image(s). The maximum length is 1000 characters.
    ///   - n: The number of images to generate. Must be between 1 and 10.
    ///   - model: The AI Model to Use. Set to `OpenAIModelType.gpt3(.davinci)` by default which is the most capable model
    ///   - maxTokens: The limit character for the returned response, defaults to 16 as per the API
    @available(swift 5.5)
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    public func sendImageGeneration(with prompt: String,
                                    n: Int = 1,
                                    size: OpenAIImageSize = .x256,
                                    responseFormat: OpenAIImageResponesFormat = .url,
                                    user: String? = nil) async throws -> ImageResponse {
        let foo = try await withCheckedThrowingContinuation { continuation in
            sendImageGeneration(with: prompt,
                                n: n,
                                size: size,
                                responseFormat: responseFormat,
                                user: user) { result in
                continuation.resume(with: result)
            }
        }
        return foo
    }

    /// Send a Completion to the OpenAI API
    /// - Parameters:
    ///   - prompt: The Text Prompt
    ///   - model: The AI Model to Use. Set to `OpenAIModelType.gpt3(.davinci)` by default which is the most capable model
    ///   - maxTokens: The limit character for the returned response, defaults to 16 as per the API
    /// - Returns: Returns an OpenAI Data Model
    @available(swift 5.5)
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    public func sendCompletion(with prompt: String,
                               suffix: String? = nil,
                               model: CompletionsModel = .gpt3(.davinci),
                               maxTokens: Int = 16,
                               temperature: Float = 1.0,
                               stop: [String]? = nil,
                               user: String? = nil) async throws -> TextResponse {
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
    @available(swift 5.5)
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    public func sendEdits(with instruction: String,
                          input: String,
                          model: EditsModel = .davinciText,
                          temperature: Float = 1.0) async throws -> TextResponse {
        return try await withCheckedThrowingContinuation { continuation in
            sendEdits(with: instruction, input: input, model: model) { result in
                continuation.resume(with: result)
            }
        }
    }
}


@available(macOS 13.0, *)
public class DataTaskDelegate: NSObject, URLSessionDataDelegate {
    var receivedData = Data()
    var role: OpenAIChatRole = .assistant
    var receivedString = ""
    var didReceiveUpdate: ((String) -> Void)?
    var didComplete: (((role: OpenAIChatRole, content: String)?, Error?) -> Void)?

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        receivedData.append(data)
        guard let str = String(data: receivedData, encoding: .utf8) else { return }
        var messages = str.components(separatedBy: "\n\n")
        while var message = messages.first {
            guard message.hasPrefix("data:") else {
                messages.removeFirst()
                continue
            }
            do {
                message.trimPrefix("data:")
                let res = try JSONDecoder().decode(RealtimeChatUpdate.self, from: Data(message.utf8))
                if let content = res.choices.first?.delta.role {
                    if let updatedRole = OpenAIChatRole(rawValue: content) {
                        self.role = updatedRole
                    } else {
                        print("unknown role: \(content)")
                    }
                }
                if let content = res.choices.first?.delta.content {
                    receivedString += content
                }
            } catch {
                // noop
            }
            messages.removeFirst()
        }
        receivedData = Data(messages.joined(separator: "\n\n").utf8)
        didReceiveUpdate?(receivedString)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            // Handle the error here
            didComplete?(nil, error)
        } else {
            // The task completed successfully
            didComplete?((role: role, content: receivedString), nil)
        }
    }
}
