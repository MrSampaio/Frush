
//
//  SheetNotes.swift
//  CH4-Books
//
//  Created by Lucas on 14/08/26.
//
 
import SwiftUI
import PhotosUI
 
struct SheetNotes: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var photoLibraryViewModel: PhotoLibraryViewModel
    @EnvironmentObject var booksViewModel: BooksViewModel
    @EnvironmentObject var notesViewModel: NotesViewModel
    
    @State var showingDiscardAlert: Bool = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    @State private var titleText: String = ""
    @State private var noteText: String = ""
    @State var image: UIImage? = nil
    @State var selectedCategory: String = ""
    
    @State private var selectedBook: Books? = nil
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    
    //descomentar e adicionar em to: book
    // essa variável é pra quando a sheet for aberta direto da view de um livro
    //var book: Books
   
    
    var body: some View {
        NavigationStack{
            ZStack {
                Color("BackgroundColorViews")
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    //aqui e o teste
//                    NavigationBarView()
//                        .padding(.horizontal)
//                        .padding(.top, 10)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 17) {
                            
                            VStack(alignment: .leading, spacing: 0){
                                Text("Conteúdo da nota")
                                    .font(.system(.title3, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.bottom, 6)
                                    .padding(.leading, 4)
                                
                                TipsComponent(
                                    content: "Adicione um título e um conteúdo para a sua nota."
                                )
                            }
                            
                            
                            TextField("", text: $titleText, prompt: Text("Adicionar título")
                                .font(.system(.body, weight: .regular))
                                .foregroundColor(.white.opacity(0.7))
                            )
                                .foregroundStyle(.white)
                                .padding()
                                .font(.system(.body, weight: .regular))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                                
                            
                            ZStack(alignment: .topLeading) {
                                if noteText.isEmpty {
                                    Text("Escreva sua nota...")
                                        .foregroundColor(.white.opacity(0.7))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 16)
                                        .zIndex(1)
                                        .allowsHitTesting(false)
                                        .font(.system(.body, weight: .regular))
                                }
                                
                                TextEditor(text: $noteText)
                                    .padding(8)
                                    .scrollContentBackground(.hidden)
                                    .cornerRadius(10)
                                    .frame(height: 250)
                                    .foregroundStyle(.white)
                                    .font(.system(.body, weight: .regular))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white, lineWidth: 1)
                                    )
                            }
                            
                            // depois muda pra sheet receber o livro como parâmetro
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Livro relacionado")
                                    .font(.system(.title3, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.bottom, 6)
                                    .padding(.leading, 4)
                                
                                Menu {
                                    ForEach(booksViewModel.savedBooks, id: \.self) { book in
                                        Button(book.bookTitle ?? "Sem título") {
                                            selectedBook = book
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedBook?.bookTitle ?? "Selecione um livro")
                                            .font(.system(.body, weight: .regular))
                                            .foregroundColor(selectedBook == nil ? .white.opacity(0.7) : .white)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.up.chevron.down")
                                            .font(.footnote.weight(.semibold))
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .contentShape(Rectangle())
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white, lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                 
                            
                            if let selectedImage = photoLibraryViewModel.selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                                    .cornerRadius(10)
                            }
                            
                            
                            
                            VStack(alignment: .leading, spacing: 5){

                                Text("Mídias")
                                    .font(.system(.title3, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.bottom, 6)
                                    .padding(.leading, 4)
                                
                                if !selectedImages.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(selectedImages.indices, id: \.self) { index in
                                                ZStack(alignment: .topTrailing) {
                                                    Image(uiImage: selectedImages[index])
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 120, height: 120)
                                                        .clipped()
                                                        .cornerRadius(10)
                                                    
                                                    Button(action: {
                                                        withAnimation{
                                                            selectedImages.remove(at: index)
                                                            selectedItems.remove(at: index)
                                                        }
                                                        
                                                    }) {
                                                        Image(systemName: "xmark.circle.fill")
                                                            .foregroundColor(.white)
                                                            .background(Color.black.opacity(0.6))
                                                            .clipShape(Circle())
                                                            .padding(6)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                PhotosPicker(selection: $selectedItems, maxSelectionCount: 3, matching: .images, photoLibrary: .shared()) {
                                        HStack {
                                            Image(systemName: "camera.viewfinder")
                                                .foregroundColor(Color("AddNoteImage"))
                                            
                                            Text(selectedImages.isEmpty ? "Adicionar fotos" : "Alterar fotos (\(selectedImages.count)/3)")
                                                .foregroundColor(Color("AddNoteImage"))
                                                .font(.system(.body, weight: .regular))
                                            
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(Color("AddNoteImage"))
                                        }
                                        .padding()
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.white, lineWidth: 1)
                                        )
                                    }
                                    .onChange(of: selectedItems) {newItems in
                                        Task {
                                            selectedImages.removeAll()
                                            for item in newItems {
                                                if let data = try? await item.loadTransferable(type: Data.self),
                                                   let uiImage = UIImage(data: data) {
                                                    selectedImages.append(uiImage)
                                                }
                                            }
                                        }
                                    }
                                TipsComponent(
                                    content: "Você pode adicionar até 3 fotos em uma mesma nota."
                                )
                            }
                            
                            
                            CategoryMenuView(
                                title: "Escolha a categoria",
                                categories: notesViewModel.noteCategories,
                                selectedCategory: $selectedCategory
                            )
                            
                        }
                        .padding(.horizontal)
                    }
 
                }
                
                .toolbar {
                    SheetHeaderView (
                        title: "Adicionar nota",
                        actionIcon: "checkmark",
                        showingDiscardAlert: $showingDiscardAlert,
                        onCancel: { dismiss() },
                        onConfirm: {
                            do {
                                try notesViewModel.addNote(
                                    noteTitle: titleText,
                                    noteDescription: noteText,
                                    noteCategory: selectedCategory,
                                    notePhotos: selectedImages,
                                    to: selectedBook
                                )
                                
                                dismiss()
                                
                            } catch let error as LocalizedError {
                                errorMessage = error.errorDescription ?? "Ocorreu um erro desconhecido."
                                showErrorAlert = true
                            } catch {
                                errorMessage = "Erro inesperado."
                                showErrorAlert = true
                            }
                        },
                        onDiscard: { dismiss() }
                    )
                }
            }
            .alert("Erro ao executar a ação.", isPresented: $showErrorAlert) {
                Button("Tentar novamente", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
}
 
#Preview {
    SheetNotes()
        .environmentObject(PhotoLibraryViewModel())
        .environmentObject(BooksViewModel())
        .environmentObject(NotesViewModel())
}

/* CATEGORIAS ANTIGAS
VStack(alignment: .leading, spacing: 8) {
    Text("Escolher categoria")
        .padding(.leading, 4)
        .font(.system(.title3, weight: .medium))
        .foregroundColor(.white)
        .padding(.bottom, 6)
    
    VStack(spacing: 0) {
        CategoryRow(title: "Categoria 1", hasDivider: true)
        CategoryRow(title: "Categoria 2", hasDivider: true)
        CategoryRow(title: "Categoria 3", hasDivider: false)
    }
    .cornerRadius(10)
    .overlay(
        RoundedRectangle(cornerRadius: 10)
            .stroke(Color.white, lineWidth: 1)
    )
    
}*/

/* BOTAO DE ADICIONAR NOTA ANTIGO
Button(action: {
    //codigo que seleciona o primeiro livro do banco
    guard let book = booksViewModel.savedBooks.count > 0
                ? booksViewModel.savedBooks[1]
                : booksViewModel.savedBooks.first else {
            print("Nenhum livro disponível no banco!")
            return
        }
            notesViewModel.addNote(
                noteTitle: titleText,
                noteDescription: noteText,
                noteCategory: "Teste",
                notePhoto: "foto_teste.jpg",
                to: book
            )
}) {
    Text("Adicionar nota")
        .font(.system(.title3, weight: .medium))
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color("ActionColor"))
        .cornerRadius(30)
}
.padding(.horizontal)
.padding(.bottom, 10)
 */
