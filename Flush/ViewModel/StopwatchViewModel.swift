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
    
    @Published var showProgressSheet: Bool = false
    
    // muda aqui pra puxar a página do banco e ela atualizar o progresso dinamicamente
    
    // controle de Páginas do Livro
    @Published var currentPage: Int16 = 0
    @Published var totalPages: Int16 = 0
    
    // progresso do Cronômetro (0.0 a 1.0) para os Anéis
    var timeProgress: Double {
        guard totalTime > 0 else { return 0 }
        return (totalTime - elapsedTime) / totalTime
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
                DispatchQueue.main.async {
                    self.showProgressSheet = true
                }
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
        self.currentPage = Int16(newPage)
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
    
    func getCurrentPage(book: Books) -> Int{
        currentPage = book.bookCurrentPage
        return Int(currentPage)
    }
    
    func getTotalPages(book: Books) -> Int{
        totalPages = book.bookTotalPages
        return Int(totalPages)
    }
    
//    func getBookProgress(book: Books) -> Int{
//        //        bookProgress = Double(book.bookCurrentPage) / Double(book.bookTotalPages)
//        //        return bookProgress
//        
//        let totalPages = book.bookTotalPages
//        let currentPage = book.bookCurrentPage
//        var bookProgress: Double {
//            guard totalPages > 0 else { return 0 }
//            return min(max(Double(currentPage) / Double(totalPages), 0.0), 1.0)
//        }
//        
//        return Int(bookProgress)
//        
//    }
    
    func getBookProgress(book: Books) -> Double {
        let totalPages = book.bookTotalPages
        let currentPage = book.bookCurrentPage
        
        guard totalPages > 0 else { return 0.0 }
        return min(max(Double(currentPage) / Double(totalPages), 0.0), 1.0)
    }
    
}
