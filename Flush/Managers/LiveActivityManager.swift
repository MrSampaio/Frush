//
//  LiveActivityManager.swift
//  CH4-Books
//

import Foundation
import ActivityKit

final class LiveActivityManager {
    
    static let shared = LiveActivityManager()
    private init() {}
    
    private var activity: Activity<ReadingActivityAttributes>?
    
    /// O usuário pode desativar Live Activities nos Ajustes
    private var isEnabled: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }
    
    /// Reconecta a uma atividade que sobreviveu ao encerramento do app
    func reattach() {
        activity = Activity<ReadingActivityAttributes>.activities.first
    }
    
    func start(bookTitle: String, remaining: TimeInterval) {
        guard isEnabled, remaining > 0 else { return }
        
        // se já existe uma atividade viva, só atualiza
        if activity != nil {
            update(remaining: remaining, isPaused: false)
            return
        }
        
        let now = Date()
        let attributes = ReadingActivityAttributes(bookTitle: bookTitle)
        let state = ReadingActivityAttributes.ContentState(
            startDate: now,
            endDate: now.addingTimeInterval(remaining),
            isPaused: false,
            remainingTime: remaining
        )
        
        do {
            activity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: state, staleDate: nil),
                pushType: nil
            )
        } catch {
            print("Erro ao iniciar Live Activity: \(error)")
        }
    }
    
    func update(remaining: TimeInterval, isPaused: Bool) {
        guard let activity else { return }
        
        let now = Date()
        let state = ReadingActivityAttributes.ContentState(
            startDate: now,
            endDate: now.addingTimeInterval(remaining),
            isPaused: isPaused,
            remainingTime: remaining
        )
        
        Task {
            await activity.update(ActivityContent(state: state, staleDate: nil))
        }
    }
    
    func end() {
        let current = activity
        activity = nil
        
        Task {
            if let current {
                await current.end(nil, dismissalPolicy: .immediate)
            }
            // varre qualquer atividade órfã de sessões anteriores
            for orphan in Activity<ReadingActivityAttributes>.activities {
                await orphan.end(nil, dismissalPolicy: .immediate)
            }
        }
    }
}
