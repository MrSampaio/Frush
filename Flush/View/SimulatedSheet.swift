//
//  SimulatedSheet.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 18/08/26.
//

import SwiftUI

struct SimulatedSheet<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    @ViewBuilder var sheetContent: () -> SheetContent
    
    @State private var dragOffset: CGFloat = 0
    
    private let dismissThreshold: CGFloat = 500
    private let sheetHeightRatio: CGFloat = 0.92
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                GeometryReader { geo in
                    ZStack(alignment: .bottom) {
                        Color.black
                            .opacity(backgroundOpacity(in: geo))
                            .ignoresSafeArea()
                            .onTapGesture { close() }
                        
                        VStack(spacing: 0) {
                            sheetContent()
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: geo.size.height * sheetHeightRatio)
                        .background(Color("BackgroundColorViews"))
                        .offset(y: max(dragOffset * 0.3, 0))
                        .simultaneousGesture(dragGesture)
                        .transition(.move(edge: .bottom))
                    }
                }
                .ignoresSafeArea()
                .zIndex(1)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: isPresented)
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.translation.height > 0 {
                    dragOffset = value.translation.height
                }
            }
            .onEnded { value in
                if value.translation.height > dismissThreshold {
                    close()
                } else {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        dragOffset = 0
                    }
                }
            }
    }
    
    private func backgroundOpacity(in geo: GeometryProxy) -> Double {
        let maxDrag = geo.size.height * sheetHeightRatio
        let progress = min(max((dragOffset * 0.3) / maxDrag, 0), 1)
        return 0.4 * (1 - progress)
    }
    
    private func close() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            dragOffset = 0
            isPresented = false
        }
    }
}

extension View {
    /// Aplica uma "sheet falsa": sobe por cima da view atual e pode ser
    /// fechada arrastando pra baixo. Ao contrário de .sheet(), o conteúdo
    /// fica na mesma hierarquia de view, então @EnvironmentObject já
    /// configurados continuam disponíveis automaticamente dentro dela.
    func fakeSheet<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(SimulatedSheet(isPresented: isPresented, sheetContent: content))
    }
}

private struct RoundedCorner: Shape {
    var radius: CGFloat = 24
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
