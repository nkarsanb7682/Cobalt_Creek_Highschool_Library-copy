//
//  AccountManagementViewController.swift
//  Cobalt_Creek_Highschool_Library
//
//  Created by Grant Falkner on 8/22/17.
//  Copyright © 2017 Grant Falkner. All rights reserved.
//

import UIKit
import Firebase

struct book {
    let UID : String!
    let books : String!
    let date : String!
    let dueDate : String!
    let time : String!
    let titleArray : [String]
    let username : String!
    
}

class AccountManagementViewController: UIViewController {
    @IBOutlet weak var currentUserLabel: UILabel!
    @IBOutlet weak var librarianButtonOutlet: UIButton!
    @IBOutlet weak var librarianLabel: UILabel!
    @IBOutlet weak var titleLabelOutlet: UILabel!
    @IBOutlet weak var booksTextViewOutlet: UITextView!
    @IBOutlet weak var returnButtonOutlet: UIButton!
    
    var timer = Timer()
    var timerlock = false
    
    var date : String!
    var books : String!
    var UID : String!
    var dueDate : Double!
    var time : String!
    var titleArray = [String]()
    var username : String!
    
    @IBAction func returnButton(_ sender: Any) {
        Database.database().reference().child("Request").child(self.UID).removeValue()
        let post : [String : Any] = ["books": self.books,
                                     "date" : self.date,
                                     "time" : self.time,
                                     "username" : self.username,
                                     "titleArray" : self.titleArray,
                                     "UID": self.UID,
                                     "type" : "return request"]
        Database.database().reference().child("checkoutRequests").child((Auth.auth().currentUser?.uid)!).setValue(post)
        let alert = UIAlertController(title: nil, message: "Please wait for a librarian to review your request...", preferredStyle: .alert)
        let height:NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: self.view.frame.height * 0.20)
        alert.view.addConstraint(height);
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 85, y: 40, width: 100, height: 100))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        timer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(AccountManagementViewController.testFirebaseLibrarianUpdate), userInfo: nil, repeats: true)
    }
    
    @IBAction func bookBagButton(_ sender: Any) {
        globalVariables.bookBrowsingPageType = "BookBag"
        globalVariables.selectedGenres = ["Misc", "Mystery", "Historical", "Non-Fiction", "Young Adult", "Science Fiction", "Fantasy"]
    }
    @IBAction func signoutButton(_ sender: Any) {
        try! Auth.auth().signOut()
        self.performSegue(withIdentifier: "AccountManagmentToHome", sender: nil)
    }
    @IBAction func librarianButton(_ sender: Any) {
        
    }
    override func viewDidLoad() {
        self.view.backgroundColor = UIColorFromHex(rgbValue: 0x303131, alpha: 1)
        currentUserLabel.text = "Signed in as " + (Auth.auth().currentUser?.email!)!
        
        //test if user is librarian
        Database.database().reference().child("Librarian").observe(.value, with: { (snapshot) in
                let snapshotValue = snapshot.value as? NSDictionary
            let librarianStatus = snapshotValue![(Auth.auth().currentUser)?.uid as Any] as? String
                
                if (librarianStatus != nil){
                    //user is a librarian
                    print("is librarian is true")
                    self.librarianLabel.isHidden = false
                }
                else{
                    //user is not a librarian
                    print("is librarian is false")
                    self.librarianButtonOutlet.isHidden = false
                }
            })
        Database.database().reference().child("checkedOutBooks").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: {snapshot in
            var snapshotValue = snapshot.value as? NSDictionary
            if (snapshotValue?["date"] as? String != nil){
                self.date = snapshotValue!["date"] as? String
                snapshotValue = snapshot.value as? NSDictionary
                self.time = snapshotValue!["time"] as? String
                snapshotValue = snapshot.value as? NSDictionary
                self.titleArray = snapshotValue!["titleArray"] as! [String]
                snapshotValue = snapshot.value as? NSDictionary
                self.books = snapshotValue!["books"] as? String
                snapshotValue = snapshot.value as? NSDictionary
                self.username = snapshotValue!["username"] as? String
                snapshotValue = snapshot.value as? NSDictionary
                self.UID = snapshotValue!["UID"] as? String
                snapshotValue = snapshot.value as? NSDictionary
                self.dueDate = snapshotValue!["dueDate"] as? Double
                snapshotValue = snapshot.value as? NSDictionary
                
                self.titleLabelOutlet.isHidden = false
                self.booksTextViewOutlet.isHidden = false
                self.returnButtonOutlet.isHidden = false
                
                let dueDateAsDate = NSDate(timeIntervalSince1970: self.dueDate!)
                let calendar = Calendar.current
                let day = calendar.component(.day, from: dueDateAsDate as Date)
                let month = calendar.component(.month, from: dueDateAsDate as Date)
                let year = calendar.component(.year, from: dueDateAsDate as Date)
                let hour = calendar.component(.hour, from: dueDateAsDate as Date)
                let minutes = calendar.component(.minute, from: dueDateAsDate as Date)
                self.titleLabelOutlet.text = "Due \(month)/\(day)/\(year) at \(hour):\(minutes)"
                self.booksTextViewOutlet.text = self.books
            }
        
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
    
    func testFirebaseLibrarianUpdate(){
        Database.database().reference().child("Request").observeSingleEvent(of: .value, with: {snapshot in
            let snapshotValue = snapshot.value as? NSDictionary
            if (snapshotValue?[(Auth.auth().currentUser?.uid)!] as? String != nil){
                let status = snapshotValue![(Auth.auth().currentUser?.uid)!] as? String
                print(status!)
                if (status! == "Accepted" && self.timerlock == false){
                    globalVariables.requestStatus = "Accept"
                    self.dismiss(animated: false, completion: nil)
                    self.timer.invalidate()
                    self.timerlock = true
                    self.performSegue(withIdentifier: "AccountManagmentToHome", sender: nil)
                }
                if (status! == "Denied" && self.timerlock == false){
                    globalVariables.requestStatus = "Deny"
                    self.dismiss(animated: false, completion: nil)
                    self.timer.invalidate()
                    self.timerlock = true
                    self.performSegue(withIdentifier: "AccountManagmentToHome", sender: nil)
                }
            }
        })
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
