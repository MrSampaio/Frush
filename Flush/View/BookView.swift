//
//  BookView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 14/08/26.
//
import SwiftUI
import PhotosUI

struct BookView: View {
    @State private var isShowingSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Meus Livros")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Button(action: {
                    isShowingSheet = true
                }) {
                    Image(systemName: "plus")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.black)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 8)
            
            Spacer()
        }
        .sheet(isPresented: $isShowingSheet) {
            AddBookSheetView()
        }
    }
}

struct AddBookSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var photoLibraryViewModel: PhotoLibraryViewModel
    
    @State private var showingDiscardAlert: Bool = false
    
    let goalOptions = ["5 minutos", "10 minutos", "15 minutos", "20 minutos", "30 minutos", "45 minutos", "60 minutos"]
    @State private var selectedGoal: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack {
                        PhotosPicker(selection: $photoLibraryViewModel.selectedItem, matching: .images) {
                            ZStack(alignment: .bottomTrailing) {
                                Group {
                                    if let selectedImage = photoLibraryViewModel.selectedImage {
                                        Image(uiImage: selectedImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 150, height: 210)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                    } else {
                                        Image("defaultBook")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 150, height: 210)
                                            .background(Color(uiColor: .systemGray4))
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                    }
                                }
                                
                                Image(systemName: photoLibraryViewModel.selectedImage == nil ? "plus" : "pencil")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(Color.black)
                                    .clipShape(Circle())
                                    .offset(x: 12, y: 12)
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom, 12)
                        .padding(.trailing, 12)
                    }
                    
                    if photoLibraryViewModel.selectedImage != nil {
                        Button(action: {
                            withAnimation {
                                photoLibraryViewModel.selectedImage = nil
                                photoLibraryViewModel.selectedItem = nil
                            }
                        }) {
                            Text("Remover capa")
                                .font(.body)
                                .foregroundColor(.red)
                        }
                    }
                    
                    TextField("Título", text: .constant(""))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    TextField("Categoria", text: .constant(""))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    TextField("Páginas", text: .constant(""))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Menu {
                        ForEach(goalOptions, id: \.self) { option in
                            Button(option) {
                                selectedGoal = option
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedGoal.isEmpty ? "Objetivo diário (minutos)" : selectedGoal)
                                .foregroundColor(selectedGoal.isEmpty ? Color(uiColor: .placeholderText) : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(uiColor: .systemGray4), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                }
            }
            .toolbar {
                SheetHeaderView(
                    title: "Cadastrar Livro",
                    actionIcon: "checkmark",
                    showingDiscardAlert: $showingDiscardAlert,
                    onCancel: {},
                    onAction: { dismiss() },
                    onDiscard: { dismiss() }
                )
            }
        }
    }
}

#Preview {
    BookView()
        .environmentObject(PhotoLibraryViewModel())
}
