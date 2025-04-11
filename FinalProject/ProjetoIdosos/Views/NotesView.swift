//
//  Notes.swift
//  ProjetoIdosos
//
//  Created by Turma02-16 on 02/04/25.
//

import SwiftUI

struct NotesView: View {
    @StateObject var vm = ViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                NavBarView()
                VStack(alignment: .leading) {
                    NavigationLink(destination: NewNoteView()) {
                        Text("Adicionar Nota")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.lightGreen) // Example blue color
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    Text("Últimas Notas")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                    List {
                        ForEach(vm.notes) { note in
                            NavigationLink(destination: NoteDetailView(note: note)) {
                                VStack(alignment: .leading) {
                                    Text(note.title)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text(note.description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 5)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    
                    Spacer()
                }
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    Task {
                        vm.fetchNotes()
                    }
                }
            }
        }
    }
}

#Preview {
    NotesView()
}
