//
//  ViewController.swift
//  VideoTemplate
//
//  Created by Alex on 3/11/23.
//

import simd
import UIKit
import SnapKit


protocol TemplateViewControllerProtocol: AnyObject {}

class TemplateViewController: UIViewController {

    var presenter: TemplatePresenterProtocol!
        
    private let viewRender = ViewRender(frame: UIScreen.main.bounds)
    private let buttonPlay = UIButton()
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    private var images: [(last: UIImage?, image: UIImage, mask: UIImage, type: ImageType)] = []
    private let speedTimeFrame = 0.5
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = #colorLiteral(red: 0.08100076765, green: 0.08100076765, blue: 0.08100076765, alpha: 1)
        setupViewRender()
        setupButtonPlay()
        
        uploadImages()
        setFrameDefault()
    }

    
    private func setupViewRender() {
        view.addSubview(viewRender)
        
        viewRender.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalTo(view.frame.height/2)
            make.height.equalTo(view.frame.width*4/3)
        }
    }
    
    private func setupButtonPlay() {
        let attr = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)]
        
        buttonPlay.backgroundColor = #colorLiteral(red: 0.9977526069, green: 0.6595464945, blue: 0.03938799351, alpha: 1)
        buttonPlay.clipsToBounds = true
        buttonPlay.layer.cornerRadius = 22
        buttonPlay.setAttributedTitle(NSAttributedString(string: "Start", attributes: attr), for: .normal)
        buttonPlay.addTarget(self, action: #selector(play), for: .touchUpInside)
        view.addSubview(buttonPlay)
        
        buttonPlay.snp.makeConstraints { make in
            make.width.equalTo(view.frame.width/2)
            make.height.equalTo(44)
            make.leading.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(80)
        }
    }
}


private extension TemplateViewController {
    
    func uploadImages() {
        (1...8).forEach { index in
            if let image = UIImage(named: "image_\(index)"), let mask = presenter.segmentationImage(image) {
                images.append((UIImage(named: "image_\(index-1)"), image, mask, .mask))
                images.append((UIImage(named: "image_\(index-1)"), image, image, .image))
            }
        }
    }
    
    func setFrameDefault() {
        let textures = presenter.textures(from: images[1])
        let dataFrame = dataFrame(texture: textures.image, type: textures.type)
        
        viewRender.modelFrame = ModelFrame(image: (textures.last, textures.image, textures.mask), data: dataFrame)
        viewRender.draw()
    }
    
    @objc
    func play() {
        let newImages = images.dropFirst()
        var counter = 0 { didSet { if newImages.count == counter { presenter.pauseMusic() }}}
        
        presenter.playMusic()
                
        newImages.forEach { image in
            let textures = presenter.textures(from: image)
            let dataFrame = dataFrame(texture: textures.image, type: textures.type)
            
            viewRender.modelFrame = ModelFrame(image: (textures.last, textures.image, textures.mask), data: dataFrame)
            viewRender.draw()
            
            counter += 1

            RunLoop.current.run(until: Date() + speedTimeFrame)
        }
    }
    
    // Пока не трогаем, нужно для выравнивания кадра (aspectFill, aspectFit)
    func dataFrame(texture: Texture?, type: ImageType) -> DataFrame? {
        guard let texture = texture else { return nil }
        
        let maxSide = max(texture.texture.width, texture.texture.height)
        let minSide = min(texture.texture.width, texture.texture.height)
        let ratio = Double(maxSide) / Double(minSide)
        let isLandscape = texture.texture.width > texture.texture.height
        let screenRender = UIScreen.main.nativeBounds
        
        let size = vector_float2(x: Float(isLandscape ? screenRender.width : screenRender.width * ratio),
                                 y: Float(isLandscape ? screenRender.width / ratio : screenRender.width / ratio))
        return DataFrame(type: type, overlayStyle: OverlayStyle.none, size: size)
    }
}

extension TemplateViewController: TemplateViewControllerProtocol {}
