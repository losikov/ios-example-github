//
//  UserCollectionViewCell.swift
//  GitHub
//
//  Created by Alexander Losikov on 10/17/20.
//  Copyright © 2020 Alexander Losikov. All rights reserved.
//

import UIKit

class UserCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    var user: User?
    
    lazy var roundedBackgroundView: UIView = {
        let view = UIView()
        view.layer.backgroundColor = UIColor.primaryBackground.cgColor
        view.layer.cornerRadius = .cellRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var avatarImageTag: String?
    lazy var avatarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = .imageRadius
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var loginLabel: UILabel = {
        let label = UILabel()
        label.font = .title
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .brandGiantsClub
        label.backgroundColor = UIColor.secondaryBackground.withAlphaComponent(0.9)
        label.clipsToBounds = true
        label.layer.cornerRadius = .labelRadius
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.isUserInteractionEnabled = true
        roundedBackgroundView.isUserInteractionEnabled = true
        contentView.addSubview(roundedBackgroundView)
        roundedBackgroundView.addSubview(avatarImage)
        roundedBackgroundView.addSubview(activityIndicator)
        roundedBackgroundView.addSubview(loginLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            roundedBackgroundView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            roundedBackgroundView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
            roundedBackgroundView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0),
            roundedBackgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        ])
        
        NSLayoutConstraint.activate([
            avatarImage.topAnchor.constraint(equalTo: roundedBackgroundView.topAnchor, constant: .cellSpacing),
            avatarImage.leftAnchor.constraint(equalTo: roundedBackgroundView.leftAnchor, constant: .cellSpacing),
            avatarImage.rightAnchor.constraint(equalTo: roundedBackgroundView.rightAnchor, constant: -.cellSpacing),
            avatarImage.bottomAnchor.constraint(equalTo: roundedBackgroundView.bottomAnchor, constant: -.cellSpacing)
            
        ])
        
        NSLayoutConstraint.activate([
            loginLabel.leftAnchor.constraint(equalTo: avatarImage.leftAnchor, constant: .cellSpacing),
            loginLabel.rightAnchor.constraint(equalTo: avatarImage.rightAnchor, constant: -.cellSpacing),
            loginLabel.bottomAnchor.constraint(equalTo: avatarImage.bottomAnchor, constant: -.cellSpacing)
        ])
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: roundedBackgroundView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: roundedBackgroundView.centerYAnchor)
        ])
    }
    
    // MARK: - prepareForReuse
    
    override func prepareForReuse() {
        loginLabel.text = ""
        avatarImageTag = ""
        avatarImage.image = #imageLiteral(resourceName: "placeholder")
        activityIndicator.stopAnimating()
    }
    
    // MARK: - Cell Configuration
    public func configure(with user: User?) {
        self.user = user
        
        guard let user = user else {
            return
        }
        
        loginLabel.text = user.login.uppercased()
        
        avatarImageTag = user.avatarUrl
        avatarImage.loadImageWithUrl(string: user.avatarUrl,
                                     placeholder: #imageLiteral(resourceName: "placeholder"),
                                     startedHandler: {
                                        activityIndicator.startAnimating()
                                     },
                                     completionHandler: {[weak self] image in
                                        if self?.avatarImageTag == user.avatarUrl {
                                            self?.activityIndicator.stopAnimating()
                                            self?.avatarImage.image = image
                                        }
                                     })
        
    }
}
