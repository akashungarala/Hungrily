//
//  RecipeCell.swift
//  Hungrily
//
//  Created by Akash Ungarala on 11/14/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class RecipeCell: UITableViewCell {
    
    @IBOutlet weak var photo: UIImageView! {
        didSet {
            photo.layer.cornerRadius = 10
            photo.clipsToBounds = true
        }
    }
    @IBOutlet weak var recipeTitle: UILabel!
    @IBOutlet weak var cuisine: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var ingredients: UILabel!
    
    var dataBaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    var storageRef: FIRStorage {
        return FIRStorage.storage()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(recipe: Recipe) {
        self.recipeTitle.text = recipe.title!
        self.cuisine.text = recipe.cuisine!
        self.category.text = recipe.category!
        self.ingredients.text = recipe.ingredients!
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

}
