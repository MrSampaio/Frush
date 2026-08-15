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
    @EnvironmentObject var booksViewModel: BooksViewModel
    
//    @State var savedBooks[][books] = BooksViewModel.savedBooks
    
    
    var body: some View {
        VStack(alignment: .center) {
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
            
            //Spacer()
            
            VStack(alignment: .center){
                if booksViewModel.savedBooks.count > 0{
                    ForEach(booksViewModel.savedBooks, id: \.self) { bookIndex in

                        Text("Livro \(bookIndex)")
                        //ReminderCard(reminder: $viewModel.reminders[index])
                    }
                    
                } else{
                    //Spacer()
                    Text("Nenhum livro adicionado")
                }
            }
        }
        .sheet(isPresented: $isShowingSheet) {
            AddBookSheetView()
        }
    }
}

#Preview {
    BookView()
        .environmentObject(PhotoLibraryViewModel())
        .environmentObject(BooksViewModel())
}
