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
                        
                        
                        //card de livros lidos por mês
                        HStack {
                            Image("BookPagesReadCard")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 98, height: 51)
                            
                            Spacer()
                            
                            VStack (alignment: .leading, spacing: 4){
                                Text("128 páginas lidas")
                                    .font(.bitter(.bold, style: .title3))
                                    .foregroundStyle(Color.black)
                                
                                Text(" neste mês")
                                    .font(.bitter(.regular, style: .footnote))
                                    .foregroundStyle(Color.black)
                            }
                            
                            Spacer()
                            
                        }
                        .padding(24)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color("PagesReadCard2"),
                                    Color("PagesReadCard1")
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: RoundedRectangle(cornerRadius: 20)
                        )
                        
                        
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
            AddBookSheetView()
        }
    }
}

#Preview {
    BookCaseView()
        .environmentObject(PhotoLibraryViewModel())
        .environmentObject(BooksViewModel())
}
