//
//  File.swift
//  
//
//  Created by Duy Nguyen on 22/09/2021.
//

import Foundation

public enum Environment: String, CaseIterable {
    case development
    case staging
    case production
}

extension Environment {
    //Example baseUrl
    var serviceBaseUrl: String {
        switch self {
        case .development:
            return "https://dummyapi.io/data/v1"
        case .staging:
            return "https://stg-combine.com/data/v1"
        case .production:
            return "https://combine.com/data/v1"
        }
    }
}
