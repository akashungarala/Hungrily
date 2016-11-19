//
//  ChefRecipeDetailViewController.swift
//  Hungrily
//
//  Created by Akash Ungarala on 11/14/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class RecipeDetailViewController: UIViewController {
    
    @IBOutlet weak var backFoodie: UIButton!
    @IBOutlet weak var backChef: UIButton!
    @IBOutlet weak var backFoodieChef: UIButton!
    @IBOutlet weak var order: UIButton!
    @IBOutlet weak var recipeTitle: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var avatar: UIImageView! {
        didSet {
            avatar.layer.cornerRadius = avatar.frame.size.width / 2
            avatar.clipsToBounds = true
        }
    }
    @IBOutlet weak var photo: UIImageView! {
        didSet {
            photo.layer.cornerRadius = 10
            photo.clipsToBounds = true
        }
    }
    @IBOutlet weak var cuisine: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var ingredients: UILabel!
    @IBOutlet weak var recipeDescription: UITextView!
    
    var recipe: Recipe!
    var sender: String!
    var dataBaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    var storageRef: FIRStorage {
        return FIRStorage.storage()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.sender == "Chef" {
            backChef.isHidden = false
            backFoodie.isHidden = true
            backFoodieChef.isHidden = true
            order.isHidden = true
            name.isHidden = true
            avatar.isHidden = true
        } else if self.sender == "Foodie" {
            backChef.isHidden = true
            backFoodie.isHidden = false
            backFoodieChef.isHidden = true
            order.isHidden = false
            name.isHidden = false
            avatar.isHidden = false
            loadChefInfo(id: recipe.chefId!)
        } else if self.sender == "FoodieChef" {
            backChef.isHidden = true
            backFoodie.isHidden = true
            backFoodieChef.isHidden = false
            order.isHidden = false
            name.isHidden = false
            avatar.isHidden = false
            loadChefInfo(id: recipe.chefId!)
        }
        self.recipeTitle.text = recipe.title!
        self.cuisine.text = recipe.cuisine!
        self.category.text = recipe.category!
        self.price.text = "\(recipe.price!) $"
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
    
    @IBAction func backToRecipeDetail(storyboard: UIStoryboardSegue) {}
    
    func loadChefInfo(id: String) {
        let userRef = dataBaseRef.child("users/\(id)")
        userRef.observe(.value, with: { (snapshot) in
            let chef = Chef(snapshot: snapshot)
            self.name.text = "\(chef.firstName!) \(chef.lastName!)"
            let imageURL = chef.photoURL!
            self.storageRef.reference(forURL: imageURL).data(withMaxSize: 10*1024*1024, completion: { (imgData, error) in
                if error == nil {
                    DispatchQueue.main.async {
                        if let data = imgData {
                            self.avatar.image = UIImage(data: data)
                        }
                    }
                } else {
                    self.avatar.image = UIImage(named: "Chef")
                }
            })
        }) { (error) in
            self.avatar.image = UIImage(named: "Chef")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OrderSegue" {
            let destination = segue.destination as! OrderViewController
            destination.recipe = self.recipe
        }
    }

}
