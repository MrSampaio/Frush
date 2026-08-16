//
//  FontTypography.swift
//  CH4-Books
//
//  Created by Agatha Barbosa Marinho dos Santos on 15/08/26.
//

import SwiftUI

extension Font {
    enum BitterWeight: String {
        case regular = "Bitter-Regular"
        case medium = "Bitter-Medium"
        case bold = "Bitter-Bold"
        case semibold = "Bitter-SemiBold"
    }
    
    // aplica a fonte Bitter com peso específico ajustada ao Dynamic Type
    static func bitter(_ weight: BitterWeight = .medium, style: TextStyle) -> Font {
        let uiStyle: UIFont.TextStyle = switch style {
        case .largeTitle: .largeTitle
        case .title: .title1
        case .title2: .title2
        case .title3: .title3
        case .headline: .headline
        case .subheadline: .subheadline
        case .body: .body
        case .callout: .callout
        case .footnote: .footnote
        case .caption: .caption1
        case .caption2: .caption2
        @unknown default: .body
        }
        
        let pointSize = UIFont.preferredFont(forTextStyle: uiStyle).pointSize
        return Font.custom(weight.rawValue, size: pointSize, relativeTo: style)
    }
}
