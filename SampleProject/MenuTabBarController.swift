//
//  MenuTabbarController.swift
//  SampleProject
//
//  Created by Paolo Hilario on 6/25/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import UIKit
import SQLite

class MenuTabBarController: UITabBarController {

    let utilities           = Utilities()
    var clientID            = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clientID = utilities.getUserID()
        setupTabBar()
    }
    
    func setupTabBar(){
        
        var arrayControllers    = [UIViewController]()
        self.tabBar.tintColor   = #colorLiteral(red: 0.4666666667, green: 0.2549019608, blue: 0.003921568627, alpha: 1)
        
        let homeController      = createNavController(vc: MainMenuController(), selected: UIImage(named: "Home")!, unselected: UIImage(named: "Home")!, title: "Home")
        let dashboardController = createNavController(vc: UserProfileTab(), selected: UIImage(named: "a_dashboard")!, unselected: UIImage(named: "a_dashboard")!, title: "Dashboard")
        
        arrayControllers.append(homeController)
        arrayControllers.append(dashboardController)
        if(clientID > 0){
            let profileController = createNavController(vc: UserProfileController(), selected: UIImage(named: "Profile")!, unselected: UIImage(named: "Profile")!, title: "Profile")
            arrayControllers.append(profileController)
        }
        
        viewControllers     = arrayControllers
        let selectedColor   = #colorLiteral(red: 0.4666666667, green: 0.2549019608, blue: 0.003921568627, alpha: 1)
        let unselectedColor = UIColor.lightGray
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: unselectedColor], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: selectedColor], for: .selected)
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension UITabBarController{
    
    func createNavController(vc:UIViewController,selected:UIImage,unselected:UIImage,title:String) -> UINavigationController{
        
        var viewController = vc
        let storyBoard = UIStoryboard(name:"Main",bundle:nil)
        
        if vc is MainMenuController{
            viewController  = storyBoard.instantiateViewController(withIdentifier: "MainMenuController") as! MainMenuController
        }
        else if vc is UserProfileTab{
            viewController  = storyBoard.instantiateViewController(withIdentifier: "UserProfileTab") as! UserProfileTab
        }
        else{
             viewController  = storyBoard.instantiateViewController(withIdentifier: "UserProfileController") as! UserProfileController
        }

        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.selectedImage      = selected
        navController.tabBarItem.title              = title
        navController.tabBarItem.image              = unselected
        navController.navigationBar.barTintColor    = #colorLiteral(red: 0.5725490196, green: 0.7803921569, blue: 0.2509803922, alpha: 1)
        navController.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        return navController
    }
    
    
}




