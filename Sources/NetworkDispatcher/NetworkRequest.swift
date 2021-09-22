//
//  File.swift
//  
//
//  Created by Duy Nguyen on 22/09/2021.
//

import Foundation

public struct NetworkRequest {

    
    var endpoint: Endpoint
    var headers: [String: String]? = [:]
    var body: Encodable?
    var requestTimeOut: Float = 30
    var httpMethod: HTTPMethod = .GET
    
    public init(endpoint: Endpoint, headers: [String : String]? = [:], body: Encodable? = nil, requestTimeOut: Float = 30, httpMethod: HTTPMethod = .GET) {
        self.endpoint = endpoint
        self.headers = headers
        self.body = body
        self.requestTimeOut = requestTimeOut
        self.httpMethod = httpMethod
    }

    func buildURLRequest() -> URLRequest? {
        var urlRequest = URLRequest(url: endpoint.url)
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpBody = body?.encode()
        return urlRequest
    }
}

public enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

public enum NetworkError: Error, Equatable {
    case invalidRequest
    case forbidden
    case notFound
    case error4xx(_ code: Int)
    case error5xx(_ code: Int)
    case decodingError
    case badRequest
    case unauthorized
//    case serverError
    case urlSessionFailed(_ error: URLError)
    case badURL(_ error: String)
    case apiError(code: Int, error: String)
    case invalidJSON(_ error: String)
    case invalidHostName(code: Int, error: String)
//    case unauthorized(code: Int, error: String)
//    case badRequest(code: Int, error: String)
    case serverError(code: Int, error: String)
    case noResponse(_ error: String)
    case unableToParseData(_ error: String)
    case responseError(code: String, error: String)
    case unknown(code: Int, error: String)
}


extension Encodable {
    func encode() -> Data? {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            return nil
        }
    }
}
