//
//  SignupViewController.swift
//  ScriptSpeak
//
//  Created by uid on 12/8/14.
//  Copyright (c) 2014 uid. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import Parse

class SignupViewController: UIViewController {
    @IBOutlet weak var usernametextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var supplementText: UILabel!
    @IBOutlet weak var loginWithDiffAccount: UIButton!
    
    @IBAction func usertextFieldTouchDown(sender: AnyObject) {
        self.supplementText.text = ""
    }
    
    @IBAction func passwordtextFieldTouchDown(sender: AnyObject) {
        self.supplementText.text = ""
    }
    
    @IBAction func signupButtonTouchDown(sender: AnyObject) {
        if(usernametextField.text != "" && passwordTextField.text != "" && passwordConfirmTextField.text != ""){
            if(passwordTextField.text == passwordConfirmTextField.text) {
                signUp(usernametextField.text, password: passwordTextField.text);
            }
            else {
                self.supplementText.text = "Passwords don't match. Please try again."
                self.passwordTextField.text = ""
                self.passwordConfirmTextField.text = ""
                self.dismissKeyboard()
            }
        }
    }
   
    @IBAction func loginButtonTouchDown(sender: AnyObject) {
        performSegueWithIdentifier("signupToLogin", sender: nil)
    }
    
    //loads favorites page
    override func viewDidLoad() {
        super.viewDidLoad();
        signUpButton.layer.cornerRadius = 7;
        var tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
        
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func signUp(userName:String,password:String) {
        var user = PFUser()
        user.username = userName
        user.password = password
        
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool!, error: NSError!) -> Void in
            if error == nil {
                               // Hooray! Let them use the app now.
                self.performSegueWithIdentifier( "signupToMainController",
                    sender: user);
            } else {
                let errorString = error.userInfo;
                self.supplementText.text = "Username unavailable. Please try again."
                self.usernametextField.text = ""
                self.passwordTextField.text = ""
                self.passwordConfirmTextField.text = ""
                self.dismissKeyboard()
                // Show the errorString somewhere and let the user try again.
            }
        }
    }
}