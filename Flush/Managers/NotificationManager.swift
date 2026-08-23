//
//  NotificationManager.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 23/08/26.
//

import Foundation
import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Permissão de notificação concedida!")
            } else if let error = error {
                print("Erro ao pedir permissão de notificação: \(error)")
            }
        }
    }
    
    func scheduleDailyReminders() {
        cancelReminders()
        
        scheduleNotification(
            id: "morning_reminder",
            hour: 8,
            title: "Bom dia, leitor(a)!",
            body: "Que tal começar o dia avançando algumas páginas do seu livro?"
        )
        
        scheduleNotification(
            id: "afternoon_reminder",
            hour: 15,
            title: "Pausa para leitura",
            body: "Tire uns minutinhos da sua tarde para relaxar e progredir na sua meta de hoje."
        )
        
        scheduleNotification(
            id: "night_reminder",
            hour: 21,
            title: "O dia está acabando...",
            body: "Ainda dá tempo! Pegue seu livro e relaxe lendo um pouco antes de dormir."
        )
    }
    
    // função auxiliar que cria o gatilho da hora exata
    private func scheduleNotification(id: String, hour: Int, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = 0
        
        // repeats: true faz com que a notificação se repita todo dia nesse horário (se não for cancelada)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error when scheduling notification \(id): \(error.localizedDescription)")
            }
        }
    }
    
    func cancelReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
