//
//  CameraBridgeComponent.swift
//  Demo
//
//  Created by Assistant on 01/01/24.
//

import Foundation
import Strada
import UIKit

final class CameraBridgeComponent: BridgeComponent {
    override class var name: String { "camera" }
    
    override func onReceive(message: Message) {
        guard let event = Event(rawValue: message.event) else {
            return
        }
        
        switch event {
        case .capture:
            handleCaptureRequest()
        case .captured:
            // This event is sent from native to web, not received
            break
        }
    }
    
    private func handleCaptureRequest() {
        guard let viewController = delegate.destination as? UIViewController else { return }
        
        let cameraController = CameraCaptureController()
        cameraController.delegate = self
        cameraController.modalPresentationStyle = .fullScreen
        
        viewController.present(cameraController, animated: true)
    }
    
    private func sendImageToWeb(_ imageData: Data, filename: String) {
        let base64String = imageData.base64EncodedString()
        
        let data = MessageData(image: base64String, filename: filename)
        
        reply(to: Event.captured.rawValue, with: data)
    }
}

// MARK: - CameraCaptureDelegate
extension CameraBridgeComponent: CameraCaptureDelegate {
    func cameraCaptureDidCaptureImage(_ image: UIImage) {
        guard let viewController = delegate.destination as? UIViewController else { return }
        
        // Dismiss camera
        viewController.dismiss(animated: true) {
            // Convert image to JPEG data
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                print("Failed to convert image to JPEG data")
                return
            }
            
            let filename = "captured_\(Date().timeIntervalSince1970).jpg"
            self.sendImageToWeb(imageData, filename: filename)
        }
    }
    
    func cameraCaptureDidCancel() {
        guard let viewController = delegate.destination as? UIViewController else { return }
        viewController.dismiss(animated: true)
    }
}

// MARK: - Events
private extension CameraBridgeComponent {
    enum Event: String {
        case capture
        case captured
    }
}

// MARK: - Message data
private extension CameraBridgeComponent {
    struct MessageData: Encodable {
        let image: String
        let filename: String
    }
}
