//
//  PhotoLibraryViewModel.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 14/08/26.
//

import Foundation
import SwiftUI
import Combine
import PhotosUI
import UIKit
import CoreData

class PhotoLibraryViewModel: ObservableObject {
    @Published var selectedItem: PhotosPickerItem? = nil {
        didSet {
            Task {
                await loadImage()
            }
        }
    }
    
    @Published var selectedImage: UIImage? = nil
    
    private func loadImage() async {
        guard let item = selectedItem else { return }
        if let data = try? await item.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            DispatchQueue.main.async {
                self.selectedImage = image
            }
        }
    }
    
    func saveImageToCoreData(image: UIImage){
        let newPhoto = Books(context: CoreDataManager.shared.viewContext)
        
        if let imageData = image.jpegData(compressionQuality: 1){
            newPhoto.bookCover = imageData
        }
        
        do {
            try CoreDataManager.shared.viewContext.save()
            print("Success when trying to save book cover")
        } catch let error{
            print("Success when trying to save book cover \(error)")
        }

    }
}
