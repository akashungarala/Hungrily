//
//  HomeViewController.swift
//  Hungrily
//
//  Created by Akash Ungarala on 11/8/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            emailTextField.delegate = self
            emailTextField.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.delegate = self
            passwordTextField.layer.cornerRadius = 5
        }
    }
    
    var authService = AuthService()
    var errorMessage: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGestureRecognizersToDismissKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if errorMessage != nil {
            showMessage(message: errorMessage!)
        }
    }
    
    @IBAction func resetPasswordAction(sender: UIButton) {
        self.view.endEditing(true)
        resetPassword()
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let email = emailTextField.text!.lowercased()
        let finalEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!
        if finalEmail.isEmpty {
            showMessage(message: "Email Address is a mandatory field")
        } else if finalEmail.characters.count < 8 {
            showMessage(message: "Email Address should be atleast 8 characters")
        } else if password.isEmpty {
            showMessage(message: "Password is a mandatory field")
        } else if password.characters.count < 6 {
            showMessage(message: "Password should be atleast 6 characters")
        } else {
            authService.logIn(email: finalEmail, password: password)
        }
    }
    
    func showMessage(message: String) {
        let alertController = UIAlertController(title: "Oops", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {}

}

extension HomeViewController: UITextFieldDelegate  {
    
    @IBAction func backToHome(storyboard: UIStoryboardSegue) {}
    
    // Dismissing the Keyboard with the Return Keyboard Button
    func dismissKeyboard(gesture: UIGestureRecognizer){
        self.view.endEditing(true)
    }
    
    // Dismissing the Keyboard with the Return Keyboard Button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
    
    // Moving the View down after the Keyboard appears
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateView(up: true, moveValue: 80)
    }
    
    // Moving the View down after the Keyboard disappears
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateView(up: false, moveValue: 80)
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
    
    func setGestureRecognizersToDismissKeyboard() {
        // Creating Tap Gesture to dismiss Keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.dismissKeyboard(gesture:)))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        // Creating Swipe Gesture to dismiss Keyboard
        let swipDown = UISwipeGestureRecognizer(target: self, action: #selector(HomeViewController.dismissKeyboard(gesture:)))
        swipDown.direction = .down
        view.addGestureRecognizer(swipDown)
    }
    
}
