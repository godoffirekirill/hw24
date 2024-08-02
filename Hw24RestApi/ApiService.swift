//
//  ApiService.swift
//  Hw24RestApi
//
//  Created by Кирилл Курочкин on 02.08.2024.
//

import Foundation

class ApiService {
    private let baseUrl = URL(string: "https://ioscourse.morphe.by/")!
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    
    func getAllPerson()  async throws -> [Person]{
        let endPointURL = baseUrl.appending(components: "person", "all")
        let request = URLRequest(url: endPointURL)
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let allPerson = try decoder.decode([Person].self, from: data)
            return allPerson
        } catch {
            print(error)
            return []
        }
    }
    
    func getPerson(id: Int) async throws -> Person {
        let endPointURL = baseUrl.appending(components: "person", "get", "\(id)")
        let request = URLRequest(url: endPointURL)
        let (data, response) = try await URLSession.shared.data(for: request)
        let onePerson = try decoder.decode(Person.self, from: data)
        return onePerson
    }
    
    func newPerson(firstName: String, lastName: String, email: String) async throws {
        struct NewPerson: Codable {
            var firstName: String
            var lastName: String
            var email: String
        }
        let endPointURL = baseUrl.appending(components: "person", "save")
        var request = URLRequest(url: endPointURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(NewPerson(firstName: firstName, lastName: lastName, email: email))
        let (data, response) = try await URLSession.shared.data(for: request)
        
    }
    
    func deletePerson() async throws {
        //http://ioscourse.morphe.by/person/remove
        let endPointURL = baseUrl.appending(components: "person", "remove")
        let request = URLRequest(url: endPointURL)
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
        } catch {
            print(error)
        }
    }
}
