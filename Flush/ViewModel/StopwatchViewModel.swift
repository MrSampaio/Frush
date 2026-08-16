//
//  stopwatchViewModel.swift
//  CH4-Books
//
//  Created by Lucas on 15/08/26.
//
import Combine
import Foundation

class StopwatchViewModel: ObservableObject {
    @Published var elapsedTime: TimeInterval = 10
    @Published var isRunning: Bool = false
    @Published var timer: Timer? = nil
        
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if self.elapsedTime > 0 {
                self.elapsedTime -= 0.1
                
            }else{
                self.isRunning = false
            }
            
        }
    }
    
    func stop() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func timerFormater() -> String{
        return String(format: "%02d:%02d", Int(elapsedTime) / 60, Int(elapsedTime) % 60)
    }
    
}
