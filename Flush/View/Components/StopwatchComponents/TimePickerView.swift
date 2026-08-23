////
////  TimePickerView.swift
////  CH4-Books
////
////  Created by Julio Sampaio on 22/08/26.
////
//
//import Foundation
//import SwiftUI
//
//struct TimePickerView: View {
//    var body: some View {
//        // Picker de Horas
//        Picker("Horas", selection: Binding(
//            get: { Int(selectedDuration) / 3600 },
//            set: { newHours in
//                let currentMinutes = (Int(selectedDuration) % 3600) / 60
//                
//                // Separado para o compilador não chorar
//                let hoursInSeconds = Double(newHours * 3600)
//                let minutesInSeconds = Double(currentMinutes * 60)
//                let newTotal = hoursInSeconds + minutesInSeconds
//                
//                selectedDuration = newTotal
//                stopwatchViewModel.totalTime = newTotal
//                stopwatchViewModel.elapsedTime = newTotal
//            }
//        )) {
//            ForEach(0..<24, id: \.self) { hour in
//                Text("\(hour) h").tag(hour)
//            }
//        }
//        .pickerStyle(.wheel)
//
//        // Picker de Minutos
//        Picker("Minutos", selection: Binding(
//            get: { (Int(selectedDuration) % 3600) / 60 },
//            set: { newMinutes in
//                let currentHours = Int(selectedDuration) / 3600
//                
//                // Separado para o compilador não chorar
//                let hoursInSeconds = Double(currentHours * 3600)
//                let minutesInSeconds = Double(newMinutes * 60)
//                let newTotal = hoursInSeconds + minutesInSeconds
//                
//                selectedDuration = newTotal
//                stopwatchViewModel.totalTime = newTotal
//                stopwatchViewModel.elapsedTime = newTotal
//            }
//        )) {
//            ForEach(0..<60, id: \.self) { minute in
//                Text("\(minute) min").tag(minute)
//            }
//        }
//        .pickerStyle(.wheel)
//
//    }
//}
