//
//  Foodie.swift
//  Hungrily
//
//  Created by Akash Ungarala on 11/14/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

struct Foodie {
    
    var ref: FIRDatabaseReference?
    var uid: String!
    var key: String?
    var category: String!
    var photoURL: String!
    var firstName: String!
    var lastName: String!
    var email: String?
    var biography: String?
    
    init (snapshot: FIRDataSnapshot) {
        ref = snapshot.ref
        key = snapshot.key
        uid = (snapshot.value! as! NSDictionary)["uid"] as! String
        category = (snapshot.value! as! NSDictionary)["category"] as! String
        photoURL = (snapshot.value! as! NSDictionary)["photoURL"] as! String
        firstName = (snapshot.value! as! NSDictionary)["firstName"] as! String
        lastName = (snapshot.value! as! NSDictionary)["lastName"] as! String
        email = (snapshot.value! as! NSDictionary)["email"] as? String
        biography = (snapshot.value! as! NSDictionary)["biography"] as? String
    }
    
}
