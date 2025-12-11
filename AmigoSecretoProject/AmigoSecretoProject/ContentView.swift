//
//  ContentView.swift
//  AmigoSecretoProject
//
//  Created by Lucas Dal Pra Brascher on 11/12/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SecretSantaViewModel()
    @State private var newName = ""
    @State private var newEmail = ""
    @State private var isDrawn = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                    Text("Amigo Secreto")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding()
                
                // Formulário de adicionar participante
                if !isDrawn {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Adicionar Participante")
                            .font(.headline)
                        
                        TextField("Nome", text: $newName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Email", text: $newEmail)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        Button(action: {
                            viewModel.addParticipant(name: newName, email: newEmail)
                            newName = ""
                            newEmail = ""
                        }) {
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
                
                // Lista de participantes
                VStack(alignment: .leading) {
                    Text("Participantes (\(viewModel.participants.count))")
                        .font(.headline)
                    
                    if viewModel.participants.isEmpty {
                        Text("Nenhum participante adicionado")
                            .foregroundColor(.gray)
                            .italic()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        List {
                            ForEach(viewModel.participants) { person in
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
                                }
                            }
                            .onDelete(perform: isDrawn ? nil : viewModel.removeParticipant)
                        }
                        .listStyle(InsetGroupedListStyle())
                    }
                }
                
                Spacer()
                
                // Botões de ação
                VStack(spacing: 15) {
                    if !isDrawn {
                        Button(action: {
                            if viewModel.performDraw() {
                                isDrawn = true
                            }
                        }) {
                            Label("Sortear Amigo Secreto", systemImage: "shuffle.circle.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.participants.count >= 2 ? Color.green : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                        .disabled(viewModel.participants.count < 2)
                    } else {
                        Button(action: {
                            Task {
                                await viewModel.sendMessages()
                            }
                        }) {
                            HStack {
                                if viewModel.isSending {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                                Label(viewModel.isSending ? "Enviando..." : "Enviar Emails", systemImage: "envelope.fill")
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.isSending ? Color.gray : Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                        }
                        .disabled(viewModel.isSending)
                        
                        Button(action: {
                            isDrawn = false
                            viewModel.reset()
                        }) {
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
            }
            .padding()
            .navigationBarHidden(true)
            .alert(isPresented: $viewModel.showingAlert) {
                Alert(title: Text("Amigo Secreto"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

#Preview {
    ContentView()
}
