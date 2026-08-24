//
//  NoteImageModel.swift
//  CH4-Books
//
//  Created by Lucas on 23/08/26.
//

import Foundation
import SwiftData

@Model
final class NoteImage1 {
    @Attribute(.unique) var id: UUID
    var fileName: String
    
    var note: Notes1?
    
    init(id: UUID, fileName: String) {
        self.id = id
        self.fileName = fileName
    }
}
