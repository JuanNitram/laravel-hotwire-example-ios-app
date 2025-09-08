//
//  SidebarContainerController.swift
//  Demo
//
//  Created by Assistant on 01/01/24.
//

import UIKit
import Turbo

class SidebarContainerController: UIViewController {
    
    private let mainTabBarController: TabBarController
    private let sidebarMenuController: SidebarMenuController
    
    private var isSidebarOpen = false
    private let sidebarWidth: CGFloat = 280
    
    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }()
    
    private var sidebarLeadingConstraint: NSLayoutConstraint!
    
    init(tabBarController: TabBarController) {
        self.mainTabBarController = tabBarController
        self.sidebarMenuController = SidebarMenuController()
        super.init(nibName: nil, bundle: nil)
        
        self.sidebarMenuController.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupHamburgerButton()
        setupNotificationObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        
        // Add tab bar controller as child
        addChild(mainTabBarController)
        view.addSubview(mainTabBarController.view)
        mainTabBarController.view.translatesAutoresizingMaskIntoConstraints = false
        mainTabBarController.didMove(toParent: self)
        
        // Add overlay view
        view.addSubview(overlayView)
        
        // Add sidebar menu controller as child
        addChild(sidebarMenuController)
        view.addSubview(sidebarMenuController.view)
        sidebarMenuController.view.translatesAutoresizingMaskIntoConstraints = false
        sidebarMenuController.didMove(toParent: self)
        
        // Setup constraints
        sidebarLeadingConstraint = sidebarMenuController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -sidebarWidth)
        
        NSLayoutConstraint.activate([
            // Tab bar controller constraints
            mainTabBarController.view.topAnchor.constraint(equalTo: view.topAnchor),
            mainTabBarController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainTabBarController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainTabBarController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Overlay constraints
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Sidebar constraints
            sidebarLeadingConstraint,
            sidebarMenuController.view.topAnchor.constraint(equalTo: view.topAnchor),
            sidebarMenuController.view.widthAnchor.constraint(equalToConstant: sidebarWidth),
            sidebarMenuController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Add shadow to sidebar
        sidebarMenuController.view.layer.shadowColor = UIColor.black.cgColor
        sidebarMenuController.view.layer.shadowOpacity = 0.3
        sidebarMenuController.view.layer.shadowOffset = CGSize(width: 2, height: 0)
        sidebarMenuController.view.layer.shadowRadius = 5
    }
    
    private func setupHamburgerButton() {
        // Add hamburger button to all navigation controllers in tab bar
        if let viewControllers = mainTabBarController.viewControllers {
            for viewController in viewControllers {
                if let navController = viewController as? UINavigationController {
                    addHamburgerButtonToNavigationController(navController)
                }
            }
        }
    }
    
    private func addHamburgerButtonToNavigationController(_ navController: UINavigationController) {
        // Create hamburger button with 3 lines of different sizes
        let hamburgerButton = createHamburgerButton()
        hamburgerButton.addTarget(self, action: #selector(hamburgerButtonTapped), for: .touchUpInside)
        
        let barButtonItem = UIBarButtonItem(customView: hamburgerButton)
        navController.topViewController?.navigationItem.leftBarButtonItem = barButtonItem
        
        // Configure navigation bar appearance to match tab bar
        configureNavigationBarAppearance(for: navController)
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(settingsTabLoaded(_:)),
            name: NSNotification.Name("SettingsTabLoaded"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(navigationControllerDidSetViewController(_:)),
            name: NSNotification.Name("NavigationControllerDidSetViewController"),
            object: nil
        )
    }
    
    @objc private func settingsTabLoaded(_ notification: Notification) {
        guard let navController = notification.object as? UINavigationController else { return }
        
        // Add hamburger button to the newly loaded settings navigation controller
        addHamburgerButtonToNavigationController(navController)
    }
    
    @objc private func navigationControllerDidSetViewController(_ notification: Notification) {
        guard let navController = notification.object as? UINavigationController,
              let viewController = notification.userInfo?["viewController"] as? UIViewController else { return }
        
        // Check if this navigation controller belongs to our tab bar
        if let tabViewControllers = mainTabBarController.viewControllers,
           tabViewControllers.contains(navController) {
            
            // Add hamburger button to the new view controller
            let hamburgerButton = createHamburgerButton()
            hamburgerButton.addTarget(self, action: #selector(hamburgerButtonTapped), for: .touchUpInside)
            let barButtonItem = UIBarButtonItem(customView: hamburgerButton)
            
            viewController.navigationItem.leftBarButtonItem = barButtonItem
        }
    }
    
    private func configureNavigationBarAppearance(for navigationController: UINavigationController) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // Set background color to match tab bar
        appearance.backgroundColor = UIColor.systemBackground
        
        // Add subtle bottom border
        appearance.shadowColor = UIColor.separator.withAlphaComponent(0.3)
        appearance.shadowImage = createBorderImage()
        
        // Apply appearance
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.compactAppearance = appearance
        
        if #available(iOS 15.0, *) {
            navigationController.navigationBar.compactScrollEdgeAppearance = appearance
        }
    }
    
    private func createBorderImage() -> UIImage? {
        let size = CGSize(width: 1, height: 0.5)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            UIColor.separator.withAlphaComponent(0.3).setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
    
    private func createHamburgerButton() -> UIButton {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        // Create hamburger icon with 3 lines of different sizes
        let image = createHamburgerIcon()
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.label
        
        return button
    }
    
    private func createHamburgerIcon() -> UIImage? {
        let size = CGSize(width: 24, height: 18)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            cgContext.setStrokeColor(UIColor.label.cgColor)
            cgContext.setLineWidth(2.0)
            cgContext.setLineCap(.round)
            
            // Top line (longest)
            cgContext.move(to: CGPoint(x: 0, y: 3))
            cgContext.addLine(to: CGPoint(x: 24, y: 3))
            
            // Middle line (medium)
            cgContext.move(to: CGPoint(x: 0, y: 9))
            cgContext.addLine(to: CGPoint(x: 18, y: 9))
            
            // Bottom line (shortest)
            cgContext.move(to: CGPoint(x: 0, y: 15))
            cgContext.addLine(to: CGPoint(x: 12, y: 15))
            
            cgContext.strokePath()
        }
    }
    
    @objc private func hamburgerButtonTapped() {
        toggleSidebar()
    }
    
    @objc private func overlayTapped() {
        closeSidebar()
    }
    
    private func toggleSidebar() {
        if isSidebarOpen {
            closeSidebar()
        } else {
            openSidebar()
        }
    }
    
    private func openSidebar() {
        isSidebarOpen = true
        sidebarLeadingConstraint.constant = 0
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.view.layoutIfNeeded()
            self.overlayView.alpha = 1
        }
    }
    
    private func closeSidebar() {
        isSidebarOpen = false
        sidebarLeadingConstraint.constant = -sidebarWidth
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.view.layoutIfNeeded()
            self.overlayView.alpha = 0
        }
    }
    
    // Public method to navigate (used by SceneController)
    func navigate(to url: URL, options: VisitOptions = VisitOptions(), properties: PathProperties = [:]) {
        mainTabBarController.navigate(to: url, options: options, properties: properties)
    }
    
    // Forward session properties
    var session: Session! {
        get { mainTabBarController.session }
        set { mainTabBarController.session = newValue }
    }
    
    var modalSession: Session! {
        get { mainTabBarController.modalSession }
        set { mainTabBarController.modalSession = newValue }
    }
}

// MARK: - SidebarMenuDelegate
extension SidebarContainerController: SidebarMenuDelegate {
    
    func sidebarMenuDidSelectDashboard() {
        mainTabBarController.selectedIndex = 0
        let dashboardURL = URL(string: "http://localhost:8000/dashboard")!
        mainTabBarController.navigate(to: dashboardURL, options: VisitOptions(action: .replace))
    }
    
    func sidebarMenuDidSelectSettings() {
        mainTabBarController.selectedIndex = 1
        let settingsURL = URL(string: "http://localhost:8000/settings")!
        mainTabBarController.navigate(to: settingsURL, options: VisitOptions(action: .replace))
    }
    
    func sidebarMenuShouldClose() {
        closeSidebar()
    }
}
