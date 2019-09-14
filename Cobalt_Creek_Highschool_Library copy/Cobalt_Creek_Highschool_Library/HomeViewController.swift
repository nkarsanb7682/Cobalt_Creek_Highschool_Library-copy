//
//  HomeViewController.swift
//  Cobalt_Creek_Highschool_Library
//
//  Created by Grant Falkner on 8/22/17.
//  Copyright © 2017 Grant Falkner. All rights reserved.
//

import UIKit
import Firebase
import NotificationCenter
import UserNotifications
import OAuthSwift
import AVFoundation

struct Tweet{
    var tweet : String?
    var dateInt : Int?
    var dateString : String?
    var imageURL : String?
    var username : String?
}

class HomeViewController: UIViewController, UITableViewDataSource, UIScrollViewDelegate, UITableViewDelegate{
     let requestIdentifier = "SampleRequest"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollViewOutlet: UIScrollView!
    @IBOutlet weak var addBookButtonOutlet: UIButton!
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var manageCheckoutRequestsOutlet: UIButton!
    var tweets : [Tweet] = []
    var tweetsTemp: [Tweet] = []
    var tweetsTemp2: [Tweet] = []
    var frame = CGRect()
    
    let dateFormatter = DateFormatter()
    
    @IBAction func accountButton(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            // User is signed in.
            self.performSegue(withIdentifier: "HomeToAccountManagment", sender: nil)
        }
        else {
            self.performSegue(withIdentifier: "HomeToCreateAccount", sender: nil)
        }
        
    }

    override func viewDidLoad() {
        self.view.backgroundColor = UIColorFromHex(rgbValue: 0x303131, alpha: 1)
        Database.database().reference().child("Librarian").observe(.value, with: { (snapshot) in
            let snapshotValue = snapshot.value as? NSDictionary
            let librarianStatus = snapshotValue![(Auth.auth().currentUser)?.uid as Any] as? String
            if (librarianStatus != nil){
                //user is a librarian
                print("is librarian is true")
                self.addBookButtonOutlet.isHidden = false
                self.manageCheckoutRequestsOutlet.isHidden = false
            }
            else{
                //user is not a librarian
                print("is librarian is false")
            }
        })
        
        if Auth.auth().currentUser != nil {
            // User is signed in.
            accountButton.setTitle("Account", for: .normal)
        }
        else {
            // User is not signed in.
            accountButton.setTitle("Create Account or Sign In", for: .normal)
        }
        if (globalVariables.requestStatus == "Accept"){
            let alert = UIAlertController(title: "Your Request Went Through!", message: "Congratulations, your request was accepted... Your books are due in one week", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            let content = UNMutableNotificationContent()
            content.title = "Your Book is due!"
            content.body = "turn it in today!"
            content.sound = UNNotificationSound.default()
            
            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 60, repeats: false)
            let request = UNNotificationRequest(identifier:requestIdentifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
            UNUserNotificationCenter.current().add(request){(error) in}
            globalVariables.requestStatus = ""
        }
        if (globalVariables.requestStatus == "Deny"){
            let alert = UIAlertController(title: "Your Request Was Denied", message: "We're sorry but we denied your request", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            globalVariables.requestStatus = ""
        }
        tableView.delegate = self
        tableView.dataSource = self
        
        self.scrollViewOutlet.contentSize = CGSize(width: self.view.frame.size.width, height: self.tableView.frame.origin.y)
        
        dateFormatter.dateFormat = "EEE MMM d HH:mm:ss"
        
        let oauthswift = OAuth1Swift(consumerKey: "jlZoMH2k7GHkLwS5ib85d8aYh", consumerSecret: "FQQnDarMNLvbD2NAymLIDYLSIjBSrxNZl2YgLklI9asFm0RgT7")
        //https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=Cobalt_High_Lib
        //https://api.twitter.com/1.1/search/tweets.json?q=%40Cobalt_High_Lib
        
        super.viewDidLoad()
        oauthswift.client.get("https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=Cobalt_High_Lib",
                              success: {response in
                                print("in user timeline")
                                var tweet = [String]()
                                var dateInt = [Int]()
                                var dateString = [String]()
                                var imageURL = [String]()
                                var username = [String]()
                                
                                var dataAsStringTweets = String(data: response.data, encoding: .utf8)
                                var dataAsStringDates = String(data: response.data, encoding: .utf8)
                                var dataAsStringUsername = String(data: response.data, encoding: .utf8)?.replacingOccurrences(of: "city\",\"name\":\"", with: "")
                                var dataAsStringImage = String(data: response.data, encoding: .utf8)?.replacingOccurrences(of: "profile_background_image_url\":\"", with: "")
                                self.tweets.removeAll()
                                //parse for tweets
                                while (dataAsStringTweets?.range(of:",\"text\":\"") != nil) {
                                    tweet.append((dataAsStringTweets?.substring(with: dataAsStringTweets?.endIndex(of: ",\"text\":\"") ..< dataAsStringTweets?.index(of: "\",\"truncated\"")!))!)
                                    dataAsStringTweets?.removeSubrange(dataAsStringTweets?.index(of: ",\"text\":\"") ..< dataAsStringTweets?.endIndex(of: "\",\"truncated\""))
                                }
                                //parse for dates
                                while dataAsStringDates?.range(of:"{\"created_at\":\"") != nil {
                                    dateString.append((dataAsStringDates?.substring(with: dataAsStringDates?.endIndex(of: "{\"created_at\":\"") ..< dataAsStringDates?.index(of: " +0000 2018\",\"id\"")!))!)
                                    dateInt.append(Int(self.dateFormatter.date(from: ((dataAsStringDates?.substring(with: dataAsStringDates?.endIndex(of: "{\"created_at\":\"") ..< dataAsStringDates?.index(of: " +0000 2018\",\"id\"")!))!))!.timeIntervalSince1970))
                                    dataAsStringDates?.removeSubrange(dataAsStringDates?.index(of: "{\"created_at\":\"") ..< dataAsStringDates?.endIndex(of: " +0000 2018\",\"id\""))
                                }
                                //parse for username
                                while dataAsStringUsername?.range(of:"{\"screen_name\":\"Cobalt_High_Lib\",\"name\":\"") != nil {
                                    dataAsStringUsername?.removeSubrange(dataAsStringUsername?.index(of: "{\"screen_name\":\"Cobalt_High_Lib\",\"name\":\"") ..< dataAsStringUsername?.endIndex(of: "\",\"id\":963091886381633536,\"id_str\""))
                                }
                                while dataAsStringUsername?.range(of:"\",\"name\":\"") != nil {
                                    
                                    username.append((dataAsStringUsername?.substring(with: dataAsStringUsername?.endIndex(of: "\",\"name\":\"") ..< dataAsStringUsername?.index(of: "\",\"screen_name\":\"")!))!)
                                    dataAsStringUsername?.removeSubrange(dataAsStringUsername?.index(of: "\",\"name\":\"") ..< dataAsStringUsername?.endIndex(of: "\",\"screen_name\":\""))
                                }
                                while dataAsStringImage?.range(of:"e_url\":\"") != nil {
                                    
                                    imageURL.append(((dataAsStringImage?.substring(with: dataAsStringImage?.endIndex(of: "e_url\":\"") ..< dataAsStringImage?.index(of: "\",\"profile_image_url_https")!))!).replacingOccurrences(of: "\\/", with: "/"))
                                    dataAsStringImage?.removeSubrange(dataAsStringImage?.index(of: "e_url\":\"") ..< dataAsStringImage?.endIndex(of: "\",\"profile_image_url_https"))
                                }
                                for i in 0..<tweet.count {
                                    self.tweetsTemp.insert(Tweet(tweet: tweet[i], dateInt: dateInt[i], dateString: dateString[i], imageURL: imageURL[i], username: username[i]), at: 0)
                                }
                                print(self.tweetsTemp)
                                
        },
                              failure: { error in
                                print("failed")
                                print(error.localizedDescription)
        }
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
        oauthswift.client.get("https://api.twitter.com/1.1/search/tweets.json?q=%40Cobalt_High_Lib",
                              success: {response in
                                print("in search")
                                var tweet = [String]()
                                var dateInt = [Int]()
                                var dateString = [String]()
                                var imageURL = [String]()
                                var username = [String]()
                                
                                var dataAsStringTweets = String(data: response.data, encoding: .utf8)
                                var dataAsStringDates = String(data: response.data, encoding: .utf8)
                                var dataAsStringUsername = String(data: response.data, encoding: .utf8)?.replacingOccurrences(of: "city\",\"name\":\"", with: "")
                                var dataAsStringImage = String(data: response.data, encoding: .utf8)?.replacingOccurrences(of: "profile_background_image_url\":\"", with: "")
                                self.tweets.removeAll()
                                //parse for tweets
                                while (dataAsStringTweets?.range(of:",\"text\":\"") != nil) {
                                    tweet.append((dataAsStringTweets?.substring(with: dataAsStringTweets?.endIndex(of: ",\"text\":\"") ..< dataAsStringTweets?.index(of: "\",\"truncated\"")!))!)
                                    dataAsStringTweets?.removeSubrange(dataAsStringTweets?.index(of: ",\"text\":\"") ..< dataAsStringTweets?.endIndex(of: "\",\"truncated\""))
                                }
                                //parse for dates
                                while dataAsStringDates?.range(of:"{\"created_at\":\"") != nil {
                                    dateString.append((dataAsStringDates?.substring(with: dataAsStringDates?.endIndex(of: "{\"created_at\":\"") ..< dataAsStringDates?.index(of: " +0000 2018\",\"id\"")!))!)
                                    dateInt.append(Int(self.dateFormatter.date(from: ((dataAsStringDates?.substring(with: dataAsStringDates?.endIndex(of: "{\"created_at\":\"") ..< dataAsStringDates?.index(of: " +0000 2018\",\"id\"")!))!))!.timeIntervalSince1970))
                                    dataAsStringDates?.removeSubrange(dataAsStringDates?.index(of: "{\"created_at\":\"") ..< dataAsStringDates?.endIndex(of: " +0000 2018\",\"id\""))
                                }
                                //parse for username
                                while dataAsStringUsername?.range(of:"{\"screen_name\":\"Cobalt_High_Lib\",\"name\":\"") != nil {
                                    dataAsStringUsername?.removeSubrange(dataAsStringUsername?.index(of: "{\"screen_name\":\"Cobalt_High_Lib\",\"name\":\"") ..< dataAsStringUsername?.endIndex(of: "\",\"id\":963091886381633536,\"id_str\""))
                                }
                                while dataAsStringUsername?.range(of:"\",\"name\":\"") != nil {
                                    
                                    username.append((dataAsStringUsername?.substring(with: dataAsStringUsername?.endIndex(of: "\",\"name\":\"") ..< dataAsStringUsername?.index(of: "\",\"screen_name\":\"")!))!)
                                    dataAsStringUsername?.removeSubrange(dataAsStringUsername?.index(of: "\",\"name\":\"") ..< dataAsStringUsername?.endIndex(of: "\",\"screen_name\":\""))
                                }
                                while dataAsStringImage?.range(of:"e_url\":\"") != nil {
                                    
                                    imageURL.append(((dataAsStringImage?.substring(with: dataAsStringImage?.endIndex(of: "e_url\":\"") ..< dataAsStringImage?.index(of: "\",\"profile_image_url_https")!))!).replacingOccurrences(of: "\\/", with: "/"))
                                    dataAsStringImage?.removeSubrange(dataAsStringImage?.index(of: "e_url\":\"") ..< dataAsStringImage?.endIndex(of: "\",\"profile_image_url_https"))
                                }
                                for i in 0..<tweet.count {
                                    self.tweetsTemp2.insert(Tweet(tweet: tweet[i], dateInt: dateInt[i], dateString: dateString[i], imageURL: imageURL[i], username: username[i]), at: 0)
                                }
                                self.tweets.removeAll()
                                self.tweets = self.tweetsTemp + self.tweetsTemp2
                                self.tweets.sort { (object1, object2) -> Bool in
                                    let word1 = object1.dateInt!
                                    let word2 = object2.dateInt
                                    return Double(word1) > Double(word2!)
                                }
                                print(self.tweetsTemp2)
                                print(self.tweets)
                                DispatchQueue.main.async(execute: {
                                    self.tableView.reloadData()
                                })
                                print("array")
        },
                              failure: { error in
                                print(error.localizedDescription)
        }
        )
            })

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let textView = cell.contentView.viewWithTag(5) as! UITextView
        textView.text = tweets[indexPath.row].tweet
        
        let dateText = cell.contentView.viewWithTag(10) as! UILabel
        dateText.text = tweets[indexPath.row].dateString
        
        let userText = cell.contentView.viewWithTag(15) as! UILabel
        userText.text = tweets[indexPath.row].username
        
        let imageView = cell.contentView.viewWithTag(35) as! UIImageView
        
        if let url = URL.init(string: tweets[indexPath.row].imageURL!.replacingOccurrences(of: "http", with: "https")) {
            imageView.downloadedFrom(url: url)
        }
        
        textView.sizeToFit()
        self.tableView.rowHeight =  textView.bounds.size.height + 50
        
        frame = tableView.frame
        frame.size.height = frame.size.height + textView.bounds.size.height + 50
        tableView.frame = frame
        
        self.scrollViewOutlet.contentSize.height = self.scrollViewOutlet.contentSize.height + textView.bounds.size.height+50
       
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.isNavigationBarHidden = true
    }
}

func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
    let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
    let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
    let blue = CGFloat(rgbValue & 0xFF)/256.0
    
    return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
}
    
extension HomeViewController:UNUserNotificationCenterDelegate{
        
        
        func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
            
            print("Tapped in notification")
        }
        
        //This is key callback to present notification while the app is in foreground
        func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            
            print("Notification being triggered")
            
            if notification.request.identifier == requestIdentifier{
                
                completionHandler( [.alert,.sound,.badge])
                
            }
        }
    }
@IBDesignable extension UIButton {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}
@IBDesignable extension UITextField {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}


    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

