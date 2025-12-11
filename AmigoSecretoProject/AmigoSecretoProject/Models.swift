//
//  Models.swift
//  AmigoSecretoProject
//
//  Created by Lucas Dal Pra Brascher on 11/12/25.
//

import Foundation

struct Person: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var email: String
}

struct Assignment {
    let giver: Person
    let receiver: Person
}
