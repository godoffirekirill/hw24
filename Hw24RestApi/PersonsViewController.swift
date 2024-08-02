//
//  ViewController.swift
//  Hw24RestApi
//
//  Created by Кирилл Курочкин on 02.08.2024.
//

import UIKit


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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        setupUI()
        loadPersons()
    }
    
    // MARK: - UI Setup
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
            addButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addButton.heightAnchor.constraint(equalToConstant: 44),
            
            deleteButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            deleteButton.heightAnchor.constraint(equalToConstant: 44),
            
            collectionView.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func configureCollectionView() {
        // Define the layout
        let layout = createCompositionalLayout()
        
        // Initialize the collection view
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(PersonCell.self, forCellWithReuseIdentifier: PersonCell.identifier)
        
        // Configure the diffable data source
        dataSource = UICollectionViewDiffableDataSource<Section, Person>(collectionView: collectionView) { collectionView, indexPath, person in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PersonCell.identifier, for: indexPath) as! PersonCell
            cell.configure(with: person)
            return cell
        }
        
        collectionView.delegate = self
    }
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .none
            return section
        }
    }
    
    // MARK: - Actions
    @objc private func showAddPersonView() {
        let addPersonVC = AddPersonViewController()
        addPersonVC.delegate = self
        present(addPersonVC, animated: true, completion: nil)
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
    
    // MARK: - Helper Functions
    private func loadPersons() {
        activityIndicator.startAnimating()
        
        Task {
            do {
                let fetchedPersons = try await apiService.getAllPerson()
                self.persons = fetchedPersons
                updateDataSource()
            } catch {
                showError(error.localizedDescription)
            }
            activityIndicator.stopAnimating()
        }
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
}

// MARK: - AddPersonDelegate
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
private extension PersonsViewController {
    enum Section {
        case main
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension PersonsViewController: UICollectionViewDelegate {
    // Implement any delegate methods if needed
}
