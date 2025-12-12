import Foundation
import Combine
import SwiftUI

class SecretSantaViewModel: ObservableObject {
    @Published var participants: [Person] = []
    @Published var assignments: [Assignment] = []
    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var isSending = false
    
    // Configuração Resend
    private let resendAPIKey = "re_g4LgvAxM_8jdFxayeRz2Vhd7xrpPFL4Z5"
    private let resendAPIURL = "https://api.resend.com/emails"
    private let fromEmail = "amigoSecretoCulegudos@dalpra0.tech"
    
    func addParticipant(name: String, email: String) {
        guard !name.isEmpty && !email.isEmpty else {
            alertMessage = "Nome e email são obrigatórios"
            showingAlert = true
            return
        }
        
        guard email.contains("@") else {
            alertMessage = "Email inválido"
            showingAlert = true
            return
        }
        
        let person = Person(name: name, email: email)
        participants.append(person)
    }
    
    func removeParticipant(at offsets: IndexSet) {
        participants.remove(atOffsets: offsets)
    }
    
    func performDraw() -> Bool {
        guard participants.count >= 2 else {
            alertMessage = "Você precisa de pelo menos 2 participantes"
            showingAlert = true
            return false
        }
        
        // Algoritmo de amigo secreto com restrições
        var attempts = 0
        let maxAttempts = 1000
        
        while attempts < maxAttempts {
            if let validAssignments = generateValidAssignments() {
                assignments = validAssignments
                return true
            }
            attempts += 1
        }
        
        alertMessage = "Não foi possível gerar um sorteio válido. Tente novamente."
        showingAlert = true
        return false
    }
    
    private func generateValidAssignments() -> [Assignment]? {
        let givers = participants
        var receivers = participants
        var tempAssignments: [Assignment] = []
        
        // Embaralhar receivers
        receivers.shuffle()
        
        for giver in givers {
            // Encontrar um receiver válido
            guard let receiverIndex = receivers.firstIndex(where: { receiver in
                // Não pode tirar a si mesmo
                receiver.id != giver.id &&
                // Não pode formar um par bidirecional
                !tempAssignments.contains(where: { assignment in
                    assignment.giver.id == receiver.id && assignment.receiver.id == giver.id
                })
            }) else {
                return nil // Não encontrou um receiver válido
            }
            
            let receiver = receivers.remove(at: receiverIndex)
            tempAssignments.append(Assignment(giver: giver, receiver: receiver))
        }
        
        return tempAssignments
    }
    
    func sendMessages() async {
        guard !assignments.isEmpty else {
            await MainActor.run {
                alertMessage = "Faça o sorteio primeiro!"
                showingAlert = true
            }
            return
        }
        
        await MainActor.run {
            isSending = true
        }
        
        var successCount = 0
        var failCount = 0
        var errors: [String] = []
        
        for (index, assignment) in assignments.enumerated() {
            // Delay de 1 segundo entre cada email para respeitar rate limit
            if index > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 segundo
            }
            
            let result = await sendEmailViaResend(to: assignment.giver, receiver: assignment.receiver)
            if result.success {
                successCount += 1
            } else {
                failCount += 1
                if let errorMsg = result.error {
                    errors.append("\(assignment.giver.name): \(errorMsg)")
                }
            }
        }
        
        await MainActor.run {
            isSending = false
            
            if failCount == 0 {
                alertMessage = "✅ Todos os emails foram enviados! (\(successCount)/\(assignments.count))"
            } else {
                var message = "⚠️ Enviados: \(successCount), Falhas: \(failCount)\n\n"
                
                if errors.contains(where: { $0.contains("testing emails") || $0.contains("verify a domain") }) {
                    message += "⚠️ IMPORTANTE: No plano gratuito do Resend, você só pode enviar emails para: lucas.dalprabrascher@gmail.com\n\n"
                    message += "Para enviar para outros emails:\n"
                    message += "1. Configure um domínio no Resend\n"
                    message += "2. Ou use todos os participantes com o email: lucas.dalprabrascher@gmail.com para testar"
                } else if !errors.isEmpty {
                    message += "Erros:\n" + errors.prefix(3).joined(separator: "\n")
                }
                
                alertMessage = message
            }
            showingAlert = true
        }
    }
    
    private func sendEmailViaResend(to giver: Person, receiver: Person) async -> (success: Bool, error: String?) {
        let subject = "🎅 Seu Amigo Secreto"
        let htmlBody = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    line-height: 1.6;
                    color: #333;
                    max-width: 600px;
                    margin: 0 auto;
                    padding: 20px;
                }
                .container {
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    border-radius: 15px;
                    padding: 30px;
                    color: white;
                    text-align: center;
                }
                .gift-icon {
                    font-size: 60px;
                    margin-bottom: 20px;
                }
                h1 {
                    margin: 0 0 20px 0;
                    font-size: 28px;
                }
                .receiver-name {
                    background: rgba(255, 255, 255, 0.2);
                    padding: 20px;
                    border-radius: 10px;
                    font-size: 24px;
                    font-weight: bold;
                    margin: 20px 0;
                }
                .footer {
                    margin-top: 30px;
                    font-size: 14px;
                    opacity: 0.9;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="gift-icon">🎁</div>
                <h1>Olá, \(giver.name)!</h1>
                <p>Seu amigo secreto foi sorteado!</p>
                <div class="receiver-name">
                    \(receiver.name)
                </div>
                <p>🤫 Mantenha em segredo!</p>
                <div class="footer">
                    <p>Boas festas! 🎄✨</p>
                </div>
            </div>
        </body>
        </html>
        """
        
        let emailData: [String: Any] = [
            "from": fromEmail,
            "to": [giver.email],
            "subject": subject,
            "html": htmlBody
        ]
        
        guard let url = URL(string: resendAPIURL) else {
            return (false, "URL inválida")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(resendAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: emailData)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    return (true, nil)
                } else {
                    // Log e retorna o erro
                    if let errorString = String(data: data, encoding: .utf8) {
                        print("Erro ao enviar email para \(giver.name): \(errorString)")
                        
                        // Extrair mensagem de erro do JSON
                        if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let message = errorData["message"] as? String {
                            return (false, message)
                        }
                        return (false, errorString)
                    }
                    return (false, "Erro HTTP \(httpResponse.statusCode)")
                }
            }
            
            return (false, "Resposta inválida")
        } catch {
            print("Erro na requisição: \(error.localizedDescription)")
            return (false, error.localizedDescription)
        }
    }
    
    func reset() {
        assignments = []
    }
}
