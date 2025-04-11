//
//  LoginView.swift
//  ProjetoIdosos
//
//  Created by Turma02-11 on 09/04/25.
//

import SwiftUI

struct LoginView: View {
    
    @State public var email: String = ""
    @State private var password: String = ""
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Login")
                    .font(.largeTitle)
                Group {
                    TextField("Email: ",text: $email)
                        .multilineTextAlignment(.center)
                    SecureField("Senha: ",text: $password)
                        .multilineTextAlignment(.center)
                    Button("Entrar") {
                        dismiss()
                    }
                    .foregroundStyle(.lightGreen)
                    
                }
                .padding()
                .background(.background)
                .clipShape(.rect(cornerRadius: 4))
            }
            .padding(40)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
            .padding(20)
        }
    }
}

#Preview {
    LoginView()
}
