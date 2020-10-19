//
//  PackegesCollectionViewController.swift
//  GitHub
//
//  Created by Alexander Losikov on 10/17/20.
//  Copyright © 2020 Alexander Losikov. All rights reserved.
//

import UIKit

class UsersCollectionViewController: UIViewController {
    
    // MARK: - Properties
    private let data = UsersSearch()
    
    /// current search name, to match with response from search API which are async
    private var searchName: String = ""
    /// search name for which current data is already displayed in tableView
    private var displayedSearchName: String = ""
    private var items: [User] = []
    private var isNextPageAvailable = false
    
    lazy var logo: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "Logo").withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .brandAero
        return imageView
    }()
    
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search User"
        return searchController
    }()
    
    lazy var collectionView: UICollectionView = {
        let usersCollectionViewLayout = UsersCollectionViewLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: usersCollectionViewLayout)
        collectionView.register(UserCollectionViewCell.self, forCellWithReuseIdentifier: "UserCollectionViewCell")
        collectionView.backgroundColor = .secondaryBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
}

// MARK: - UI Setup
extension UsersCollectionViewController {
    private func setupUI() {
        // logo
        navigationItem.titleView = logo
        
        // navigation bar
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.backgroundColor = .primaryBackground
        
        // search controller
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // collection view
        self.view.addSubview(collectionView)
        collectionView.prefetchDataSource = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}

// MARK: - UISearchResultsUpdating
extension UsersCollectionViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        if text == "" {
            items = []
            isNextPageAvailable = false
            self.collectionView.reloadData()
        } else {
            search(text, nextPage: false)
        }
    }
    
}

// MARK: - Users Search Data source
private extension UsersCollectionViewController {
    
    func user(for indexPath: IndexPath) -> User? {
        return items[indexPath.row]
    }
    
    func isNextPageCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= items.count
    }
    
    func search(_ name: String, nextPage: Bool) {
        self.searchName = name
        
        data.search(for: name, nextPage: nextPage) {[weak self] response in
            switch response {
            case .error(let error):
                print("Error: '\(error)'.")
                
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
                
            case .data(let data):
                // response may come when another search string is active already
                if (data.name == self?.searchName) {
                    self?.items = data.items
                    self?.isNextPageAvailable = data.isNextPageAvailable
                    
                    // TODO: insert cells for next page, instead of reloadData()
                    
                    // if new data to display
                    self?.displayedSearchName = data.name
                    self?.collectionView.reloadData()
                }
            }
        }
    }
    
}

// MARK: - UICollectionViewDataSourcePrefetching
extension UsersCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if !isNextPageCell(for: indexPath) {
                let m = user(for: indexPath)!
                
                UIImageView().loadImageWithUrl(string: m.avatarUrl,
                                               placeholder: #imageLiteral(resourceName: "placeholder"),
                                               startedHandler: {},
                                               completionHandler: {image in})
            }
        }
        
    }
}

// MARK: - UICollectionViewDelegate & DataSource
extension UsersCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count + (isNextPageAvailable == true ? 1 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCollectionViewCell", for: indexPath) as! UserCollectionViewCell
        
        if isNextPageCell(for: indexPath) {
            cell.configure(with: .none)
            search(searchName, nextPage: true)
        } else {
            let u = user(for: indexPath)!
            cell.configure(with: u)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isNextPageCell(for: indexPath) {
            let u = user(for: indexPath)!
            
            if let url = URL(string: u.htmlUrl) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url as URL)
                }
            }
        }
    }
    
}
