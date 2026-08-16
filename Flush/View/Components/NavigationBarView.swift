//
//  NavigationBarView.swift
//  CH4-Books
//
//  Created by Lucas on 14/08/26.
//

import SwiftUI

struct NavigationBarView: View {
    var body: some View {
                
            HStack {
                Button(action: {
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .background(Color(UIColor.tertiarySystemFill))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text("Add Note")
                    //.font(.title3)
                    //.fontWeight(.semibold)
                    .font(.bitter(.medium, style: .title3))
                    .foregroundStyle(Color("TitleColor"))
                
                Spacer()
                
                Button(action: {
                }) {
                    Image(systemName: "checkmark")
                        .font(.callout.weight(.bold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
            .background(Color("BackgroundColorViews"))
        }
    }

#Preview {
    NavigationBarView()
}
