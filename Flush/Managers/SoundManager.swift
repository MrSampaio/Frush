//
//  SoundManager.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 23/08/26.
//

import Foundation

import Foundation
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    private var audioPlayer: AVAudioPlayer?

    enum SoundType: String {
        case splash = "splash"
        case success = "success"
    }

    func playSound(named sound: SoundType) {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else {
            print("Sounf file '\(sound.rawValue)' not founded")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error when reproducing sound \(error.localizedDescription)")
        }
    }
}
