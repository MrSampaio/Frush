//
//  VideoPlayerView.swift
//  CH4-Books
//
//  Created by Julio Sampaio on 26/08/26.
//
import SwiftUI
import AVFoundation

struct VideoPlayerView: UIViewRepresentable {
    let fileName: String
    let fileExtension: String
    /// Chamado quando o vídeo termina
    var onFinish: () -> Void = {}
    
    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        view.configure(fileName: fileName,
                       fileExtension: fileExtension,
                       onFinish: onFinish)
        return view
    }
    
    func updateUIView(_ uiView: PlayerUIView, context: Context) { }
    
    static func dismantleUIView(_ uiView: PlayerUIView, coordinator: ()) {
        uiView.cleanup()
    }
}

final class PlayerUIView: UIView {
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var onFinish: () -> Void = {}
    
    // faz a camada do player acompanhar o tamanho da view
    override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }
    
    func configure(fileName: String, fileExtension: String, onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print("Vídeo \(fileName).\(fileExtension) não encontrado no bundle")
            onFinish()   // não trava o fluxo se o arquivo faltar
            return
        }
        
        let player = AVPlayer(url: url)
        player.actionAtItemEnd = .none
        player.isMuted = true          // splash com áudio costuma incomodar
        self.player = player
        
        if let layer = self.layer as? AVPlayerLayer {
            layer.player = player
            layer.videoGravity = .resizeAspectFill
            self.playerLayer = layer
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoDidEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
        
        player.play()
    }
    
    @objc private func videoDidEnd() {
        onFinish()
    }
    
    func cleanup() {
        player?.pause()
        player = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
