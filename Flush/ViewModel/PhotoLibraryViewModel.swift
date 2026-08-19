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
    
    @Published var selectedImage: UIImage?
    
    @Published var noteImages: [SelectableImage] = []
    
    private let maxNoteImages = 3
    
    func loadImage() async {
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
    
    func getCoverImage(for book: Books) -> UIImage? {
        if book.entity.attributesByName.keys.contains("bookCover") {
            
            if let imageData = book.value(forKey: "bookCover") as? Data, let uiImage = UIImage(data: imageData) {
                return uiImage
            }
            
            if let imageName = book.value(forKey: "bookCover") as? String, !imageName.isEmpty, let uiImage = UIImage(named: imageName) {
                return uiImage
            }
        }
        
        if book.entity.attributesByName.keys.contains("bookImage") {
            if let imageData = book.value(forKey: "bookImage") as? Data, let uiImage = UIImage(data: imageData) {
                return uiImage
            }
        }
        return nil
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
