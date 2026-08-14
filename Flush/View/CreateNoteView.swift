//
//  create-note-view.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 14/08/26.
//

import Foundation
import SwiftUI
import PhotosUI

struct CreateNoteView: View {
    @EnvironmentObject var viewModel: PhotoLibraryViewModel
    var body: some View {
            VStack {

                PhotosPicker(selection: $viewModel.selectedItem, matching: .images) {
                    HStack {
                        Text("Adicione uma foto")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "camera")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    .padding()
                }
                
                // Apenas para testar se a imagem foi carregada:
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                }
            }
        }
}

#Preview {
    CreateNoteView()
        .environment(\.managedObjectContext, CoreDataManager.shared.viewContext)
        .environmentObject(PhotoLibraryViewModel())
}
