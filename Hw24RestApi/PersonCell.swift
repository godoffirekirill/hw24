//
//  PersonCell.swift
//  Hw24RestApi
//
//  Created by Кирилл Курочкин on 02.08.2024.
//

import UIKit

class PersonCell: UICollectionViewCell {
    
    // MARK: - Properties
    static let identifier = "PersonCell"
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    private let container: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Views
    private func setupViews() {
        contentView.addSubview(container)
        container.addSubview(nameLabel)
        container.addSubview(emailLabel)
        
        container.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            emailLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configure
    func configure(with person: Person) {
        nameLabel.text = "\(person.firstName) \(person.lastName)"
        emailLabel.text = person.email
    }
}
