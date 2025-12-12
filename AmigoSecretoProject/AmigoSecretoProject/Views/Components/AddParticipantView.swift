import SwiftUI

struct AddParticipantView: View {
    @Binding var name: String
    @Binding var email: String
    let onAdd: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Adicionar Participante")
                .font(.headline)
            
            TextField("Nome", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            Button(action: onAdd) {
                Label("Adicionar", systemImage: "plus.circle.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}
