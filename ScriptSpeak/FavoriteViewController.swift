import AVFoundation
import UIKit
import Parse

class FavoriteViewController: UITableViewController {
    
    @IBOutlet weak var favoriteItem: UITabBarItem!
    @IBOutlet weak var footerView: UIView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var textToPlayField: UITextField!
    @IBOutlet var tapDictationItem: UITapGestureRecognizer! //MOVED THIS UP
    var synthesizer:AVSpeechSynthesizer = AVSpeechSynthesizer();


   // var favoritePhrases:[String] = [];
    var favoritePhrasesParse :[PFObject] = [];

    
    /*
        Creates segue to Phrase Popover Controller with given phrase as data
        @param sender  either the text input play button or any of the table view cells containing a phrase
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        //segues from a table view cell phrase to the phrase view page
        if segue.identifier == "phraseModal2" {
            var cell: UITableViewCell = sender as UITableViewCell;
            let vc = segue.destinationViewController as PhraseViewController;
            
            var cellLabel:UILabel = cell.viewWithTag(50) as UILabel;
            var buttonPosition:CGPoint = sender.convertPoint(CGPointZero, toView: self.tableView);
            var row = self.tableView.indexPathForRowAtPoint(buttonPosition)?.row;
            vc.dictation = favoritePhrasesParse[row!];
        }
        //segues from the text input play button to the phrase view
        else if segue.identifier == "inputToPhrase2" {
            let vc = segue.destinationViewController as PhraseViewController;
            println("VCPHRASETEXT")
            vc.dictation = sender as PFObject;
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        //Grab the data from local storage upon loading the view
        var query = PFQuery(className:"Dictation")
        query.fromLocalDatastore();
        query.whereKey("favorite", equalTo:true)
        query.orderByDescending("createdAt");
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                NSLog("Successfully retrieved \(objects.count) dictations.")
                // Do something with the found objects
                self.favoritePhrasesParse = objects as [PFObject];
                println(self.favoritePhrasesParse);
                self.tableView.reloadData();
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo!)
            }
        }
        
    }
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    //loads favorites page
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColorFromRGB(0x191970);
        //self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Oxygen", size: 30)!, NSForegroundColorAttributeName: UIColor.whiteColor()];
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor();
        //self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Pontano Sans", size: 18)!], forState: UIControlState.Normal);
        
        tableView.frame = self.view.frame;
        
        
        
        // Keyboard handler code.
        var center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /*
        Plays input text and stores input text into history phrases list
        @param sender  input text play button
    */
    @IBAction func playText(sender: UIButton) {
        let text = textToPlayField.text;
        if(text != ""){
            var dictationParse = PFObject(className:"Dictation")
            dictationParse["createdBy"] =  PFUser.currentUser();
            dictationParse["text"] = text;
            dictationParse["usageCount"] = 1;
            dictationParse["history"] = true;
            dictationParse["favorite"] = false;
            dictationParse.pinInBackgroundWithBlock(nil);
            dictationParse.saveEventually();
            favoritePhrasesParse.insert(dictationParse, atIndex: 0);
            play(text)
            performSegueWithIdentifier("inputToPhrase2", sender: dictationParse)
            textToPlayField.text = "";
        }
    }
    
    func play(text:String){
        var mySpeechUtterance = AVSpeechUtterance(string:text);
        mySpeechUtterance.rate = AVSpeechUtteranceMinimumSpeechRate;
        synthesizer.speakUtterance(mySpeechUtterance);
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        PFObject.unpinAllObjects();
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritePhrasesParse.count;
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return footerView.frame.size.height;
    }
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footerView;
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let dictationParse = favoritePhrasesParse[indexPath.row];
        let text = dictationParse.objectForKey("text") as String;
        dictationParse.incrementKey("usageCount");
        dictationParse.saveEventually();
        play(text);
        
        tableView.reloadData();
    }


    
    //creates labels and buttons for each table view cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        println("cellForrowAtIndexPath");
        let cell = tableView.dequeueReusableCellWithIdentifier("dictationCell") as UITableViewCell;
        var cellLabel:UILabel = cell.viewWithTag(50) as UILabel;
//        println(favoritePhrasesParse);

        var dictationParse = favoritePhrasesParse[indexPath.row]

        println(dictationParse);
        cellLabel.text = dictationParse.objectForKey("text") as? String;
     
        var deleteButton:UIButton? = cell.contentView.viewWithTag(51) as? UIButton;
        deleteButton?.addTarget(self, action: "deleteItemClicked:", forControlEvents: UIControlEvents.TouchDown);
        
        var addTextButton:UIButton? = cell.contentView.viewWithTag(54) as? UIButton;
        addTextButton?.addTarget(self, action: "addTextClicked:", forControlEvents: UIControlEvents.TouchDown);
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
            var dication = favoritePhrasesParse[currentIndex!];
            performSegueWithIdentifier("phraseModal2", sender: tableView.cellForRowAtIndexPath(indexPath!));
        }
    
    }


    //FOR ADDING TEXT TO THE INPUT TEXT PART (for the base phrase stuff)
    func addTextClicked(sender:AnyObject) {
        var buttonPosition:CGPoint = sender.convertPoint(CGPointZero, toView: self.tableView);
        var indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition);
        
        if(indexPath != nil){
            var cell = self.tableView.cellForRowAtIndexPath(indexPath!);
            var currentIndex = indexPath?.row;
            var dictation = favoritePhrasesParse[currentIndex!];
            dictation.incrementKey("usageCount");
            dictation.saveEventually();
            var text = dictation.objectForKey("text") as String;
            textToPlayField.text = textToPlayField.text+" "+text + " ";
            if(textToPlayField.canBecomeFirstResponder()){
                textToPlayField.becomeFirstResponder();
            } else {
                println("cannot become first responder");
            }
        } else {
            println("error");
        }
    }
    
    /////////////////////////////////////////
    //// DELETE ITEM IN FAVORITES LIST ///////
    /////////////////////////////////////////
    //alert dialog
    func deleteItemClicked(sender: AnyObject){
        let alertController = UIAlertController(title: "Delete Phrase?",message:"This phrase will be removed from your favorites list.",preferredStyle: UIAlertControllerStyle.Alert)
        
        //for iphones
//        let alertController = UIAlertController(title: "",message:"This phrase will be removed from your favorites list.",preferredStyle: UIAlertControllerStyle.ActionSheet)
    
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
    
    //deletes item from list
    func deleteItem(sender: AnyObject){
        var buttonPosition:CGPoint = sender.convertPoint(CGPointZero, toView: self.tableView);
        var indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition);
        if (indexPath != nil)
        {
            var currentIndex = indexPath?.row;
            var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var dictationParse = favoritePhrasesParse[currentIndex!]
            favoritePhrasesParse.removeAtIndex(currentIndex!);
            dictationParse.setObject(false, forKey: "favorite");
            dictationParse.saveEventually();
            tableView.reloadData()
        }
    }
    

    //code for the favorite button on the text field
    @IBAction func favoriteTextInput(sender: UIButton) {
        sender.setImage(UIImage(named:"star-filled.png"), forState:UIControlState.Highlighted);
        let text = textToPlayField.text;
        
        if (text != "") {
            var dictationParse = PFObject(className:"Dictation")
            dictationParse["text"] = text;
            dictationParse["usageCount"] = 1;
            dictationParse["history"] = false;
            dictationParse["favorite"] = true;
            dictationParse.saveEventually();
            textToPlayField.text = "";
            tableView.reloadData();
        }
    }
    
    @IBAction func logoutButtonClicked(sender: AnyObject) {
        let alertController = UIAlertController(title: "Logout?",message:"You will be logged out of your account.",preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "Logout", style: UIAlertActionStyle.Default, handler: { (action : UIAlertAction!) in
            PFUser.logOut();
            // Hooray! Let them use the app now.
            self.performSegueWithIdentifier( "openLoginSignup",
                sender: nil
            );
        });
            
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil);
        
        // Add the actions
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        // Present the controller
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info:NSDictionary = notification.userInfo!
        var keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as NSValue).CGRectValue()
        
        var keyboardHeight:CGFloat = keyboardSize.height
        
        var animationDuration:CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as CGFloat
        println(self.tableView.frame.minY)
        println(self.tableView.frame.maxY)
        println(self.tableView.frame.height)
        println(self.tableView.frame)
        println(self.tableView.frame.maxY - keyboardHeight)
        
        if (self.footerView.frame.origin.y > self.tableView.frame.maxY - keyboardHeight) {
            println("hi")
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
        
        if (self.footerView.frame.origin.y >= self.tableView.frame.maxY - keyboardHeight) {
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