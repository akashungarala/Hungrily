//
//  ChefRecipeDetailViewController.swift
//  Hungrily
//
//  Created by Akash Ungarala on 11/14/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit
import FirebaseStorage

class ChefRecipeDetailViewController: UIViewController {
    
    @IBOutlet weak var recipeTitle: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var cuisine: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var ingredients: UILabel!
    @IBOutlet weak var recipeDescription: UITextView!
    
    var recipe: Recipe!
    var storageRef: FIRStorage {
        return FIRStorage.storage()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.recipeTitle.text = recipe.title!
        self.cuisine.text = recipe.cuisine!
        self.category.text = recipe.category!
        self.ingredients.text = recipe.ingredients!
        self.recipeDescription.text = recipe.description!
        let imageURL = recipe.photoURL!
        self.storageRef.reference(forURL: imageURL).data(withMaxSize: 10*1024*1024, completion: { (imgData, error) in
            if error == nil {
                DispatchQueue.main.async {
                    if let data = imgData {
                        self.photo.image = UIImage(data: data)
                    }
                }
            } else {
                self.photo.image = UIImage(named: "Foodie")
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {}

}
