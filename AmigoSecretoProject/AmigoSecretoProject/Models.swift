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
