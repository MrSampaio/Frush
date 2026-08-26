//
//  ReadingActivityAttributes.swift
//  CH4-Books
//

import Foundation
import ActivityKit

struct ReadingActivityAttributes: ActivityAttributes {
    
    /// Dados que mudam durante a sessão de leitura
    struct ContentState: Codable, Hashable {
        /// Início do intervalo exibido na contagem
        var startDate: Date
        /// Momento em que o cronômetro chega a zero
        var endDate: Date
        /// Congela a contagem quando o usuário pausa
        var isPaused: Bool
        /// Tempo restante no momento da pausa (usado só quando isPaused == true)
        var remainingTime: TimeInterval
    }
    
    /// Dados fixos, definidos quando a atividade começa
    var bookTitle: String
}
