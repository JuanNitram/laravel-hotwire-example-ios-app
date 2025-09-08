//
//  TabBarController.swift
//  Demo
//
//  Created by Assistant on 01/01/24.
//

import UIKit
import Turbo
import Strada

class TabBarController: UITabBarController {
    
    var session: Session! {
        didSet {
            configureSessionsIfReady()
        }
    }
    var modalSession: Session! {
        didSet {
            configureSessionsIfReady()
        }
    }
    private let rootURL = Demo.current
    
    // Navigation controllers for each tab
    private var dashboardNavController: TurboNavigationController!
    private var settingsNavController: TurboNavigationController!
    private var isInitialSetupComplete = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        // Create navigation controllers for each tab
        dashboardNavController = TurboNavigationController()
        settingsNavController = TurboNavigationController()
        
        // Configure tab bar items
        dashboardNavController.tabBarItem = UITabBarItem(
            title: "Dashboard",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        settingsNavController.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gearshape"),
            selectedImage: UIImage(systemName: "gearshape.fill")
        )
        
        // Set view controllers
        viewControllers = [dashboardNavController, settingsNavController]
        
        // Set default selected tab (Dashboard)
        selectedIndex = 0
        
        // Configure tab bar appearance
        tabBar.tintColor = UIColor.black
        tabBar.unselectedItemTintColor = UIColor.systemGray
        tabBar.backgroundColor = UIColor.systemBackground
        
        // Add subtle border to top of tab bar
        let tabBarBorder = UIView()
        tabBarBorder.backgroundColor = UIColor.separator.withAlphaComponent(0.3)
        tabBarBorder.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(tabBarBorder)
        
        NSLayoutConstraint.activate([
            tabBarBorder.topAnchor.constraint(equalTo: tabBar.topAnchor),
            tabBarBorder.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            tabBarBorder.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            tabBarBorder.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    private func configureSessionsIfReady() {
        guard !isInitialSetupComplete,
              session != nil,
              modalSession != nil,
              dashboardNavController != nil,
              settingsNavController != nil else { return }
        
        // Configure sessions for each navigation controller
        dashboardNavController.session = session
        dashboardNavController.modalSession = modalSession
        
        settingsNavController.session = session
        settingsNavController.modalSession = modalSession
        
        // Load initial routes now that sessions are configured
        loadInitialRoutes()
        isInitialSetupComplete = true
    }
    
    private func loadInitialRoutes() {
        // Only load dashboard route initially
        let dashboardURL = rootURL.appendingPathComponent("/dashboard")
        let dashboardProperties = session.pathConfiguration?.properties(for: dashboardURL) ?? [:]
        dashboardNavController.route(
            url: dashboardURL,
            options: VisitOptions(action: .replace),
            properties: dashboardProperties
        )
        
        // Settings route will be loaded when the user first taps the settings tab
    }
    
    // Handle tab selection
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.firstIndex(of: item) else { return }
        
        switch index {
        case 0: // Dashboard
            // Dashboard is already loaded, no need to reload unless we want to refresh
            break
        case 1: // Settings
            // Load settings route if it hasn't been loaded yet
            if settingsNavController.viewControllers.isEmpty {
                let settingsURL = rootURL.appendingPathComponent("/settings")
                let properties = session.pathConfiguration?.properties(for: settingsURL) ?? [:]
                settingsNavController.route(
                    url: settingsURL,
                    options: VisitOptions(action: .replace),
                    properties: properties
                )
                
                // Notify parent that settings was loaded so hamburger button can be added
                NotificationCenter.default.post(name: NSNotification.Name("SettingsTabLoaded"), object: settingsNavController)
            }
        default:
            break
        }
    }
    
    // Public method to navigate to a specific URL
    func navigate(to url: URL, options: VisitOptions = VisitOptions(), properties: PathProperties = [:]) {
        let path = url.path
        
        // Determine which tab should handle this URL
        if path.hasPrefix("/dashboard") {
            selectedIndex = 0
            dashboardNavController.route(url: url, options: options, properties: properties)
        } else if path.hasPrefix("/settings") {
            selectedIndex = 1
            settingsNavController.route(url: url, options: options, properties: properties)
        } else {
            // Default to dashboard for unknown routes
            selectedIndex = 0
            dashboardNavController.route(url: url, options: options, properties: properties)
        }
    }
}
