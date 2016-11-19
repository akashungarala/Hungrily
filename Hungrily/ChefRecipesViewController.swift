//
//  ChefRecipesViewController.swift
//  Hungrily
//
//  Created by Akash Ungarala on 11/14/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class ChefRecipesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var chef: Chef!
    var recipes: [Recipe]!
    var dataBaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    var storageRef: FIRStorage {
        return FIRStorage.storage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchRecipes()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let recipes = recipes {
            return recipes.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! RecipeCell
        cell.configureCell(recipe: recipes[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    @IBAction func backToChefRecipes(storyboard: UIStoryboardSegue) {}
    
    func fetchRecipes() {
        dataBaseRef.child("users").child(chef.uid).child("recipes").observe(.value, with: { (snapshot) in
            var results = [Recipe]()
            for recipeId in snapshot.children {
                let recipeObj = recipeId as! FIRDataSnapshot
                let id = "\(recipeObj.key)"
                self.dataBaseRef.child("recipes").child(id).observe(.value, with: { (recipeSnapshot) in
                    results.append(Recipe(snapshot: recipeSnapshot))
                    self.recipes = results.sorted(by: { (u1, u2) -> Bool in
                        u1.title < u2.title
                    })
                    self.tableView.reloadData()
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FoodieChefRecipeDetailSegue" {
            let destination = segue.destination as! RecipeDetailViewController
            destination.sender = "FoodieChef"
            destination.recipe = recipes![(self.tableView.indexPathForSelectedRow?.row)!]
        }
    }

}
