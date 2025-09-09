//
//  FloatingCameraButton.swift
//  Demo
//
//  Created by Assistant on 01/01/24.
//

import UIKit

protocol FloatingCameraButtonDelegate: AnyObject {
    func floatingCameraButtonTapped()
}

class FloatingCameraButton: UIView {
    
    weak var delegate: FloatingCameraButtonDelegate?
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Create camera icon
        let cameraImage = UIImage(systemName: "camera.fill")
        button.setImage(cameraImage, for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        // Add press animation
        button.addTarget(self, action: #selector(buttonPressed), for: .touchDown)
        button.addTarget(self, action: #selector(buttonReleased), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.widthAnchor.constraint(equalToConstant: 56),
            button.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    @objc private func buttonTapped() {
        delegate?.floatingCameraButtonTapped()
    }
    
    @objc private func buttonPressed() {
        UIView.animate(withDuration: 0.1) {
            self.button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc private func buttonReleased() {
        UIView.animate(withDuration: 0.1) {
            self.button.transform = CGAffineTransform.identity
        }
    }
    
    func show(animated: Bool = true) {
        guard animated else {
            alpha = 1
            transform = CGAffineTransform.identity
            return
        }
        
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.alpha = 1
            self.transform = CGAffineTransform.identity
        }
    }
    
    func hide(animated: Bool = true) {
        guard animated else {
            alpha = 0
            return
        }
        
        UIView.animate(withDuration: 0.2) {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }
    }
}
