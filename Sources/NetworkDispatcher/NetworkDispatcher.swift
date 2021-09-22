//
//  File.swift
//  
//
//  Created by Duy Nguyen on 22/09/2021.
//

import Foundation
import Combine

public protocol Requestable {
    var requestTimeOut: Float { get }
    func request<T: Codable>(_ req: NetworkRequest) -> AnyPublisher<T, NetworkError>
}

public struct NetworkDispatcher: Requestable {
    
    
    public var requestTimeOut: Float
    
    let urlSession: URLSession!
    public init(urlSession: URLSession = .shared, requestTimeOut: Float = 30) {
        self.urlSession = urlSession
        self.requestTimeOut = requestTimeOut
    }
    
    /// Dispatches an URLRequest and returns a publisher
    /// - Parameter request: URLRequest
    /// - Returns: A publisher with the provided decoded data or an error
    func request<T>(_ req: URLRequest) -> AnyPublisher<T, NetworkError> where T : Decodable, T : Encodable {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = TimeInterval(self.requestTimeOut )
        
        return urlSession
            .dataTaskPublisher(for: req)
            // Map on Request response
            .tryMap({ data, response in
                // If the response is invalid, throw an error
                if let response = response as? HTTPURLResponse,
                   !(200...299).contains(response.statusCode) {
                    throw httpError(response.statusCode)
                }
                // Return Response data
                return data
            })
            // Decode data using our ReturnType
            .decode(type: T.self, decoder: JSONDecoder())
            // Handle any decoding errors
            .mapError { error in
                handleError(error)
            }
            // And finally, expose our publisher
            .eraseToAnyPublisher()
    }
    
    /// Dispatches an URLRequest and returns a publisher
    /// - Parameter request: NetworkRequest
    /// - Returns: A publisher with the provided decoded data or an error
    public func request<T>(_ req: NetworkRequest) -> AnyPublisher<T, NetworkError> where T : Decodable, T : Encodable {
        guard let request = req.buildURLRequest() else {
            return Fail(outputType: T.self, failure: NetworkError.badRequest).eraseToAnyPublisher()
        }
        typealias RequestPublisher = AnyPublisher<T, NetworkError>
        let publisher: RequestPublisher = self.request(request)
        return publisher
    }
}


extension NetworkDispatcher {
    /// Parses a HTTP StatusCode and returns a proper error
    /// - Parameter statusCode: HTTP status code
    /// - Returns: Mapped Error
    private func httpError(_ statusCode: Int) -> NetworkError {
        switch statusCode {
        case 400: return .badRequest
        case 401: return .unauthorized
        case 403: return .forbidden
        case 404: return .notFound
        case 402, 405...499: return .error4xx(statusCode)
        case 500: return .serverError(code: 0,error: "server error")
        case 501...599: return .error5xx(statusCode)
        case -1003: return .apiError(code: -1003, error: "Hostname could not be found")
        default: return .unknown(code: -1, error: "unknown error")
        }
    }
    
    /// Parses URLSession Publisher errors and return proper ones
    /// - Parameter error: URLSession publisher error
    /// - Returns: Readable NetworkRequestError
    private func handleError(_ error: Error) -> NetworkError {
        switch error {
        case is Swift.DecodingError:
            return .decodingError
        case let urlError as URLError:
            return .urlSessionFailed(urlError)
        case let error as NetworkError:
            return error
        case let nsError as NSError:
            return .apiError(code: nsError.code, error: nsError.localizedDescription)
        default:
            return .unknown(code: -1, error: "unknown error")
        }
    }
}
