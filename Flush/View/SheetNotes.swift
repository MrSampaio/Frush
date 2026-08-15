//
//  SheetNotes.swift
//  CH4-Books
//
//  Created by Lucas on 14/08/26.
//

import SwiftUI

struct SheetNotes: View {

    @State private var titleText: String = ""
    @State private var noteText: String = ""

    var body: some View {
        ZStack {
            //cor da interface
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                //aqui e o teste
                NavigationBarView()
                    .padding(.horizontal)
                    .padding(.top, 10)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        
                        TextField("Adicionar título", text: $titleText)
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(10)

                        ZStack(alignment: .topLeading) {
                            if noteText.isEmpty {
                                Text("Escreva sua nota...")
                                    .foregroundColor(Color(UIColor.placeholderText))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 16)
                                    .zIndex(1)
                                    .allowsHitTesting(false)
                            }

                            TextEditor(text: $noteText)
                                .padding(8)
                                .scrollContentBackground(.hidden)
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(10)
                                .frame(height: 250)
                        }

                        Button(action: {
                        }) {
                            HStack {
                                Image(systemName: "camera.viewfinder")
                                Text("Adicionar foto")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color(UIColor.tertiaryLabel))
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(10)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Escolher categoria")
                                .font(.headline)
                                .padding(.leading, 4)

                            VStack(spacing: 0) {
                                CategoryRow(title: "Categoria 1", hasDivider: true)
                                CategoryRow(title: "Categoria 2", hasDivider: true)
                                CategoryRow(title: "Categoria 3", hasDivider: false)
                            }
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }

                Button(action: {
                }) {
                    Text("Adicionar nota")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(30)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
        }
    }
}

#Preview {
    SheetNotes()
}
