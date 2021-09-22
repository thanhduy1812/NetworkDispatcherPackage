//
//  File.swift
//  
//
//  Created by Duy Nguyen on 22/09/2021.
//

import Foundation

public struct Endpoint {
    var path: String
    var environment: Environment!
    var queryItems: [URLQueryItem] = []
    
    public init(path: String = "", environment: Environment, queryItems: [URLQueryItem] = []) {
        self.path = path
        self.environment = environment
        self.queryItems = queryItems
    }
}

extension Endpoint {
    var url: URL {
        let baseUrl = URL(string: environment.serviceBaseUrl)
        var components = URLComponents()
        components.scheme = baseUrl?.scheme
        components.host = baseUrl?.host
        components.path = (baseUrl?.path ?? "") + path
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            preconditionFailure("Invalid URL components: \(components)")
        }
        return url;
    }
}
