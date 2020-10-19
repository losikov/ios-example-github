//
//  UIImageView_Caches.swift 
//  GitHub
//
//  Created by Alexander Losikov on 10/17/20.
//  Copyright © 2020 Alexander Losikov. All rights reserved.
//

import UIKit

/// to store downloaded images
private let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func loadImageWithUrl(string urlString: String,
                          placeholder: UIImage?,
                          startedHandler: () -> Void,
                          completionHandler: @escaping (UIImage?) -> Void) {
        if let cachedImage = imageCache.object(forKey: NSString(string: urlString)) {
            self.image = cachedImage
            return
        }
        
        guard let url = URL(string: urlString) else {
            self.image = placeholder
            return
        }

        startedHandler()
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Failed to load image for '\(urlString)': \(error)")
                DispatchQueue.main.async {
                    completionHandler(placeholder)
                }
                return
            }

            guard
                let data = data,
                let image = UIImage(data: data)
                else {
                    print("Invalid image for '\(urlString)'")
                    DispatchQueue.main.async {
                        completionHandler(placeholder)
                    }
                    return
            }
            
            DispatchQueue.main.async {
                completionHandler(image)
            }
        
            imageCache.setObject(image, forKey: NSString(string: urlString))
        }.resume()
    }
    
}
