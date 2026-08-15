//
//  stopwatchViewModel.swift
//  CH4-Books
//
//  Created by Lucas on 15/08/26.
//
import Combine
import Foundation

class StopwatchViewModel: ObservableObject {
    @Published var elapsedTime: TimeInterval = 120
    @Published var isRunning: Bool = false
    @Published var timer: Timer? = nil
    var timeString: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.elapsedTime -= 0.1
            
            
        }
        
    }
    func stop() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
}
