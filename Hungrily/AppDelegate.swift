//
//  AppDelegate.swift
//  Hungrily
//
//  Created by Akash Ungarala on 11/8/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    override init() {
        super.init()
        FIRApp.configure()
    }
    
    func logUser() {
        if FIRAuth.auth()!.currentUser != nil {
            let userRef = FIRDatabase.database().reference().child("users/\(FIRAuth.auth()!.currentUser!.uid)")
            userRef.observe(.value, with: { (snapshot) in
                let category = (snapshot.value! as! NSDictionary)["category"] as! String
                if category == "Chef" {
                    let ChefHomeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChefHomeViewController") as! ChefHomeViewController
                    self.window?.rootViewController = ChefHomeViewController
                } else if category == "Foodie" {
                    let FoodieHomeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FoodieHomeViewController") as! FoodieHomeViewController
                    self.window?.rootViewController = FoodieHomeViewController
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    func loginError(message: String) {
        let HomeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        HomeViewController.errorMessage = message
        self.window?.rootViewController = HomeViewController
    }
    
    func signUpError(message: String) {
        let SignUpViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        SignUpViewController.errorMessage = message
        self.window?.rootViewController = SignUpViewController
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        logUser()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {}

}
