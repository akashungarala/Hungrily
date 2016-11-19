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

class FoodieHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var avatar: UIImageView! {
        didSet {
            avatar.layer.cornerRadius = 10
            avatar.clipsToBounds = true
        }
    }
    
    var foodie: Foodie!
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
        loadUserInfo()
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
    
    @IBAction func backToFoodieHome(storyboard: UIStoryboardSegue) {}
    
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
    
    func fetchRecipes() {
        dataBaseRef.child("recipes").observe(.value, with: { (snapshot) in
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
        if segue.identifier == "ChefsSegue" {
            let destination = segue.destination as! ChefsViewController
            destination.foodie = self.foodie
        } else if segue.identifier == "FoodieRecipeDetailSegue" {
            let destination = segue.destination as! RecipeDetailViewController
            destination.sender = "Foodie"
            destination.recipe = recipes![(self.tableView.indexPathForSelectedRow?.row)!]
        }
    }
    
}
