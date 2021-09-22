//
//  File.swift
//  
//
//  Created by Duy Nguyen on 22/09/2021.
//

import Foundation

public protocol BaseService {
    init(networkRequest: Requestable, environment: Environment)
}
