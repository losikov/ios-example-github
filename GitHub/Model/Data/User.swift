//
//  User.swift
//  GitHub
//
//  Created by Alexander Losikov on 10/17/20.
//  Copyright © 2020 Alexander Losikov. All rights reserved.
//

import Foundation

struct User {
    let id: Int
    let login: String
    let avatarUrl: String
    let htmlUrl: String
}

extension User: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case login
        case avatarUrl = "avatar_url"
        case htmlUrl = "html_url"
    }
    
}
