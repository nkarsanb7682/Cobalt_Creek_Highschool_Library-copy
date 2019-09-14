//
//  PreviewStorePageViewController.swift
//  Cobalt_Creek_Highschool_Library
//
//  Created by Grant Falkner on 8/28/17.
//  Copyright © 2017 Grant Falkner. All rights reserved.
//

import UIKit
import Firebase

func starRating(rating: String, starNumber: Double)-> UIImage{ //4.3
    let ratingAsDouble: Double = Double(rating)!
    if ratingAsDouble < starNumber + 0.125 {
        //empty star
        return #imageLiteral(resourceName: "Empty Star.png")
    }
    else if ratingAsDouble < starNumber + 0.375{
        //quarter star
        return #imageLiteral(resourceName: "Quarter Star.png")
    }
    else if ratingAsDouble < starNumber + 0.625{
        //half star
        return #imageLiteral(resourceName: "Half Star.png")
    }
    else if ratingAsDouble < starNumber + 0.875{
        //three quarter star
        return #imageLiteral(resourceName: "Three Fourths Star.png")
    }
    else{
        //full star
        return #imageLiteral(resourceName: "Full Star.png")
    }
    
}

class StorePageViewController: UIViewController {
    var bookTitleFIR: String? = ""
    var bookAuthorFIR: String? = ""
    var bookDescriptonFIR: String? = ""
    var bookImageURLFIR: String? = ""
    var bookRatingFIR: String? = ""
    var bookPageCountFIR: String? = ""
    var bookYearFIR: String? = ""
    var bookPublisherFIR: String? = ""
    var bookGenreFIR: String? = ""
    var bookCopiesFIR: String? = ""
    
    var child = "pendingPosts"
    
    var strings:[String] = []
    

    @IBOutlet weak var addToBagButtonOutlet: UIButton!
    @IBOutlet weak var contentViewOutlet: UIView!
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var bookDescriptionTextView: UITextView!
    @IBOutlet weak var bookTitleTextView: UITextView!
    @IBOutlet weak var bookRatingTextView: UITextView!
    @IBOutlet weak var scrollViewOutlet: UIScrollView!
    @IBOutlet weak var copiesTextView: UITextView!
    @IBOutlet weak var postButtonOutlet: UIButton!
    @IBOutlet weak var cancelButtonOutlet: UIButton!
    @IBOutlet weak var previewLabelOutlet: UILabel!
    
    @IBOutlet weak var starOneImage: UIImageView!
    @IBOutlet weak var starTwoImage: UIImageView!
    @IBOutlet weak var starThreeImage: UIImageView!
    @IBOutlet weak var starFourImage: UIImageView!
    @IBOutlet weak var starFiveImage: UIImageView!
    
    
    @IBAction func cancelButton(_ sender: Any) {
        Database.database().reference().child("pendingPosts").child(globalVariables.isbn).removeValue()
    }
    @IBAction func addToBagButton(_ sender: Any) {
        if (copiesTextView.text != "copies avalible: 0"){
            if Auth.auth().currentUser != nil {
                let currentUser = Auth.auth().currentUser
                Database.database().reference().child("verifiedPosts").child(globalVariables.isbn).child((currentUser?.uid)!).setValue("In Book Bag")
                
                self.performSegue(withIdentifier: "StorePageToBookBrowsingTable", sender: nil)
            }
            else {
                // User is not signed in.
                self.performSegue(withIdentifier: "StorePageToSignIn", sender: nil)
            }
        }
        else{
            let alert = UIAlertController(title: "No Copies Available", message: "all copies are checked out... please wait for one to be returned", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

    }
    
    @IBAction func postButton(_ sender: Any) {

        let imageRef = Storage.storage().reference().child("\(globalVariables.isbn).jpg")
            let data = UIImageJPEGRepresentation(self.bookImage.image!, 1)
            let upload = imageRef.putData(data!, metadata: nil, completion: { (metadata, error) in
                if (error != nil)
                    
                {
                    print(error!.localizedDescription)
                }
                imageRef.downloadURL(completion: { (url, error2) in
                    if (error2 != nil)
                    {
                        print(error!.localizedDescription)
                    }
                    if let url = url {
                        
                        let postInfo : [String : Any] = ["title" : self.bookTitleTextView.text,
                                                         "rating": self.bookRatingTextView.text.replacingOccurrences(of: "/5", with: ""),
                                                         "description" : self.bookDescriptionTextView.text,
                                                         "image" : url.absoluteString,
                                                         "genre" : self.bookGenreFIR!,
                                                         "copies" : self.bookCopiesFIR!,
                                                         "isbn" : globalVariables.isbn]
                        Database.database().reference().child("verifiedPosts").child(globalVariables.isbn).setValue(postInfo)
                        Database.database().reference().child("pendingPosts").child(globalVariables.isbn).removeValue()
                    }
                    
                })
                
            })
            upload.resume()
        globalVariables.isPreview = false
        self.performSegue(withIdentifier: "PreviewStorePageToBookInput", sender: nil)
    }
    
    
    
    

    override func viewDidLoad() {
        
        self.addDoneButtonOnKeyboard()
        self.view.backgroundColor = UIColorFromHex(rgbValue: 0x303131, alpha: 1)
            //hide preview controll elements
        if (globalVariables.isPreview == false){
            self.bookDescriptionTextView.isEditable = false
            self.cancelButtonOutlet.isHidden = true
            self.postButtonOutlet.isHidden = true
            self.previewLabelOutlet.isHidden = true
            self.child = "verifiedPosts"
        }
        else{
            self.addToBagButtonOutlet.isEnabled = false
        }
        Database.database().reference().child(child).child(globalVariables.isbn).observeSingleEvent(of: .value, with: {snapshot in
            print(snapshot)
            var snapshotValue = snapshot.value as? NSDictionary
            self.bookAuthorFIR = snapshotValue!["author"] as? String
            snapshotValue = snapshot.value as? NSDictionary
            self.bookDescriptonFIR = snapshotValue!["description"] as? String
            snapshotValue = snapshot.value as? NSDictionary
            self.bookImageURLFIR = snapshotValue!["image"] as? String
            snapshotValue = snapshot.value as? NSDictionary
            self.bookPageCountFIR = snapshotValue!["pageCount"] as? String
            snapshotValue = snapshot.value as? NSDictionary
            self.bookRatingFIR = snapshotValue!["rating"] as? String
            snapshotValue = snapshot.value as? NSDictionary
            self.bookTitleFIR = snapshotValue!["title"] as? String
            snapshotValue = snapshot.value as? NSDictionary
            self.bookPublisherFIR = snapshotValue!["publisher"] as? String
            snapshotValue = snapshot.value as? NSDictionary
            self.bookYearFIR = snapshotValue!["year"] as? String
            snapshotValue = snapshot.value as? NSDictionary
            self.bookGenreFIR = snapshotValue!["genre"] as? String
            snapshotValue = snapshot.value as? NSDictionary
            self.bookCopiesFIR = snapshotValue!["copies"] as? String
            snapshotValue = snapshot.value as? NSDictionary
            
            if (globalVariables.isPreview == true){
            let bullet1 = self.bookPageCountFIR! + " pages"
            let bullet2 = "published on " + self.bookYearFIR! + " by " + self.bookPublisherFIR!
            let bullet3 = self.bookGenreFIR
            
            self.strings = [bullet1, bullet2, bullet3!]
            
            var fullString = ""
            
            for string: String in self.strings
            {
                let bulletPoint: String = "\u{2022}"
                let formattedString: String = "\(bulletPoint) \(string)\n"
                
                fullString = fullString + formattedString
            }
            
            //fill ui
            self.bookTitleTextView.text = self.bookTitleFIR! + " by " + self.bookAuthorFIR!
            self.bookDescriptionTextView.text = fullString + "\n" + self.bookDescriptonFIR!
            }
            else{
                self.bookDescriptionTextView.text = self.bookDescriptonFIR
                self.bookTitleTextView.text = self.bookTitleFIR
            }
            self.copiesTextView.text = "copies avalible: " + self.bookCopiesFIR!
            self.bookRatingTextView.text = self.bookRatingFIR! + "/5"
            self.bookTitleTextView.sizeToFit()
            if(self.bookImageURLFIR != nil){
                if let url = URL.init(string: self.bookImageURLFIR!) {
                    self.bookImage.downloadedFrom(url: url)
                }
            }
            
            self.starOneImage.image = starRating(rating: self.bookRatingFIR!, starNumber: 0)
            self.starTwoImage.image = starRating(rating: self.bookRatingFIR!, starNumber: 1.0)
            self.starThreeImage.image = starRating(rating: self.bookRatingFIR!, starNumber: 2.0)
            self.starFourImage.image = starRating(rating: self.bookRatingFIR!, starNumber: 3.0)
            self.starFiveImage.image = starRating(rating: self.bookRatingFIR!, starNumber: 4.0)
            self.bookDescriptionTextView.sizeToFit()
            print(self.bookDescriptionTextView.bounds.size.height)
            self.scrollViewOutlet.contentSize = CGSize(width: self.view.frame.size.width, height: self.bookDescriptionTextView.frame.origin.y + self.bookDescriptionTextView.bounds.size.height)
        })
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.isNavigationBarHidden = false
    }
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(ManualInputViewController.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.copiesTextView.inputAccessoryView = doneToolbar
        self.bookTitleTextView.inputAccessoryView = doneToolbar
        self.bookDescriptionTextView.inputAccessoryView = doneToolbar
        self.bookRatingTextView.inputAccessoryView = doneToolbar
        
    }
    func doneButtonAction() {
        self.copiesTextView.resignFirstResponder()
        self.bookTitleTextView.resignFirstResponder()
        self.bookDescriptionTextView.resignFirstResponder()
        self.bookRatingTextView.resignFirstResponder()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
