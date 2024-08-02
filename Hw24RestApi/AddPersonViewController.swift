//
//  AddPersonViewController.swift
//  Hw24RestApi
//
//  Created by Кирилл Курочкин on 02.08.2024.
//

import UIKit

protocol AddPersonDelegate: AnyObject {
    func didAddPerson(firstName: String, lastName: String, email: String)
}

class AddPersonViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: AddPersonDelegate?
    
    private lazy var firstNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "First Name"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private lazy var lastNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Last Name"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.keyboardType = .emailAddress
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.tintColor = UIColor.white
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [firstNameTextField, lastNameTextField, emailTextField, addButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        guard let firstName = firstNameTextField.text, !firstName.isEmpty,
              let lastName = lastNameTextField.text, !lastName.isEmpty,
              let email = emailTextField.text, !email.isEmpty else {
            showAlert(title: "Missing Information", message: "Please fill all fields.")
            return
        }
        
        delegate?.didAddPerson(firstName: firstName, lastName: lastName, email: email)
        dismiss(animated: true, completion: nil)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
