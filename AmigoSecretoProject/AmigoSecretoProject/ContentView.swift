import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SecretSantaViewModel()
    @StateObject private var coordinator = AppCoordinator()
    @State private var newName = ""
    @State private var newEmail = ""
    @State private var isDrawn = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    HeaderView()
                    
                    if !isDrawn {
                        AddParticipantView(
                            name: $newName,
                            email: $newEmail,
                            onAdd: addParticipant
                        )
                    }
                    
                    ParticipantsListView(
                        participants: viewModel.participants,
                        canDelete: !isDrawn,
                        onDelete: deleteParticipant
                    )
                    
                    ActionButtonsView(
                        isDrawn: isDrawn,
                        participantsCount: viewModel.participants.count,
                        isSending: viewModel.isSending,
                        onDraw: performDraw,
                        onSendEmails: sendEmails,
                        onReset: resetDraw
                    )
                }
                .padding()
            }
            .navigationBarHidden(true)
            .alert(isPresented: $viewModel.showingAlert) {
                Alert(
                    title: Text("Amigo Secreto"),
                    message: Text(viewModel.alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func addParticipant() {
        viewModel.addParticipant(name: newName, email: newEmail)
        newName = ""
        newEmail = ""
    }
    
    private func deleteParticipant(_ person: Person) {
        if let index = viewModel.participants.firstIndex(of: person) {
            viewModel.removeParticipant(at: IndexSet(integer: index))
        }
    }
    
    private func performDraw() {
        if viewModel.performDraw() {
            isDrawn = true
        }
    }
    
    private func sendEmails() {
        Task {
            await viewModel.sendMessages()
        }
    }
    
    private func resetDraw() {
        isDrawn = false
        viewModel.reset()
    }
}

#Preview {
    ContentView()
}
