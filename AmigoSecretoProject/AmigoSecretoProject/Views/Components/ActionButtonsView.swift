import SwiftUI

struct ActionButtonsView: View {
    let isDrawn: Bool
    let participantsCount: Int
    let isSending: Bool
    let onDraw: () -> Void
    let onSendEmails: () -> Void
    let onReset: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            if !isDrawn {
                drawButton
            } else {
                sendEmailsButton
                resetButton
            }
        }
        .padding(.top, 20)
    }
    
    private var drawButton: some View {
        Button(action: onDraw) {
            Label("Sortear Amigo Secreto", systemImage: "shuffle.circle.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(participantsCount >= 2 ? Color.green : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(15)
        }
        .disabled(participantsCount < 2)
    }
    
    private var sendEmailsButton: some View {
        Button(action: onSendEmails) {
            HStack {
                if isSending {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
                Label(
                    isSending ? "Enviando..." : "Enviar Emails",
                    systemImage: "envelope.fill"
                )
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSending ? Color.gray : Color.purple)
            .foregroundColor(.white)
            .cornerRadius(15)
        }
        .disabled(isSending)
    }
    
    private var resetButton: some View {
        Button(action: onReset) {
            Label("Fazer Novo Sorteio", systemImage: "arrow.counterclockwise")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(15)
        }
    }
}
