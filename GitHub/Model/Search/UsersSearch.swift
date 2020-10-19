//
//  UsersSearch.swift
//  GitHub
//
//  Created by Alexander Losikov on 10/17/20.
//  Copyright © 2020 Alexander Losikov. All rights reserved.
//

import Foundation

/// Users Search URL implementation
class UsersSearch: Search<User> {

    override func searchURL(for name: String, page: Int) -> URL? {
        guard let escapedName = name.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) else { return nil }
        
        let url = "https://api.github.com/search/users?q=\(escapedName)&per_page=\(perPage)&page=\(page)"
        return URL(string: url)
    }
    
}
