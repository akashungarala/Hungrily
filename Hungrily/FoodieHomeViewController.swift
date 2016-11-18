//
//  FoodieHomeViewController.swift
//  Hungrily
//
//  Created by Akash Ungarala on 11/14/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class FoodieHomeViewController: UIViewController {
    
    @IBOutlet weak var avatar: UIImageView! {
        didSet {
            avatar.layer.cornerRadius = 10
            avatar.clipsToBounds = true
        }
    }
    
    var foodie: Foodie!
    var dataBaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    var storageRef: FIRStorage {
        return FIRStorage.storage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserInfo()
    }
    
    @IBAction func logOut(_ sender: AnyObject) {
        if FIRAuth.auth()!.currentUser != nil {
            // there is a user signed in
            do {
                try? FIRAuth.auth()!.signOut()
                if FIRAuth.auth()?.currentUser == nil {
                    let HomeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                    self.present(HomeViewController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func loadUserInfo() {
        let userRef = dataBaseRef.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
        userRef.observe(.value, with: { (snapshot) in
            self.foodie = Foodie(snapshot: snapshot)
            let imageURL = self.foodie.photoURL!
            self.storageRef.reference(forURL: imageURL).data(withMaxSize: 10*1024*1024, completion: { (imgData, error) in
                if error == nil {
                    DispatchQueue.main.async {
                        if let data = imgData {
                            self.avatar.image = UIImage(data: data)
                        }
                    }
                } else {
                    self.avatar.image = UIImage(named: "Default Avatar")
                }
            })
        }) { (error) in
            self.avatar.image = UIImage(named: "Default Avatar")
        }
    }
    
    @IBAction func backToFoodieHome(storyboard: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChefsSegue" {
            let destination = segue.destination as! ChefsViewController
            destination.foodie = self.foodie
        }
    }
    
}
