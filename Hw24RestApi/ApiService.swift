//
//  ApiService.swift
//  Hw24RestApi
//
//  Created by Кирилл Курочкин on 02.08.2024.
//

import Foundation


// Actor for handling API service operations
actor ApiService {
    // Base URL for the API
    private let baseUrl = URL(string: "https://ioscourse.morphe.by/")!
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    // Fetch all persons from the API
    func getAllPersons() async throws -> [Person] {
        let endPointURL = baseUrl.appendingPathComponent("person/all")
        let request = URLRequest(url: endPointURL)
        let (data, _) = try await URLSession.shared.data(for: request)
        let allPersons = try decoder.decode([Person].self, from: data)
        return allPersons
    }
    
    // Fetch a specific person by ID
    func getPerson(id: Int) async throws -> Person {
        let endPointURL = baseUrl.appendingPathComponent("person/get/\(id)")
        let request = URLRequest(url: endPointURL)
        let (data, _) = try await URLSession.shared.data(for: request)
        let onePerson = try decoder.decode(Person.self, from: data)
        return onePerson
    }
    
    // Add a new person to the API
    func newPerson(firstName: String, lastName: String, email: String) async throws {
        struct NewPerson: Codable {
            var firstName: String
            var lastName: String
            var email: String
        }
        
        let endPointURL = baseUrl.appendingPathComponent("person/save")
        var request = URLRequest(url: endPointURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(NewPerson(firstName: firstName, lastName: lastName, email: email))
        _ = try await URLSession.shared.data(for: request)
    }
    

    func deletePerson() async throws {
           //http://ioscourse.morphe.by/person/remove
           let endPointURL = baseUrl.appending(components: "person", "remove")
           let request = URLRequest(url: endPointURL)
           do {
               let (_, _) = try await URLSession.shared.data(for: request)
           } catch {
               print(error)
           }
       }
    
    
}
