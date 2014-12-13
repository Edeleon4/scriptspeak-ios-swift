//
//  ViewController.swift
//  IOS8SwiftPrototypeCellsTutorial
//
//  Created by Arthur Knopper on 10/08/14.
//  Copyright (c) 2014 Arthur Knopper. All rights reserved.
//
import AVFoundation
import UIKit
import Parse

class HistoryViewController: UITableViewController {
    
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    var synthesizer:AVSpeechSynthesizer = AVSpeechSynthesizer();

    var historyPhrasesParse :[PFObject] = [];
    @IBOutlet weak var textToPlayField: UITextField!
    @IBOutlet var tapDictationItem: UITapGestureRecognizer!
    
    /*
    Creates segue to Phrase Popover Controller with given phrase as data
    @param sender  either the text input play button or any of the table view cells containing a phrase
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        //segues from a table view cell phrase to the phrase view page
        if segue.identifier == "phraseModal"{
            var cell: UITableViewCell = sender as UITableViewCell;
            let vc = segue.destinationViewController as PhraseViewController;
            
            var buttonPosition:CGPoint = sender.convertPoint(CGPointZero, toView: self.tableView);
            var row = self.tableView.indexPathForRowAtPoint(buttonPosition)?.row;
//            vc.phraseText = historyPhrasesParse[row!].objectForKey("text") as String;
            vc.dictation = historyPhrasesParse[row!];
        }
        //segues from the text input play button to the phrase view
        else if segue.identifier == "inputToPhrase" {
            let text = textToPlayField.text
            let vc = segue.destinationViewController as PhraseViewController
            vc.dictation = sender as PFObject
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        var query = PFQuery(className:"Dictation")
        query.fromLocalDatastore();
        query.whereKey("history", equalTo:true)
        query.whereKey("createdBy", equalTo:PFUser.currentUser());
        query.orderByDescending("createdAt");
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                NSLog("Successfully retrieved \(objects.count) dictations.")
                // Do something with the found objects
                self.historyPhrasesParse = objects as [PFObject];
                self.saveDictationsLocally();
                
                println(self.historyPhrasesParse);
                self.tableView.reloadData();
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo!)
            }
        }

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        tableView.frame = self.view.frame;
//        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.Interactive;
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults();
        
        
        // clear all history button
        var clearButton : UIBarButtonItem = UIBarButtonItem(title: "Clear All", style: UIBarButtonItemStyle.Plain, target: self, action: "clearAllClicked:");
        self.navigationItem.rightBarButtonItem = clearButton;
      //  self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Pontano Sans", size: 18)!], forState: UIControlState.Normal);
       // self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Pontano Sans", size: 18)!], forState: UIControlState.Normal);
        
        // Keyboard stuff.
        var center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
    }
    func saveDictationsLocally(){
        
    }
    
    // play text from UITextField
    @IBAction func playText(sender: AnyObject) {
        let text = textToPlayField.text;
        if(text != ""){
            var dictationParse = PFObject(className:"Dictation")
            dictationParse["createdBy"] = PFUser.currentUser();
            dictationParse["text"] = text;
            dictationParse["usageCount"] = 1;
            dictationParse["history"] = true;
            dictationParse["favorite"] = false;
            dictationParse.pinInBackgroundWithBlock(nil);
            dictationParse.saveEventually();
            historyPhrasesParse.insert(dictationParse, atIndex: 0);
            saveDictationsLocally();
            play(text)
            performSegueWithIdentifier("inputToPhrase", sender: dictationParse)
            textToPlayField.text = "";
        }
    }


//
//    /*
//    Finds history phrases from a given list of dictation storage strings
//    Returns a list of history phrase dictation storage strings
//    */
//    func getHistoryPhrases(dictationsArray: [String]) -> [String] {
//        var historyPhrasesList:[String] = [];
//        for ele in dictationsArray {
//            var dictation = DictationModel(storageString: ele);
//            if (dictation.getHistory()) {
//                historyPhrasesList.append(ele);
//            }
//        }
//        return historyPhrasesList;
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyPhrasesParse.count;
    }
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return footerView.frame.size.height;
    }
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footerView;
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let dictationParse = historyPhrasesParse[indexPath.row];
        let text = dictationParse.objectForKey("text") as String;
        dictationParse.incrementKey("usageCount");
        dictationParse.saveEventually();
        saveDictationsLocally();
        play(text);
       
        tableView.reloadData();

    }
    func play(text:String){
        var mySpeechUtterance = AVSpeechUtterance(string:text);
        mySpeechUtterance.rate = AVSpeechUtteranceMinimumSpeechRate;
        synthesizer.speakUtterance(mySpeechUtterance);
    }
    

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("dictationCell") as UITableViewCell;
        var cellLabel:UILabel = cell.viewWithTag(50) as UILabel;
        
        var dictation = historyPhrasesParse[indexPath.row];
        cellLabel.text = dictation.objectForKey("text") as? String;
        
        var deleteButton:UIButton? = cell.contentView.viewWithTag(51) as? UIButton;
        deleteButton?.addTarget(self, action: "deleteItemClicked:", forControlEvents: UIControlEvents.TouchDown);
        
        var favButton:UIButton? = cell.contentView.viewWithTag(52) as? UIButton;
        favButton?.addTarget(self, action: "favItem:", forControlEvents: UIControlEvents.TouchDown);
        
        if(dictation.objectForKey("favorite") as Bool){
            favButton?.setImage(UIImage(named:"star-filled-blue2.png"), forState: UIControlState.Normal);
        } else {
            favButton?.setImage(UIImage(named:"star-empty-blue2.png"), forState: UIControlState.Normal);
        }
        var lpgr = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        lpgr.minimumPressDuration = 1.0; //seconds
        cell.addGestureRecognizer(lpgr);
        
        return cell;
    }
    //press to see complete text--TODO NOT LONG ENOUGH
    func handleLongPress(sender:UILongPressGestureRecognizer){
        
        var buttonPosition:CGPoint = sender.locationInView(self.tableView);

        var indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition);
        if (indexPath != nil)
        {
            var currentIndex = indexPath?.row;
            var dication = historyPhrasesParse[currentIndex!];
            performSegueWithIdentifier("phraseModal", sender: tableView.cellForRowAtIndexPath(indexPath!));

        }
    
    }
    
    /////////////////////////////////////////
    //// DELETE ITEM IN HISTORY LIST ///////
    /////////////////////////////////////////
    func deleteItemClicked(sender: AnyObject){ //UIBarBUttonItem
        let alertController = UIAlertController(title: "",message:"This phrase will be removed from your history list.",preferredStyle: UIAlertControllerStyle.Alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: { (action : UIAlertAction!) in
            self.deleteItem(sender);
        });// DeleteEntered);
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil);
        
        // Add the actions
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        // Present the controller
        presentViewController(alertController, animated: true, completion: nil)
    }

    func deleteItem(sender: AnyObject){
        var buttonPosition:CGPoint = sender.convertPoint(CGPointZero, toView: self.tableView);
        var indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition);
        if (indexPath != nil) {
            var currentIndex = indexPath?.row;
            var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var historySelected = historyPhrasesParse[currentIndex!];
            historyPhrasesParse.removeAtIndex(currentIndex!);
            historySelected.setObject(false, forKey: "history");
            historySelected.saveEventually();
            saveDictationsLocally();
            tableView.reloadData()
        }
    }
    
 
    
    //saves the text to favorites and clears it from the text field
    @IBAction func favoriteTextInput(sender: AnyObject) {
        sender.setImage(UIImage(named:"star-filled-blue2.png"), forState:UIControlState.Normal); //should change image of star to filled star when pressed
        let text = textToPlayField.text
        if(text != ""){
            var dictationParse = PFObject(className:"Dictation")
            dictationParse["createdBy"] =  PFUser.currentUser();

            dictationParse["text"] = text;
            dictationParse["usageCount"] = 1;
            dictationParse["history"] = false;
            dictationParse["favorite"] = true;
            dictationParse.saveEventually();
            saveDictationsLocally();
            textToPlayField.text = "";
            tableView.reloadData();
        }
    }
    

    func favItem(sender: AnyObject){
        sender.setImage(UIImage(named:"star-filled-blue2.png"), forState:UIControlState.Normal); //should change image of star to filled star when pressed
        var buttonPosition:CGPoint = sender.convertPoint(CGPointZero, toView: self.tableView);
        var indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition);
        if (indexPath != nil)
        {
            var currentIndex = indexPath?.row;
            var dictation = historyPhrasesParse[currentIndex!];
            dictation.setObject(true, forKey: "favorite");
            dictation.saveEventually();
            saveDictationsLocally();
        }
        tableView.reloadData();
    }
    
    
    ///////////////////////////////////////////////////
    ////////* CLEAR ALL PHRASES FUNCTIONALITY *////////
    ///////////////////////////////////////////////////
    
    // send alert for clear all
    func clearAllClicked(sender: AnyObject){
        let alertController = UIAlertController(title: "",message:"All phrases will be removed from your history.",preferredStyle: UIAlertControllerStyle.Alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "Clear All", style: UIAlertActionStyle.Destructive, handler: { (action : UIAlertAction!) in
            self.clearAll(sender);
        });
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil);
        
        // Add the actions
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        // Present the controller
        presentViewController(alertController, animated: true, completion: nil)
        self.tableView.reloadData();
        
    }
    
    // clear all phrases from the history list
    func clearAll(sender:AnyObject){
        for  dictation in historyPhrasesParse{
            dictation.setObject(false, forKey: "history");
            dictation.saveEventually();
        }
        self.historyPhrasesParse =  [];
        self.tableView.reloadData();
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info:NSDictionary = notification.userInfo!
        var keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as NSValue).CGRectValue()
        
        var keyboardHeight:CGFloat = keyboardSize.height
        
        var animationDuration:CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as CGFloat
        
        if (self.footerView.frame.origin.y > self.tableView.frame.maxY - keyboardHeight) {
            UIView.animateWithDuration(0, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.tableView.frame = CGRectMake(0, (self.tableView.frame.origin.y - keyboardHeight), self.view.bounds.width, self.view.bounds.height)
                }, completion: nil)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        var info:NSDictionary = notification.userInfo!
        var keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as NSValue).CGRectValue()
        
        var keyboardHeight:CGFloat = keyboardSize.height
        
        var animationDuration:CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as CGFloat
        
        if (self.footerView.frame.origin.y > self.tableView.frame.maxY - keyboardHeight) {
            UIView.animateWithDuration(0.25, delay: 0.25, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.tableView.frame = CGRectMake(0, (self.tableView.frame.origin.y + keyboardHeight), self.view.bounds.width, self.view.bounds.height)
                }, completion: nil)
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

}
