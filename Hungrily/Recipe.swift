//
//  Recipe.swift
//  Hungrily
//
//  Created by Akash Ungarala on 11/14/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

struct Recipe {
    
    var uid: String!
    var ref: FIRDatabaseReference?
    var key: String?
    var chefId: String!
    var title: String!
    var cuisine: String!
    var category: String!
    var ingredients: String!
    var description: String!
    var photoURL: String!
    
    init (snapshot: FIRDataSnapshot) {
        ref = snapshot.ref
        key = snapshot.key
        uid = (snapshot.value! as! NSDictionary)["uid"] as! String
        chefId = (snapshot.value! as! NSDictionary)["chefId"] as! String
        title = (snapshot.value! as! NSDictionary)["title"] as! String
        cuisine = (snapshot.value! as! NSDictionary)["cuisine"] as! String
        category = (snapshot.value! as! NSDictionary)["category"] as! String
        ingredients = (snapshot.value! as! NSDictionary)["ingredients"] as! String
        description = (snapshot.value! as! NSDictionary)["description"] as! String
        photoURL = (snapshot.value! as! NSDictionary)["photoURL"] as! String
    }
    
}
