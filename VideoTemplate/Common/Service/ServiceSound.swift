//
//  ServiceSound.swift
//  VideoTemplate
//
//  Created by Alex on 3/11/23.
//

import AVFoundation

enum Extension: String {
    case mp3
    case aac
}

protocol ServiceSoundProtocol: AnyObject {
    func play(name: String, extension: Extension)
    func pause()
}

final class ServiceSound: ServiceSoundProtocol {
    
    private var player: AVAudioPlayer?
    
    func play(name: String, extension: Extension) {
        guard let url = Bundle.main.url(forResource: name, withExtension: `extension`.rawValue) else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.prepareToPlay()
            player.play()
            
        } catch let error {
            print(error)
        }
    }
    
    func pause() {
        player?.pause()
        player = nil
    }
}
