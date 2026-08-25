//
//  stopwatchViewModel.swift
//  CH4-Books
//
//  Created by Lucas on 15/08/26.
//

import Combine
import Foundation
import UIKit

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
    private var timer: Timer? = nil
    
    @Published var showProgressSheet: Bool = false
    
    // muda aqui pra puxar a página do banco e ela atualizar o progresso dinamicamente
    
    // controle de Páginas do Livro
    @Published var currentPage: Int16 = 0
    @Published var totalPages: Int16 = 0
    
    private var cancellables = Set<AnyCancellable>()
        
    init() {
        // obeservador do tempo de vida ativo do app
        setupAppLifecycleObservers()
        checkPendingSession()
    }
    
    
    private func resumeStateOnForeground() {
        checkPendingSession()
    }
    
    private func setupAppLifecycleObservers() {
        // verifica quando o app vai pra segundo plano
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                self?.saveStateOnBackground()
            }
            .store(in: &cancellables)
        
        // verifica quando fecha o app repentinamente (arrasta pra cima)
        NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)
            .sink { [weak self] _ in
                self?.saveStateOnBackground()
            }
            .store(in: &cancellables)

        // verifica quando o app volta para a tela (primeiro plano)
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.resumeStateOnForeground()
            }
            .store(in: &cancellables)
    }

    private func saveStateOnBackground() {
        // só salva caso tenha uma leitura em andamento
        guard timerState == .running || timerState == .paused else { return }

        // salva o exato momento que o app foi fechado/background
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "savedBackgroundDate")
        // salva o tempo que faltava
        UserDefaults.standard.set(elapsedTime, forKey: "savedElapsedTime")
        // salva o estado do timer (se estava rodando ou pausado)
        UserDefaults.standard.set(timerState == .running ? "running" : "paused", forKey: "savedTimerState")
    }
    
    // função para trazer os estados de volta pro app
    private func checkPendingSession() {
        let savedDate = UserDefaults.standard.double(forKey: "savedBackgroundDate")
        let savedElapsed = UserDefaults.standard.double(forKey: "savedElapsedTime")
        let savedTotal = UserDefaults.standard.double(forKey: "savedTotalTime")
        let savedStateStr = UserDefaults.standard.string(forKey: "savedTimerState")

        // se não tiver data salva, significa que não tinha leitura ativa, aí ignora
        guard savedDate > 0 else { return }
        
        if savedTotal > 0 {
            self.totalTime = savedTotal
        }

        let backgroundDate = Date(timeIntervalSince1970: savedDate)
        let timeAway = Date().timeIntervalSince(backgroundDate) // quanto tempo o app ficou fora de foco

        
        if savedStateStr == "running" {
            // subtrai do cronômetro o tempo que o cara passou fora do app
            let newElapsedTime = savedElapsed - timeAway

            if newElapsedTime > 0 {
                // se ainda sobrou tempo, atualiza e volta a rodar o timer visual
                self.elapsedTime = newElapsedTime
                self.startTimer()
            } else {
                // se o tempo acabou ENQUANTO o app estava fechado
                self.elapsedTime = 0
                self.finishTimer() // ou a sua função que pausa/invalida o timer
                
                // dispara a bottom sheet para ele preencher as páginas
                DispatchQueue.main.async {
                    self.showProgressSheet = true
                }
            }
        } else if savedStateStr == "paused" {
            // se estava pausado, só devolve o tempo exato, não subtrai o tempo fora
            self.elapsedTime = savedElapsed
            self.timerState = .paused
        }

        // limpa o UserDefaults para não correr o risco de puxar esses dados numa próxima leitura do zero
        UserDefaults.standard.removeObject(forKey: "savedBackgroundDate")
        UserDefaults.standard.removeObject(forKey: "savedElapsedTime")
        UserDefaults.standard.removeObject(forKey: "savedTotalTime")
        UserDefaults.standard.removeObject(forKey: "savedTimerState")
    }

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
                self.finishTimer()
                
                SoundManager.shared.playSound(named: .success)
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
    
    func getBookProgress(book: Books) -> Double {
        let totalPages = book.bookTotalPages
        let currentPage = book.bookCurrentPage
        
        guard totalPages > 0 else { return 0.0 }
        return min(max(Double(currentPage) / Double(totalPages), 0.0), 1.0)
    }
    
    func finishTimer() {
        timerState = .paused
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
}
