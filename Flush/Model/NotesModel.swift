//
//  NotesModel.swift
//  CH4-Books
//
//  Created by Lucas on 23/08/26.
//

import Foundation
import SwiftData

final class NotesModel{
    @Attribute(.unique) var id: UUID
    var noteCategory: String
    var noteDescrioption: String
    //------------------refazer essa opcao usando o Codable------------------
    //var notePhoto: Transformable
    var noteTitle: String
    
    init(id: UUID, noteCategory: String, noteDescrioption: String, noteTitle: String) {
        self.id = id
        self.noteCategory = noteCategory
        self.noteDescrioption = noteDescrioption
        self.noteTitle = noteTitle
    }
}
