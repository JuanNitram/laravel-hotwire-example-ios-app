//
//  NavigationBridgeComponent.swift
//  Demo
//
//  Created by Assistant on 01/01/24.
//

import Foundation
import Strada

final class NavigationBridgeComponent: BridgeComponent {
    override class var name: String { "navigation" }
    
    override func onReceive(message: Message) {
        guard let event = Event(rawValue: message.event) else { return }
        
        switch event {
        case .hideBars:
            handleHideBars()
        case .showBars:
            handleShowBars()
        }
    }
    
    private func handleHideBars() {
        NotificationCenter.default.post(name: NSNotification.Name("HideNavigationBarsFromWeb"), object: nil)
    }
    
    private func handleShowBars() {
        NotificationCenter.default.post(name: NSNotification.Name("ShowNavigationBarsFromWeb"), object: nil)
    }
}

private extension NavigationBridgeComponent {
    enum Event: String {
        case hideBars = "hideBars"
        case showBars = "showBars"
    }
}
