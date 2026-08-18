//
//  BookCaseView.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 15/08/26.
//

import SwiftUI

struct BookCaseView: View {
    @State private var isShowingSheet = false
    
    var body: some View {
        
        NavigationStack{
            ZStack {
                Color("BackgroundColorViews")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack (alignment: .leading, spacing: 24) {
                        //título e botão "+"
                        HStack {
                            TitleComponent(title: "Meus Livros")
                            
                            
    //                        Spacer()
    //
    //                        Button(action: {
    //                            // Ação do botão
    //                        }) {
    //                            Image(systemName: "plus")
    //                                .font(.system(.title, weight: .semibold))
    //                                .foregroundStyle(Color("TitleColor"))
    //                                .frame(width: 48, height: 48)
    //                                .background(Color.black.opacity(0.3), in: Circle())
    //                        }
    //                        .glassEffect(.regular, in: Circle())
                            
                                
                        }
                        .padding(.top, 28)
                        
                        CardTotalPages(totalPages: 100)
                        //lista de livros
                        //FAZER
                    }
                    .padding(.horizontal, 20)
                }
                
                //.navigationTitle("Meus livros")
                //.navigationBarTitleDisplayMode(.large)
                .toolbar {
                    BookCaseToolbar(onAddClick: {
                        isShowingSheet.toggle()
                    })
                }
            }
        }
        
        .sheet(isPresented: $isShowingSheet) {
            BookSheetView()
        }
    }
}

#Preview {
    BookCaseView()
        .environmentObject(PhotoLibraryViewModel())
        .environmentObject(BooksViewModel())
}
