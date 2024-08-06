//
//  ViewController.swift
//  Hw24RestApi
//
//  Created by Кирилл Курочкин on 02.08.2024.
//

import UIKit

class PersonsViewController: UIViewController {
    
    // MARK: - Properties
    
    private var persons: [Person] = []
    private let apiService = ApiService()
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Person>!
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Person", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.tintColor = UIColor.white
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(showAddPersonView), for: .touchUpInside)
        return button
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete Person", for: .normal)
        button.backgroundColor = UIColor.systemRed
        button.tintColor = UIColor.white
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(deletePersonTapped), for: .touchUpInside)
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        setupUI()
        Task {
            await loadPersons()
        }
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Persons"
        view.backgroundColor = .white
        
        view.addSubview(collectionView)
        view.addSubview(addButton)
        view.addSubview(deleteButton)
        view.addSubview(activityIndicator)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -20),
            
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addButton.bottomAnchor.constraint(equalTo: deleteButton.topAnchor, constant: -10),
            addButton.heightAnchor.constraint(equalToConstant: 50),
            
            deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            deleteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            deleteButton.heightAnchor.constraint(equalToConstant: 50),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func configureCollectionView() {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(100))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            section.interGroupSpacing = 10
            return section
        }
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(PersonCell.self, forCellWithReuseIdentifier: PersonCell.reuseIdentifier)
        collectionView.delegate = self
        
        dataSource = UICollectionViewDiffableDataSource<Section, Person>(collectionView: collectionView) { collectionView, indexPath, person in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PersonCell.reuseIdentifier, for: indexPath) as? PersonCell else {
                fatalError("Unable to dequeue PersonCell")
            }
            cell.configure(with: person)
            return cell
        }
    }
    
    // MARK: - Data Loading
    
    private func loadPersons() async {
        activityIndicator.startAnimating()
        do {
            persons = try await apiService.getAllPersons()
            updateDataSource()
        } catch {
            showError(error.localizedDescription)
        }
        activityIndicator.stopAnimating()
    }
    
    private func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Person>()
        snapshot.appendSections([.main])
        snapshot.appendItems(persons)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    
    @objc private func showAddPersonView() {
        let addPersonVC = AddPersonViewController()
        addPersonVC.delegate = self
        navigationController?.pushViewController(addPersonVC, animated: true)
    }
    

    @objc private func deletePersonTapped() {
        // Delete the first person in the list as an example
        guard let firstPerson = persons.first else { return }
        Task {
            do {
                try await apiService.deletePerson()
                await loadPersons()
            } catch {
                showError(error.localizedDescription)
            }
        }
    }
}
    

// MARK: - Collection View Delegate

extension PersonsViewController: UICollectionViewDelegate {}

// MARK: - Add Person Delegate

extension PersonsViewController: AddPersonDelegate {
    func didAddPerson(firstName: String, lastName: String, email: String) {
        Task {
            do {
                try await apiService.newPerson(firstName: firstName, lastName: lastName, email: email)
                await loadPersons()
            } catch {
                showError(error.localizedDescription)
            }
        }
    }
}

// MARK: - Section Enum

private enum Section {
    case main
}
