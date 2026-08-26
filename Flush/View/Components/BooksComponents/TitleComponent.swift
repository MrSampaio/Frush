//
//  TitleComponent.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 18/08/26.
//

import Foundation
import SwiftUI

struct TitleComponent: View {
    var title: String
    
    var body: some View {
        Text(title)
            .font(.bitter(.medium, style: .title))
            .foregroundStyle(Color("TitleColor"))
            .lineLimit(2)
    }
}


#Preview {
    TitleComponent(title: "Terceiro Livro")
}
