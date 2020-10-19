//
//  NetworkIndicator.swift
//  GitHub
//
//  Created by Alexander Losikov on 10/17/20.
//  Copyright © 2020 Alexander Losikov. All rights reserved.
//

import UIKit

/// Singleton to show/hide "network activity indicator" in status bar
class NetworkIndicator {
    /// Instance Accessor
    static let shared = NetworkIndicator()
    
    private init() {
    }
    
    private var counter = 0
    
    func activate() {
        counter += 1
        if counter == 1 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }
    
    func deactivate() {
        // in case of bugs outside
        if counter > 0 {
            counter -= 1
        }
        
        if counter == 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
}
