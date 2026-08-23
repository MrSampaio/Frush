//
//  NoteImageModel.swift
//  CH4-Books
//
//  Created by Lucas on 23/08/26.
//

import Foundation
import SwiftData

final class NoteImageModel {
    @Attribute(.unique) var id: UUID
    var fileName: String
    
    init(id: UUID, fileName: String) {
        self.id = id
        self.fileName = fileName
    }
}
