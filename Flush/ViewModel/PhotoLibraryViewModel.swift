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
import SwiftData

struct SelectableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

class PhotoLibraryViewModel: ObservableObject {
    @Published var selectedItem: PhotosPickerItem? = nil {
        didSet {
            Task {
                await loadImage()
            }
        }
    }
    
    //@Published var selectedImage: UIImage? = UIImage(named: "defaultBook")
    
    @Published var selectedCoverImage: UIImage? = UIImage(named: "defaultBook") ?? UIImage()
    
    @Published var selectedImage: UIImage? = nil
    
    @Published var noteImages: [SelectableImage] = []
    
    private let maxNoteImages = 3
    
    func loadImage() async {
        guard let item = selectedItem else { return }
        if let data = try? await item.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            DispatchQueue.main.async {
                self.selectedCoverImage = image
            }
        }
    }
    
    func loadExistingImages(_ images: [UIImage]) {
        for image in images.prefix(maxNoteImages) {
            noteImages.append(SelectableImage(image: image))
        }
    }
    
//    func saveImageToCoreData(image: UIImage){
//        let newPhoto = Books(context: CoreDataManager.shared.viewContext)
//        
//        let defaultImageData = UIImage(named: "defaultBook")?.jpegData(compressionQuality: 1) ?? Data()
//        let imageData = image.jpegData(compressionQuality: 1) ?? defaultImageData
//        
//        newPhoto.bookCover = imageData
//        
//        do {
//            try CoreDataManager.shared.viewContext.save()
//            print("Success when saving the book cover")
//        } catch let error {
//            print("Error when saving the book cover \(error)")
//        }
//    }
    //-------------------------depois resolver essa questao de imagem-------------------------
//    func saveImage(image: UIImage, context: ModelContext) {
//            let defaultImageData = UIImage(named: "defaultBook")?.jpegData(compressionQuality: 1) ?? Data()
//            let imageData = image.jpegData(compressionQuality: 1) ?? defaultImageData
//            
//            
//            let newPhotoBook = Books()
//            newPhotoBook.bookCover = imageData
//            
//            context.insert(newPhotoBook)
//            
//            do {
//                try context.save()
//                print("Success when saving the book cover")
//            } catch let error {
//                print("Error when saving the book cover \(error)")
//            }
//        }
    
    func convertImageToData(image: UIImage) -> Data?{

        let defaultImageData = UIImage(named: "defaultBook")?.jpegData(compressionQuality: 1) ?? Data()
        let imageData = image.jpegData(compressionQuality: 1) ?? defaultImageData
        
        return imageData
    }
    
//    func getCoverImage(for book: Books) -> UIImage? {
//        if book.entity.attributesByName.keys.contains("bookCover") {
//            
//            if let imageData = book.value(forKey: "bookCover") as? Data, let uiImage = UIImage(data: imageData) {
//                return uiImage
//            }
//            
//            if let imageName = book.value(forKey: "bookCover") as? String, !imageName.isEmpty, let uiImage = UIImage(named: imageName) {
//                return uiImage
//            }
//        }
//        
//        if book.entity.attributesByName.keys.contains("bookImage") {
//            if let imageData = book.value(forKey: "bookImage") as? Data, let uiImage = UIImage(data: imageData) {
//                return uiImage
//            }
//        }
//        return nil
//    }
    func getCoverImage(for book: Books) -> UIImage? {
        
        guard let data = book.bookCover else { return nil }
        return UIImage(data: data)
    }

    func loadPickedItems(_ items: [PhotosPickerItem]) {
        Task {
            for item in items {
                guard noteImages.count < maxNoteImages else { break }
                
                guard let data = try? await item.loadTransferable(type: Data.self) else { continue }
                guard let uiImage = UIImage(data: data) else { continue }
                
                await MainActor.run {
                    noteImages.append(SelectableImage(image: uiImage))
                }
            }
        }
    }
    
    func appendCapturedImage(_ image: UIImage?) {
        guard let image, noteImages.count < maxNoteImages else { return }
        noteImages.append(SelectableImage(image: image))
    }
    
    func removeNoteImage(id: UUID) {
        noteImages.removeAll { $0.id == id }
    }
    
    func resetNoteImages() {
        noteImages.removeAll()
    }
}
