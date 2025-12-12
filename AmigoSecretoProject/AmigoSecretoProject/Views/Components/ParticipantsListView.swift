import SwiftUI

struct ParticipantsListView: View {
    let participants: [Person]
    let canDelete: Bool
    let onDelete: (Person) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Participantes (\(participants.count))")
                .font(.headline)
            
            if participants.isEmpty {
                emptyStateView
            } else {
                participantsList
            }
        }
        .frame(minHeight: 200)
    }
    
    private var emptyStateView: some View {
        Text("Nenhum participante adicionado")
            .foregroundColor(.gray)
            .italic()
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
    }
    
    private var participantsList: some View {
        VStack(spacing: 8) {
            ForEach(participants) { person in
                ParticipantRowView(
                    person: person,
                    canDelete: canDelete,
                    onDelete: { onDelete(person) }
                )
            }
        }
    }
}
