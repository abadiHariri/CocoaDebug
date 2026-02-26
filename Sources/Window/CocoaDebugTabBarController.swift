//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import UIKit

class CocoaDebugTabBarController: UITabBarController {
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.keyWindow?.endEditing(true)

        overrideUserInterfaceStyle = .dark
        self.delegate = self

        setChildControllers()
        
        let savedIndex = CocoaDebugSettings.shared.tabBarSelectItem
        let maxIndex = (self.viewControllers?.count ?? 1) - 1
        self.selectedIndex = min(savedIndex, max(0, maxIndex))
        self.tabBar.tintColor = Color.mainGreen
        
        //bugfix #issues-158
        if #available(iOS 13, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.shadowColor = .clear    //removing navigationbar 1 px bottom border.
//            self.tabBar.appearance().standardAppearance = appearance
//            self.tabBar.appearance().scrollEdgeAppearance = appearance
            self.tabBar.standardAppearance = appearance
            if #available(iOS 15.0, *) {
                self.tabBar.scrollEdgeAppearance = appearance
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CocoaDebugSettings.shared.visible = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CocoaDebugSettings.shared.visible = false
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        WindowHelper.shared.displayedList = false
    }
    
    //MARK: - private
    func setChildControllers() {
        let bundle = Bundle(for: CocoaDebug.self)
        let network = makeNav(root: NetworkViewController(),  tabTitle: "Network", tabImage: "_icon_file_type_network", bundle: bundle)
        let logs    = makeNav(root: LogViewController(),      tabTitle: "Logs",    tabImage: "_icon_file_type_logs",    bundle: bundle)
        let app     = makeNav(root: AppInfoViewController(),  tabTitle: "App",     tabImage: "_icon_file_type_app",     bundle: bundle)

        var navs: [UINavigationController] = [network, logs, app]

        if let additionalViewController = CocoaDebugSettings.shared.additionalViewController {
            let nav = CocoaDebugNavigationController(rootViewController: additionalViewController)
            nav.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 4)
            navs.append(nav)
        }

        self.viewControllers = navs

        // Add close button to each tab's root VC
        let closeImage = UIImage(named: "_icon_file_type_close", in: bundle, compatibleWith: nil)
                       ?? UIImage(systemName: "xmark")
        for nav in navs {
            let btn = UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(dismissDebugger))
            btn.tintColor = Color.mainGreen
            nav.topViewController?.navigationItem.leftBarButtonItem = btn
        }
    }

    @objc private func dismissDebugger() {
        dismiss(animated: true)
    }

    private func makeNav(root: UIViewController, tabTitle: String, tabImage: String, bundle: Bundle) -> CocoaDebugNavigationController {
        let nav = CocoaDebugNavigationController(rootViewController: root)
        let image = UIImage(named: tabImage, in: bundle, compatibleWith: nil)
        nav.tabBarItem = UITabBarItem(title: tabTitle, image: image, selectedImage: image)
        return nav
    }
    
    //MARK: - show more than 5 tabs by CocoaDebug
    //    override var traitCollection: UITraitCollection {
    //        var realTraits = super.traitCollection
    //        var lieTrait = UITraitCollection.init(horizontalSizeClass: .regular)
    //        return UITraitCollection(traitsFrom: [realTraits, lieTrait])
    //    }
}

//MARK: - UITabBarDelegate
extension CocoaDebugTabBarController {

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let items = self.tabBar.items else { return }
        for index in 0...items.count-1 {
            if item == items[index] {
                CocoaDebugSettings.shared.tabBarSelectItem = index
            }
        }
    }
}

//MARK: - UITabBarControllerDelegate
extension CocoaDebugTabBarController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard viewController !== selectedViewController else { return true }
        let transition = CATransition()
        transition.duration = 0.2
        transition.type = .fade
        view.layer.add(transition, forKey: nil)
        return true
    }
}
