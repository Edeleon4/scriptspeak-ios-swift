//
//  PhrasePopoverController.swift
//  IOS8SwiftPrototypeCellsTutorial
//
//  Created by uid on 11/23/14.
//  Copyright (c) 2014 Arthur Knopper. All rights reserved.
//

import AVFoundation
import UIKit
import Parse

class PhraseViewController: UIViewController {
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet var playButton: UIButton!
    @IBAction func editMode(sender: AnyObject) {
        var button = sender as UIButton;
        if(editButton.titleLabel?.text == "Edit"){
            editTextField.hidden = false;
            myLabel.hidden = true;
            editTextField.text = myLabel.text;
            editButton.titleLabel?.text = "Save";
            editButton.setTitle("Save", forState: UIControlState.Normal);
        }else if (editButton.titleLabel?.text == "Save"){
            editTextField.hidden = true;
            myLabel.hidden = false;
            myLabel.text = editTextField.text;
            editButton.setTitle("Edit", forState: UIControlState.Normal);
            dictation.setValue(editTextField.text, forKey: "text");
            dictation.saveEventually();
        }
    }
    @IBOutlet var dismissButton: UIButton!
    @IBOutlet var myLabel: UILabel!
    var phraseText: String!
    var dictation :PFObject!
    var synthesizer: AVSpeechSynthesizer!
    
    @IBOutlet weak var editTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad();
        synthesizer = AVSpeechSynthesizer();
        myLabel.text = dictation.objectForKey("text") as? String;
//        dictation.setValue(myLabel.text, forKey: "text");
//        dictation.saveEventually();
        var tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        self.view.addGestureRecognizer(tap)
        
    }

    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playText(sender: AnyObject) {
        println("SYNTH")
        println(synthesizer)
        if(synthesizer.paused){
            synthesizer.continueSpeaking();
        } else {
            playText();
        }
    }
    
    func playText() {
        println("TREXT")
       
//        let text = dictation.objectForKey("text") as String;
//        println(text)
        var mySpeechUtterance = AVSpeechUtterance(string:myLabel.text);
        mySpeechUtterance.rate = AVSpeechUtteranceMinimumSpeechRate;
        synthesizer.speakUtterance(mySpeechUtterance);
    }
    
    @IBAction func dismissModal(sender: AnyObject) {
        println("dismiiss modal")
        synthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate);
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func stopText(sender: AnyObject) {
        synthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate);
    }
    
    @IBAction func pauseText(sender: AnyObject) {
        synthesizer.pauseSpeakingAtBoundary(AVSpeechBoundary.Immediate);
    }
    
}
