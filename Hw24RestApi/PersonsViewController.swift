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
    
    // MARK: - UI Elements
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 20
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(PersonCell.self, forCellWithReuseIdentifier: PersonCell.identifier)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
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
    
    // MARK: - Actions
    @objc private func showAddPersonView() {
        let addPersonVC = AddPersonViewController()
        addPersonVC.delegate = self
        present(addPersonVC, animated: true, completion: nil)
    }
    
    @objc private func deletePersonTapped() {
        // Delete the first person in the list as an example
        guard persons.first != nil else { return }
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
                self.persons = try await apiService.getAllPerson()
                collectionView.reloadData()
            } catch {
                showError(error.localizedDescription)
            }
            activityIndicator.stopAnimating()
        }
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

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension PersonsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return persons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PersonCell.identifier, for: indexPath) as! PersonCell
        cell.configure(with: persons[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 80)
    }
}
