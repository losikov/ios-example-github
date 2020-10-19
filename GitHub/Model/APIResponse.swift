//
//  APIResponse.swift
//  GitHub
//
//  Created by Alexander Losikov on 10/17/20.
//  Copyright © 2020 Alexander Losikov. All rights reserved.
//

import Foundation

/// Base structure for all API functions to return a result in a handler
enum APIResponse<DataType> {
    case data(DataType)
    case error(Error)
}
