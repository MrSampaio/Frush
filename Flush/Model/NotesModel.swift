//
//  NotesModel.swift
//  CH4-Books
//
//  Created by Lucas on 23/08/26.
//

import Foundation
import SwiftData

@Model
final class Notes {
    var noteCategory: String
    var noteDescription: String
    var noteTitle: String
    
    // transformador padrao para imagens
    @Attribute(.transformable(by: NSSecureUnarchiveFromDataTransformer.self))
    var notePhoto: [Data]
    
    var book: Books?
    
    @Relationship(inverse: \NoteImage.note)
    var images: [NoteImage]? = []
    
    init(noteCategory: String, noteDescription: String, noteTitle: String, notePhoto: [Data]) {
        self.noteCategory = noteCategory
        self.noteDescription = noteDescription
        self.noteTitle = noteTitle
        self.notePhoto = notePhoto
    }
}
