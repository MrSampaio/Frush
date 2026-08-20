//
//  stopwatchViewModel.swift
//  CH4-Books
//
//  Created by Lucas on 15/08/26.
//
import Combine
import Foundation

enum TimerState {
    case stopped
    case running
    case paused
}

class StopwatchViewModel: ObservableObject {
    @Published var timerState: TimerState = .stopped
    @Published var elapsedTime: TimeInterval = 0
    @Published var totalTime: TimeInterval = 0
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
    
    // configura a duração inicial (chamado ao rolar o Picker)
    func setDuration(_ duration: TimeInterval) {
        self.totalTime = duration
        self.elapsedTime = duration
    }
        
    func startTimer() {
        timerState = .running
        isRunning = true
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.elapsedTime > 0 {
                self.elapsedTime -= 0.1
            } else {
                self.stop()
            }
        }
    }
    
    func pauseTimer() {
        timerState = .paused
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    // para a contagem ao finalizar o tempo
    func stop() {
        timerState = .stopped
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    // Abandona a leitura e reseta o cronômetro para o valor original
    func abandonTimer() {
        stop()
        elapsedTime = totalTime
    }
    
    func updatePage(to newPage: Int) {
        self.currentPage = newPage
    }
    
    /*
    func timerFormater() -> String{
        let current = max(0, Int(elapsedTime))
        return String(format: "%02d:%02d", current / 60, current % 60)
    }
    */
    func timerFormater() -> String {
        let current = max(0, Int(elapsedTime))
        let hours = current / 3600
        let minutes = (current % 3600) / 60
        let seconds = current % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
