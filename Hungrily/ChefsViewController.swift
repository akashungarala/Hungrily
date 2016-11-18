//
//  ChefsViewController.swift
//  Hungrily
//
//  Created by Akash Ungarala on 11/14/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ChefsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var foodie: Foodie!
    var chefs: [Chef]!
    var dataBaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
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
        fetchChefs()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let chefs = chefs {
            return chefs.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChefCell", for: indexPath) as! ChefCell
        cell.configureCell(user: chefs[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    @IBAction func backToChefs(storyboard: UIStoryboardSegue) {}
    
    func fetchChefs() {
        dataBaseRef.child("users").observe(.value, with: { (snapshot) in
            var results = [Chef]()
            for user in snapshot.children {
                let userObj = user as! FIRDataSnapshot
                let category = (userObj.value! as! NSDictionary)["category"] as! String
                if category == "Chef" {
                    let chef = Chef(snapshot: userObj)
                    results.append(chef)
                }
            }
            self.chefs = results.sorted(by: { (u1, u2) -> Bool in
                u1.firstName < u2.firstName
            })
            self.tableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChefDetailSegue" {
            let destination = segue.destination as! ChefDetailViewController
            destination.chef = chefs![(self.tableView.indexPathForSelectedRow?.row)!]
        }
    }

}
