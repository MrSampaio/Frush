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
    @Published var totalTime: TimeInterval = 10
    @Published var isRunning: Bool = false
    @Published var timer: Timer? = nil
    
    // controle de Páginas do Livro
    @Published var currentPage: Int = 45
    @Published var totalPages: Int = 300
    
    // progresso do Cronômetro (0.0 a 1.0) para os Anéis
    var timeProgress: Double {
        guard totalTime > 0 else { return 0 }
        return (totalTime - elapsedTime) / totalTime
    }
    
    // progresso do Livro (0.0 a 1.0) independente do timer
    var bookProgress: Double {
        guard totalPages > 0 else { return 0 }
        return min(max(Double(currentPage) / Double(totalPages), 0.0), 1.0)
    }
        
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if self.elapsedTime > 0 {
                self.elapsedTime -= 0.1
            } else {
                self.stop()
            }
            
        }
    }
    
    func stop() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func updatePage(to newPage: Int) {
        self.currentPage = newPage
    }
    
    func timerFormater() -> String{
        let current = max(0, Int(elapsedTime))
        return String(format: "%02d:%02d", current / 60, current % 60)
    }
    
}
