//
//  Search.swift
//  GitHub
//
//  Created by Alexander Losikov on 10/17/20.
//  Copyright © 2020 Alexander Losikov. All rights reserved.
//

import Foundation

internal let perPage = 20
internal let maxPages = 5

fileprivate struct Page<Item: Decodable>: Decodable {
    let totalCount: Int
    let items: [Item]
}

fileprivate extension Page {
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
    }
    
}

/// To hold and combine search results for multiple pages.
/// **addNextPage** used to append initial search results or results from next pages.
fileprivate class SearchResponsesHolder<Item: Decodable> {
    
    /// Holds all items; items from next pages are appended in **addNextPage**
    private var items: [Item] = []
    
    /// number of all items - comes from a response
    private var totalCount = 0
    
    /// number of last pages which were loaded
    var lastLoadedPage: Int = 0
    
    /// to prevent loading the same page twice
    var isRequestingPage = true
    
    /// Add results from a loaded page, initial or next
    /// - returns: list of indexes of the objects updated in the storage
    func addNextPage(page: Page<Item>) -> [Int] {
        isRequestingPage = false
        lastLoadedPage += 1
        totalCount = page.totalCount
        
        var indexes = [Int]() // to count new indexes
        for pi in page.items {
            indexes.append(items.count)
            items.append(pi)
        }

        return indexes
    }
    
    /// To convert to a data structure passed to UI
    func searchResponse(for name: String, indexes: [Int]? = nil) -> SearchResponse<Item> {
        func isNextPageAvailable() -> Bool {
            let totalPages = Int(ceil(Double(totalCount)/Double(perPage)))
            let totalAvailablePages = min(maxPages, totalPages)
            return lastLoadedPage < totalAvailablePages
        }
        
        return SearchResponse(name: name, items: items, indexes: indexes, isNextPageAvailable: isNextPageAvailable())
    }
   
}

/// Search Class to fetch any types of Items
class Search<Item: Decodable> {
    
    /// Holds all data [searchString: data]
    private let searchCache = NSCache<NSString, SearchResponsesHolder<Item>>()
    
    typealias SearchCompletionResult = (APIResponse<SearchResponse<Item>>) -> Void
    
    /// Search using overridden searchURL of any item types inside **Page** json
    /// Safe to call multiple times with the same arguments, as it won't make extra API calls.
    /// - parameter name: search string
    /// - parameter nextPage: load next page
    /// - parameter completionHandler: pass **APIResponse<SearchResponse<Item>>**
    final func search(for name: String,
                      nextPage: Bool,
                      completionHandler: @escaping SearchCompletionResult) {
        // check if already performing request for first or next page
        var searchHolder = searchCache.object(forKey: NSString(string: name))
        if searchHolder != nil {
            if searchHolder?.isRequestingPage == true {
                return
            }
            if nextPage == false {
                completionHandler(APIResponse.data(searchHolder!.searchResponse(for: name)))
                return
            }
        } else {
            searchHolder = SearchResponsesHolder()
            searchCache.setObject(searchHolder!, forKey: NSString(string: name))
        }
        
        // to prevent other API calls with the same search string & nextPage argument
        searchHolder!.isRequestingPage = true
        
        NetworkIndicator.shared.activate()
        
        // redefine to cleanup properly
        let completionHandler: SearchCompletionResult = { [weak searchHolder] result in
            DispatchQueue.main.async {
                NetworkIndicator.shared.deactivate()
                
                searchHolder?.isRequestingPage = false
                
                completionHandler(result)
            }
        }
        
        // perform a request
        guard let searchURL = searchURL(for: name, page: searchHolder!.lastLoadedPage + 1) else {
            completionHandler(APIResponse.error(APIError.invalidUrl))
            return
        }
        
        URLSession.shared.dataTask(with: searchURL) { [weak searchHolder] (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                completionHandler(APIResponse.error(error))
                return
            }
            
            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200,
                let data = data
            else {
                completionHandler(APIResponse.error(APIError.invalidAPIResponse))
                return
            }
            
            do {
                //print(try JSONSerialization.jsonObject(with: data, options: []))
                let json = try JSONDecoder().decode(Page<Item>.self, from: data)
                DispatchQueue.main.async {
                    let indexes = searchHolder?.addNextPage(page: json)
                    if searchHolder != nil {
                        let searchResponse = searchHolder!.searchResponse(for: name, indexes: indexes)
                        completionHandler(APIResponse.data(searchResponse))
                    }
                }
            } catch let error as NSError {
                print("Failed to parse response: '\(error)'")
                completionHandler(APIResponse.error(error))
                return
            }
        }.resume()
    }
    
    /// Must be overriden to return search url
    func searchURL(for name: String, page: Int) -> URL? {
        fatalError("must override with URL")
    }
    
}
