//
//  LoginViewController.swift
//  ScriptSpeak
//
//  Created by uid on 12/8/14.
//  Copyright (c) 2014 uid. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import Parse

class LoginViewController: UIViewController {
    @IBOutlet weak var usernametextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var supplementText: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBAction func usertextFieldTouchDown(sender: AnyObject) {
        self.supplementText.text = ""
    }
    
    @IBAction func passwordtextFieldTouchDown(sender: AnyObject) {
        self.supplementText.text = ""
    }
    
    @IBAction func signupButtonTouchDown(sender: AnyObject) {
        self.performSegueWithIdentifier( "loginToSignup", sender: nil);
    }
   
    @IBAction func loginButtonTouchDown(sender: AnyObject) {
        if(usernametextField.text != "" && passwordTextField.text != ""){
            login(usernametextField.text, password: passwordTextField.text);
        }
    }
  
    //loads favorites page
    override func viewDidLoad() {
        super.viewDidLoad();
        loginButton.layer.cornerRadius = 7;
        var tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
        var user = PFUser.currentUser();
        if(user != nil){
            // Do stuff after successful login
            self.performSegueWithIdentifier( "openMainController",
                sender: user);
        }
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
    
    func login(userName:String,password:String){
        println("lgoing")
        PFUser.logInWithUsernameInBackground(userName, password:password) {
            (user: PFUser!, error: NSError!) -> Void in
            println("user")
            println(user)
            if user != nil {
                var query = PFQuery(className:"Dictation")
                
                query.whereKey("createdBy", equalTo:user);
                query.findObjectsInBackgroundWithBlock {
                    (objects: [AnyObject]!, error: NSError!) -> Void in
                    if error == nil {
                        // The find succeeded.
                        NSLog("Successfully retrieved \(objects.count) dictations.")
                        PFObject.pinAllInBackground(objects, block: nil);
                
                    } else {
                        // Log details of the failure
                        NSLog("Error: %@ %@", error, error.userInfo!)
                    }
                }
                    
                // Do stuff after successful login
                self.performSegueWithIdentifier( "openMainController",
                    sender: user);
                
            } else {
                // The login failed. Check error to see why.
                self.supplementText.text = "Invalid login/password combination."
                self.usernametextField.text = ""
                self.passwordTextField.text = ""
                self.dismissKeyboard()
                
            }
        }
    }
    
}