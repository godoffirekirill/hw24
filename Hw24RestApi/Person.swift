//
//  Person.swift
//  Hw24RestApi
//
//  Created by Кирилл Курочкин on 02.08.2024.
//


import Foundation

struct Person: Codable, Identifiable, Hashable {
    var id: Int
    var firstName: String
    var lastName: String
    var email: String
}
