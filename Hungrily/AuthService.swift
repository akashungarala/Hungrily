//
//  AuthService.swift
//  Hungrily
//
//  Created by Akash Ungarala on 11/14/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

struct AuthService {
    
    var dataBaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorageReference! {
        return FIRStorage.storage().reference()
    }
    
    // 1 - Creating the Signup function
    
    func signUpChef (pictureData: NSData!, firstName: String, lastName: String, email: String, password: String, biography: String, address: String, country: String, availability: String) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                self.setChefInfo(user: user, pictureData: pictureData, firstName: firstName, lastName: lastName, password: password, biography: biography, address: address, country: country, availability: availability)
            } else {
                let appDel : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDel.signUpError(message: error!.localizedDescription)
            }
        })
    }
    
    func signUpFoodie (pictureData: NSData!, firstName: String, lastName: String, email: String, password: String, biography: String) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                self.setFoodieInfo(user: user, pictureData: pictureData, firstName: firstName, lastName: lastName, password: password, biography: biography)
            } else {
                let appDel : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDel.signUpError(message: error!.localizedDescription)
            }
        })
    }
    
    // 2 - Save the User Profile Picture to Firebase Storage, Assign Photo URL to the new user
    
    private func setChefInfo(user: FIRUser!, pictureData: NSData!, firstName: String, lastName: String, password: String, biography: String, address: String, country: String, availability: String) {
        let imageRef = storageRef.child("Users").child("\(user.displayName) (\(user.uid))")
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpeg"
        imageRef.put(pictureData as Data, metadata: metaData) { (newMetaData, error) in
            if error == nil {
                let changeRequest = user.profileChangeRequest()
                changeRequest.displayName = "\(firstName) \(lastName)"
                if let photoURL = newMetaData!.downloadURL() {
                    changeRequest.photoURL = photoURL
                }
                changeRequest.commitChanges(completion: { (error) in
                    if error == nil {
                        self.saveChefInfo(user: user, firstName: firstName, lastName: lastName, password: password, biography: biography, address: address, country: country, availability: availability)
                    } else {
                        let appDel : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDel.signUpError(message: error!.localizedDescription)
                    }
                })
            } else {
                let appDel : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDel.signUpError(message: error!.localizedDescription)
            }
        }
    }
    
    private func setFoodieInfo(user: FIRUser!, pictureData: NSData!, firstName: String, lastName: String, password: String, biography: String) {
        let imageRef = storageRef.child("Users").child("\(firstName) \(lastName) (\(user.uid))")
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpeg"
        imageRef.put(pictureData as Data, metadata: metaData) { (newMetaData, error) in
            if error == nil {
                let changeRequest = user.profileChangeRequest()
                changeRequest.displayName = "\(firstName) \(lastName)"
                if let photoURL = newMetaData!.downloadURL() {
                    changeRequest.photoURL = photoURL
                }
                changeRequest.commitChanges(completion: { (error) in
                    if error == nil {
                        self.saveFoodieInfo(user: user, firstName: firstName, lastName: lastName, password: password, biography: biography)
                    } else {
                        let appDel : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDel.signUpError(message: error!.localizedDescription)
                    }
                })
            } else {
                let appDel : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDel.signUpError(message: error!.localizedDescription)
            }
        }
    }
    
    // 3 - Save the User Info to Firebase Database
    
    private func saveChefInfo(user: FIRUser!, firstName: String, lastName: String, password: String, biography: String, address: String, country: String, availability: String) {
        let userInfo = ["category": "Chef", "uid": user.uid, "photoURL": String(describing: user.photoURL!), "firstName": firstName, "lastName": lastName, "email": user.email!, "biography": biography, "address": address, "country": country, "availability": availability]
        let userRef = dataBaseRef.child("users").child(user.uid)
        userRef.setValue(userInfo) { (error, ref) in
            if error == nil {
                print("chef info saved successfully")
                self.logIn(email: user.email!, password: password)
            } else {
                let appDel : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDel.signUpError(message: error!.localizedDescription)
            }
        }
    }
    
    private func saveFoodieInfo(user: FIRUser!, firstName: String, lastName: String, password: String, biography: String) {
        let userInfo = ["category": "Foodie", "uid": user.uid, "photoURL": String(describing: user.photoURL!), "firstName": firstName, "lastName": lastName, "email": user.email!, "biography": biography]
        let userRef = dataBaseRef.child("users").child(user.uid)
        userRef.setValue(userInfo) { (error, ref) in
            if error == nil {
                print("foodie info saved successfully")
                self.logIn(email: user.email!, password: password)
            } else {
                let appDel : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDel.signUpError(message: error!.localizedDescription)
            }
        }
    }
    
    // 4 - Logging the user in function
    
    func logIn(email: String, password: String) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                if let user = user {
                    print("\(user.displayName!) has logged in successfully")
                    let appDel : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDel.logUser()
                }
            } else {
                let appDel : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDel.loginError(message: error!.localizedDescription)
            }
        })
    }
    
}

extension HomeViewController {
    
    func resetPassword () {
        var email = ""
        let alertController = UIAlertController(title: "OOPS", message: "An email containing the steps to follow in order to reset your password has been sent to: \(email) ", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { (textfield) in
            textfield.placeholder = "Enter your email"
        })
        let textField = alertController.textFields!.first
        email = textField!.text!
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        FIRAuth.auth()?.sendPasswordReset(withEmail: email, completion: { (error) in
            if error == nil {
                self.present(alertController, animated: true, completion: nil)
            } else {
                print(error!.localizedDescription)
            }
        })
    }
    
}
