//
//  BookView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 14/08/26.
//

import SwiftUI
import PhotosUI

struct BookView: View {
    //"interruptor modal"
    @State private var isShowingSheet = false
    
    var body: some View {
        
        VStack(spacing: 0){
            HStack {
                Text("Meus Livros")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Button(action: {
                    isShowingSheet = true
                }){
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
    @EnvironmentObject var PhotoLibraryViewModel: PhotoLibraryViewModel
    
    //estados para o input de imagem
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    
    let goalOptions = ["5 minutos", "10 minutos", "15 minutos", "20 minutos", "30 minutos", "45 minutos", "60 minutos"]
        
    //estado para armazenar o tempo selecionado
    @State private var selectedGoal: String = ""
    
    var body: some View {
        VStack {
            SheetHeaderView(
                title: "Cadastrar Livro",
                actionIcon: "checkmark",
                onCancel: { dismiss() },
                onAction: { dismiss() }
            )
            
            ScrollView {
                VStack(spacing: 16) {
                    //capa do livro
                    VStack {
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            ZStack(alignment: .bottomTrailing) {
                                
                                Group {
                                    if let selectedImage = selectedImage {
                                        Image(uiImage: selectedImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 150, height: 210)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                    } else {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color(uiColor: .systemGray4))
                                            .frame(width: 150, height: 210)
                                            .overlay(
                                                Text("Adicione a capa\ndo seu livro")
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.white)
                                                    .multilineTextAlignment(.center)
                                                    .padding()
                                            )
                                    }
                                }
                                
                                Image(systemName: selectedImage == nil ? "plus" : "pencil")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(Color.black)
                                    .clipShape(Circle())
                                    .offset(x: 12, y: 12)
                            }
                        }
                        
                        .padding(.bottom, 12)
                        .padding(.trailing, 12)
                        
                        .onChange(of: selectedItem) { oldItem, newItem in
                            Task {
                                await PhotoLibraryViewModel.loadImage()
                            }
                        }
                    }
                    
                    // opção de remover a imagem selecionada
                    if selectedImage != nil {
                        Button("Remover capa") {
                            selectedImage = nil
                            selectedItem = nil
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                    }
                    
                    TextField("Título", text: .constant(""))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal) // Arrumei o padding para manter alinhado
                    
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
        }
    }
}

#Preview {
    BookView()
        .environmentObject(PhotoLibraryViewModel())
}
