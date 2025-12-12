import SwiftUI

struct ParticipantRowView: View {
    let person: Person
    let canDelete: Bool
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .foregroundColor(.blue)
            VStack(alignment: .leading) {
                Text(person.name)
                    .fontWeight(.semibold)
                Text(person.email)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            if canDelete {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(10)
    }
}
