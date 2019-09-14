//
//  BookBrowsingTableViewController.swift
//  Cobalt_Creek_Highschool_Library
//
//  Created by Grant Falkner on 9/28/17.
//  Copyright © 2017 Grant Falkner. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

struct post {
    let image : String!
    let title : String!
    let rating : String!
    let copies : String!
    let description : String!
    let genre : String!
    let isbn : String!
    let bookBag : String!
}

class BookBrowsingTableViewController: UIViewController, UITableViewDataSource, UIScrollViewDelegate, UITableViewDelegate {
    var posts = [post]()
    var postsTemp = [post]()
    var buttonCount = 2;
    var postCount : Int!
    var timer = Timer()
    var timerlock = false
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bookBagButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var radioButtonOutlet: UIButton!
    @IBOutlet weak var radioButtonLabel: UILabel!
    @IBOutlet weak var navigationBarOutlet: UINavigationBar!
    
    @IBOutlet weak var hideCheckedOutButtonOutlet: UIButton!
    
    @IBAction func bookBagButton(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            
            Database.database().reference().child("checkedOutBooks").child((Auth.auth().currentUser?.uid)!).observe(.childAdded, with: {snapshot in
                let snapshotValue = snapshot.value as? NSDictionary
                if (snapshotValue?["UID"] as? String == nil){
                    globalVariables.alreadyHasBookCheckedOut = true
                }
                else{
                    globalVariables.alreadyHasBookCheckedOut = false
                }
            })
            
            if (globalVariables.bookBrowsingPageType != "BookBag"){
                globalVariables.bookBrowsingPageType = "BookBag"
                navigationBarOutlet.topItem?.title = "Book Bag"
                radioButtonOutlet.isHidden = true
                radioButtonLabel.isHidden = true
                
                posts = postsTemp
                var removedCount = 0
                
                for i in 0..<postCount{
                    let bookBagStatus = posts[i-removedCount].bookBag
                    
                    if(bookBagStatus == nil){
                        posts.remove(at: i - removedCount)
                        removedCount = removedCount + 1
                    }
                }
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
                bookBagButtonOutlet.title = "Checkout"
            }
            else if (globalVariables.bookBrowsingPageType == "BookBag" && posts.count != 0){
                if (globalVariables.alreadyHasBookCheckedOut == true){
                    let alert = UIAlertController(title: "Already Have Books", message: "You already have books checked out... please return them before checking out more", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    let currentUser = Auth.auth().currentUser
                    var titleStrings = [String]()
                    var titleData = [String]()
                    for i in 0..<posts.count{
                        print(i)
                        titleStrings.append(posts[i].title)
                        titleData.append(posts[i].isbn)
                    }
                    
                    var fullString = ""
                    
                    for string: String in titleStrings
                    {
                        let bulletPoint: String = "\u{2022}"
                        let formattedString: String = "\(bulletPoint) \(string)\n"
                        
                        fullString = fullString + formattedString
                    }
                    
                    let date = Date()
                    let calendar = Calendar.current
                    let day = calendar.component(.day, from: date)
                    let month = calendar.component(.month, from: date)
                    let year = calendar.component(.year, from: date)
                    let hour = calendar.component(.hour, from: date)
                    let minutes = calendar.component(.minute, from: date)
                    let dateString = "\(month)/\(day)/\(year)"
                    let timeString = "\(hour):\(minutes)"
                    
                    Database.database().reference().child("Request").child((currentUser?.uid)!).removeValue()
                    
                    let post : [String : Any] = ["books": fullString,
                                                 "date" : dateString,
                                                 "time" : timeString,
                                                 "username" : (Auth.auth().currentUser?.email!)!,
                                                 "titleArray" : titleData,
                                                 "UID": (currentUser?.uid)!,
                                                 "type" : "checkout request"]
                    Database.database().reference().child("checkoutRequests").child((currentUser?.uid)!).setValue(post)
                    print("post count \(posts.count)")
                    let alert = UIAlertController(title: nil, message: "Please wait for a librarian to review your request...", preferredStyle: .alert)
                    let height:NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: self.view.frame.height * 0.20)
                    alert.view.addConstraint(height);
                    
                    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 85, y: 40, width: 100, height: 100))
                    loadingIndicator.hidesWhenStopped = true
                    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                    loadingIndicator.startAnimating();
                    
                    alert.view.addSubview(loadingIndicator)
                    present(alert, animated: true, completion: nil)
                    timer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(BookBrowsingTableViewController.testFirebaseLibrarianUpdate), userInfo: nil, repeats: true)
                }
            }
        }
        else{
            self.performSegue(withIdentifier: "BookBrowsingTableToSignIn", sender: nil)
        }
       
    }
    @IBAction func hideCheckedOutButton(_ sender: Any) {
        if (buttonCount%2 == 0){
            var removedCount = 0
            for i in 0..<postCount{
                let copycount = posts[i-removedCount].copies
                
                if (copycount == "0"){
                    posts.remove(at: i - removedCount)
                    postCount = postCount - 1
                    removedCount = removedCount + 1
                }
            }
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
            hideCheckedOutButtonOutlet.setImage(#imageLiteral(resourceName: "Full Radio.png"), for: .normal)
        }
        else{
            posts = postsTemp
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
            hideCheckedOutButtonOutlet.setImage(#imageLiteral(resourceName: "Empty Radio.png"), for: .normal)
        }
        buttonCount = buttonCount + 1
    }
    @IBOutlet weak var segmentedControlOutlet: UISegmentedControl!
    @IBAction func segmentedControlAction(_ sender: UISegmentedControl) {
        switch segmentedControlOutlet.selectedSegmentIndex
        {
        case 0:
            posts.sort { (object1, object2) -> Bool in
                return object1.title < object2.title
            }
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        case 1:
            posts.sort { (object1, object2) -> Bool in
                let word1 = object1.rating!
                let word2 = object2.rating!
                return Double(word1)! > Double(word2)!
                
            }
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        default:
            break
        }

    }
    override func viewDidLoad() {
        self.view.backgroundColor = UIColorFromHex(rgbValue: 0x303131, alpha: 1)
        self.segmentedControlOutlet.setTitleTextAttributes([NSForegroundColorAttributeName : UIColorFromHex(rgbValue: 0xD5D5D9, alpha: 1)], for: .normal)
        globalVariables.alreadyHasBookCheckedOut = false
        if (globalVariables.bookBrowsingPageType == "BookBag"){
            bookBagButtonOutlet.title = "Checkout"
            navigationBarOutlet.topItem?.title = "Book Bag"
            hideCheckedOutButtonOutlet.isHidden = true
            print("you are in the book bag")
        }
        else{
            navigationBarOutlet.topItem?.title = ""
        }
        print(globalVariables.bookBrowsingPageType)
        segmentedControlOutlet.setTitle("Sort by Title", forSegmentAt: 0)
        segmentedControlOutlet.setTitle("Sort by Rating", forSegmentAt: 1)
        tableView.rowHeight = 200
        
        tableView.delegate = self
        tableView.dataSource = self
        
        Database.database().reference().child("verifiedPosts").observe(.childAdded, with: {snapshot in
            let currentUser = Auth.auth().currentUser
            
            var snapshotValue = snapshot.value as? NSDictionary
            let copies = snapshotValue!["copies"] as? String
            snapshotValue = snapshot.value as? NSDictionary
            let description = snapshotValue!["description"] as? String
            snapshotValue = snapshot.value as? NSDictionary
            let genre = snapshotValue!["genre"] as? String
            snapshotValue = snapshot.value as? NSDictionary
            let image = snapshotValue!["image"] as? String
            snapshotValue = snapshot.value as? NSDictionary
            let rating = snapshotValue!["rating"] as? String
            snapshotValue = snapshot.value as? NSDictionary
            let title = snapshotValue!["title"] as? String
            snapshotValue = snapshot.value as? NSDictionary
            let isbn = snapshotValue!["isbn"] as? String
            snapshotValue = snapshot.value as? NSDictionary
            var bookBag : String?
            if Auth.auth().currentUser != nil {
                bookBag = snapshotValue![(currentUser?.uid)!] as? String
                snapshotValue = snapshot.value as? NSDictionary
            }
            else{
                bookBag = snapshotValue![" "] as? String
                snapshotValue = snapshot.value as? NSDictionary
            }
            snapshotValue = snapshot.value as? NSDictionary
            
            for i in 0...globalVariables.selectedGenres.count-1 {
            
                if(globalVariables.selectedGenres[i] == genre!){
                    
                    self.posts.insert(post(image : image, title:title, rating: rating, copies : copies, description:description , genre : genre, isbn : isbn, bookBag : bookBag), at: 0)
                    self.postCount = self.posts.count
                    if (globalVariables.bookBrowsingPageType == "BookBag"){
                        var removedCount = 0
                        for i in 0..<self.postCount{
                            let bookBagStatus = self.posts[i-removedCount].bookBag
                            
                            if(bookBagStatus == nil){
                                self.posts.remove(at: i - removedCount)
                                removedCount = removedCount + 1
                            }
                        }
                    }
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
                    self.postsTemp = self.posts
                    }
            }
        })
        
        
        posts.sort { (object1, object2) -> Bool in
                return object1.title < object2.title
        }
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let imageView = cell.contentView.viewWithTag(5) as! UIImageView
        
        let titleLabel = cell.contentView.viewWithTag(10) as! UILabel
        titleLabel.text = posts[indexPath.row].title
        
        let ratingLabel = cell.contentView.viewWithTag(15) as! UILabel
        ratingLabel.text = "(" + posts[indexPath.row].rating + "/5)"
        
        let copiesLabel = cell.contentView.viewWithTag(20) as! UILabel
        if (posts[indexPath.row].copies == "1"){
            copiesLabel.text = posts[indexPath.row].copies + " copy avalible"
        }
        else if (posts[indexPath.row].copies == "0"){
            copiesLabel.text = "all copies checked out"
        }
        else{
            copiesLabel.text = posts[indexPath.row].copies + " copies avalible"
        }
        
        let starOne = cell.contentView.viewWithTag(25) as! UIImageView
        starOne.image = starRating(rating: posts[indexPath.row].rating, starNumber: 1)
        
        let starTwo = cell.contentView.viewWithTag(30) as! UIImageView
        starTwo.image = starRating(rating: posts[indexPath.row].rating, starNumber: 2)
        
        let starThree = cell.contentView.viewWithTag(35) as! UIImageView
        starThree.image = starRating(rating: posts[indexPath.row].rating, starNumber: 3)
        
        let starFour = cell.contentView.viewWithTag(40) as! UIImageView
        starFour.image = starRating(rating: posts[indexPath.row].rating, starNumber: 4)
        
        let starFive = cell.contentView.viewWithTag(45) as! UIImageView
        starFive.image = starRating(rating: posts[indexPath.row].rating, starNumber: 5)
        
        if let url = URL.init(string: posts[indexPath.row].image) {
            imageView.downloadedFrom(url: url)
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (globalVariables.bookBrowsingPageType != "BookBag"){
            let rowISBN = posts[indexPath.row].isbn
            globalVariables.isbn = rowISBN!
            globalVariables.isPreview = false
            self.performSegue(withIdentifier: "BrowsingBooksTableToStorePage", sender: nil)
        }
        else{
            let alert = UIAlertController(title: "Remove From Bag?", message: "Are you sure you would like to remove " + posts[indexPath.row].title + " from your bag?", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive, handler: { action in
                Database.database().reference().child("verifiedPosts").child(self.posts[indexPath.row].isbn).child((Auth.auth().currentUser?.uid)!).removeValue()
                self.posts.remove(at: indexPath.row)
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.isNavigationBarHidden = true
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
                    self.performSegue(withIdentifier: "BookBrowsingTableToHome", sender: nil)
                }
                if (status! == "Denied" && self.timerlock == false){
                    globalVariables.requestStatus = "Deny"
                    self.dismiss(animated: false, completion: nil)
                    self.timer.invalidate()
                    self.timerlock = true
                    self.performSegue(withIdentifier: "BookBrowsingTableToHome", sender: nil)
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
