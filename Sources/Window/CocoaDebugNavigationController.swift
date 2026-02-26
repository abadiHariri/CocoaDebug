//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import UIKit

class CocoaDebugNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .dark
        navigationBar.isTranslucent = false

        navigationBar.tintColor = Color.mainGreen
        navigationBar.titleTextAttributes = [.font: UIFont.boldSystemFont(ofSize: 20),
                                             .foregroundColor: Color.mainGreen]
        
        //bugfix #issues-158
        if #available(iOS 13, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .black
            appearance.shadowColor = .clear    //removing navigationbar 1 px bottom border.
            appearance.titleTextAttributes = [.font: UIFont.boldSystemFont(ofSize: 20),
                                              .foregroundColor: Color.mainGreen]
            self.navigationBar.standardAppearance = appearance
            self.navigationBar.scrollEdgeAppearance = appearance
        }
    }
}

