//
//  NewRecipeViewController.swift
//  Hungrily
//
//  Created by Akash Ungarala on 11/14/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class NewRecipeViewController: UIViewController {
    
    @IBOutlet weak var photo: UIImageView! {
        didSet {
            photo.layer.cornerRadius = 10
            photo.clipsToBounds = true
            photo.isUserInteractionEnabled = true
        }
    }
    @IBOutlet weak var recipeTitle: UITextField! {
        didSet {
            recipeTitle.layer.cornerRadius = 5
            recipeTitle.delegate = self
        }
    }
    @IBOutlet weak var cuisine: UITextField! {
        didSet {
            cuisine.layer.cornerRadius = 5
            cuisine.delegate = self
        }
    }
    @IBOutlet weak var category: UITextField! {
        didSet {
            category.layer.cornerRadius = 5
            category.delegate = self
        }
    }
    @IBOutlet weak var ingredients: UITextField! {
        didSet {
            ingredients.layer.cornerRadius = 5
            ingredients.delegate = self
        }
    }
    @IBOutlet weak var recipeDescription: UITextField! {
        didSet {
            recipeDescription.layer.cornerRadius = 5
            recipeDescription.delegate = self
        }
    }
    
    var chef: Chef!
    var dataBaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    var storageRef: FIRStorageReference! {
        return FIRStorage.storage().reference()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setGestureRecognizersToDismissKeyboard()
    }
    
    @IBAction func submit(_ sender: UIButton) {
        let title = recipeTitle.text!
        let recipeCuisine = cuisine.text!
        let recipeCategory = category.text!
        let recipeIngredients = ingredients.text!
        let description = recipeDescription.text!
        let pictureData = UIImageJPEGRepresentation(self.photo.image!, 0.70)
        if title.isEmpty {
            self.view.endEditing(true)
            showMessage(message: "Title is a mandatory field")
        } else if recipeCuisine.isEmpty {
            self.view.endEditing(true)
            showMessage(message: "Cuisine is a mandatory field")
        } else if recipeCategory.isEmpty {
            self.view.endEditing(true)
            showMessage(message: "Category is a mandatory field")
        } else if recipeIngredients.isEmpty {
            self.view.endEditing(true)
            showMessage(message: "Ingredients is a mandatory field")
        } else if description.isEmpty {
            self.view.endEditing(true)
            showMessage(message: "Description is a mandatory field")
        } else {
            self.view.endEditing(true)
            createRecipe(pictureData: pictureData as NSData!, title: title, cuisine: recipeCuisine, category: recipeCategory, ingredients: recipeIngredients, description: description)
        }
    }
    
    func createRecipe(pictureData: NSData!, title: String, cuisine: String, category: String, ingredients: String, description: String) {
        let id = self.dataBaseRef.child("recipes").childByAutoId().key
        let imageRef = storageRef.child("recipeImage\(id)/recipePic.jpg")
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpeg"
        imageRef.put(pictureData as Data, metadata: metaData) { (newMetaData, error) in
            var photoURL = ""
            if error == nil {
                if let url = newMetaData!.downloadURL()?.absoluteString {
                    photoURL = url
                }
            } else {
                
            }
            let recipeInfo = ["title": title, "cuisine": cuisine, "category": category, "ingredients": ingredients, "description": description, "uid": id, "photoURL": photoURL, "chefId": self.chef.uid]
            let recipeRef = self.dataBaseRef.child("recipes").child(id)
            recipeRef.setValue(recipeInfo) { (error, ref) in
                if error == nil {
                    let userRef = self.dataBaseRef.child("users").child(self.chef.uid).child("recipes").child(id)
                    userRef.setValue(id) { (error, ref) in
                        if error == nil {
                            self.performSegue(withIdentifier: "BackFromNewRecipeSegue", sender: nil)
                        }
                    }
                }
            }
        }
    }
    
    func showMessage(message: String) {
        let alertController = UIAlertController(title: "Oops", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {}

}

extension NewRecipeViewController: UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func setGestureRecognizersToDismissKeyboard() {
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.choosePictureAction(sender:)))
        imageTapGesture.numberOfTapsRequired = 1
        photo.addGestureRecognizer(imageTapGesture)
        // Creating Tap Gesture to dismiss Keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.dismissKeyboard(gesture:)))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        // Creating Swipe Gesture to dismiss Keyboard
        let swipDown = UISwipeGestureRecognizer(target: self, action: #selector(SignUpViewController.dismissKeyboard(gesture:)))
        swipDown.direction = .down
        view.addGestureRecognizer(swipDown)
    }
    
    func choosePictureAction(sender: AnyObject) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        let alertController = UIAlertController(title: "Add a Profile Picture", message: "Choose From", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            pickerController.sourceType = .camera
            self.present(pickerController, animated: true, completion: nil)
        }
        let photosLibraryAction = UIAlertAction(title: "Photos Library", style: .default) { (action) in
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        }
        let savedPhotosAction = UIAlertAction(title: "Saved Photos Album", style: .default) { (action) in
            pickerController.sourceType = .savedPhotosAlbum
            self.present(pickerController, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(cameraAction)
        alertController.addAction(photosLibraryAction)
        alertController.addAction(savedPhotosAction)
        alertController.addAction(cancelAction)
        self.present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage]  as? UIImage {
            self.photo.image = image
        } else if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.photo.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Dismissing the Keyboard with the Return Keyboard Button
    func dismissKeyboard(gesture: UIGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // Dismissing the Keyboard with the Return Keyboard Button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        recipeTitle.resignFirstResponder()
        cuisine.resignFirstResponder()
        category.resignFirstResponder()
        ingredients.resignFirstResponder()
        recipeDescription.resignFirstResponder()
        return true
    }
    
    // Moving the View down after the Keyboard appears
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateView(up: true, moveValue: 45)
    }
    
    // Moving the View down after the Keyboard disappears
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateView(up: false, moveValue: 45)
    }
    
    // Move the View Up & Down when the Keyboard appears
    func animateView(up: Bool, moveValue: CGFloat) {
        let movementDuration: TimeInterval = 0.3
        let movement: CGFloat = (up ? -moveValue : moveValue)
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
}
