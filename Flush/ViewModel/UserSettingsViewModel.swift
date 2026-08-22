//
//  UserSettingsViewModel.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 22/08/26.
//

import Foundation
import SwiftUI
import CoreData
import Combine

class UserSettingsViewModel: ObservableObject {
    
    @Published var dailyGoal: Int = 0
    @Published var lastBookReaded: Books? = nil
//    @Published var dailyGoalMinutes: Int = 15
    
    // mantém a referência do objeto atual do CoreData para facilitar edições
    private var currentSettings: UserSettings?
    
    init(){
        self.fetchUserSettings()
    }
    
    func fetchUserSettings(){
        let request = NSFetchRequest<UserSettings>(entityName: "UserSettings")
        
        do {
            let results = try CoreDataManager.shared.viewContext.fetch(request)
            
            if let settings = results.first {
                self.currentSettings = settings
                
                let convertedGoal = Int(settings.dailyGoalMinutes)
                
                self.dailyGoal = convertedGoal
                self.lastBookReaded = settings.lastBookReaded
                
            }
        } catch let error {
            fatalError("Error when trying to fetch UserSettings data: \(error)")
        }
    }
    
    func updateUserSettings(newGoal: Int? = nil, newLastBook: Books? = nil){
        guard let settings = currentSettings else { return }
        
        if let newGoal = newGoal {
            settings.dailyGoalMinutes = Int16(newGoal)
            self.dailyGoal = newGoal
        }
        
        if let newLastBook = newLastBook {
            settings.lastBookReaded = newLastBook
            self.lastBookReaded = newLastBook
        }
        
        do {
            try CoreDataManager.shared.viewContext.save()
            print("UserSetting updated successfully")
        } catch {
            fatalError("Error when trying to update UserSettings: \(error)")
        }
    }
    func saveDailyGoal(minutes: Int) {
        let context = CoreDataManager.shared.viewContext
        let request = NSFetchRequest<UserSettings>(entityName: "UserSettings")
        
        do {
            let results = try context.fetch(request)
            
            if let existingSettings = results.first {
                // se já existir configuração, apenas atualiza
                existingSettings.dailyGoalMinutes = Int16(minutes)
            } else {
                // se for a primeira vez, cria o registro
                let newSettings = UserSettings(context: context)
                newSettings.dailyGoalMinutes = Int16(minutes)
            }
            
            // faz uma função de save separada 
            try context.save()
            
            self.dailyGoal = minutes
            print("Sucess when saving daily goal")
            
        } catch {
            print("Error when saving daily goal: \(error.localizedDescription)")
            context.rollback()
        }
    }
}
