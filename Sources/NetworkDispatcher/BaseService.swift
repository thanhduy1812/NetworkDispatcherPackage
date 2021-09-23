//
//  File.swift
//  
//
//  Created by Duy Nguyen on 22/09/2021.
//

import Foundation

public protocol BaseService {
    var networkRequest: Requestable! { get }
    var environment: EnvironmentProtocol! { get }
    init(networkRequest: Requestable, environment: EnvironmentProtocol)

}
