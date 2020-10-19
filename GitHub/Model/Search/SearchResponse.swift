//
//  SearchResponse.swift
//  GitHub
//
//  Created by Alexander Losikov on 10/17/20.
//  Copyright © 2020 Alexander Losikov. All rights reserved.
//

import Foundation

/// Data structure returned to UI
struct SearchResponse<Item> {
    /// Search name
    let name: String

    let items: [Item]
    
    /// indexes of added objects with next page update
    let indexes: [Int]?
    
    let isNextPageAvailable: Bool
}
