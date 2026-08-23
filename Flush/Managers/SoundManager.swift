//
//  SoundManager.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 23/08/26.
//

import Foundation
import AVFoundation


class SoundManager {
    static let shared = SoundManager()
    private var audioPlayer: AVAudioPlayer?

    enum SoundType {
        case splash
        case success
        
        var fileName: (name: String, extension: String) {
            switch self {
            case .splash: return ("splash", "mp3")
            case .success: return ("readSucess", "mp3")
            }
        }
    }

    func playSound(named sound: SoundType) {
        let file = sound.fileName
        
        guard let url = Bundle.main.url(forResource: file.name, withExtension: file.extension) else {
            print("File '\(file.name).\(file.extension)' not founded")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error when reproducing sound: \(error.localizedDescription)")
        }
    }
}
