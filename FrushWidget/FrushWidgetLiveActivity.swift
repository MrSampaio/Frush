//
//  FrushWidgetsLiveActivity.swift
//  FrushWidgets
//

import ActivityKit
import WidgetKit
import SwiftUI

struct FrushWidgetsLiveActivity: Widget {
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ReadingActivityAttributes.self) { context in
            
            // Tela bloqueada / banner
            HStack(spacing: 12) {
                appIcon(size: 36)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Lendo agora")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(context.attributes.bookTitle)
                        .font(.headline)
                        .lineLimit(1)
                }
                
                Spacer()
                
                timer(for: context, font: .title2)
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.6))
            .activitySystemActionForegroundColor(Color.orange)
            
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    appIcon(size: 32)
                        .padding(.leading, 4)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    timer(for: context, font: .title2)
                        .padding(.trailing, 4)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.attributes.bookTitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            } compactLeading: {
                appIcon(size: 20)
            } compactTrailing: {
                timer(for: context, font: .caption)
                    .frame(width: 44)
            } minimal: {
                appIcon(size: 18)
            }
            .widgetURL(URL(string: "frush://stopwatch"))
            .keylineTint(Color.orange)
        }
    }
    
    // MARK: - Componentes
    
    @ViewBuilder
    private func appIcon(size: CGFloat) -> some View {
        if let uiImage = UIImage(named: "IslandImage") {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
            } else {
                Image(systemName: "book.fill")
                    .font(.system(size: size))
                    .foregroundStyle(Color.orange)
            }
    }
    @ViewBuilder
    private func timer(
        for context: ActivityViewContext<ReadingActivityAttributes>,
        font: Font
    ) -> some View {
        if context.state.isPaused {
            Text(formatted(context.state.remainingTime))
                .font(font)
                .monospacedDigit()
                .foregroundStyle(.secondary)
        } else {
            Text(
                timerInterval: context.state.startDate...context.state.endDate,
                countsDown: true
            )
            .font(font)
            .monospacedDigit()
            .multilineTextAlignment(.center)
            .foregroundStyle(Color.orange)
        }
    }
    
    private func formatted(_ seconds: TimeInterval) -> String {
        let total = max(0, Int(seconds))
        return String(format: "%02d:%02d", total / 60, total % 60)
    }
}
