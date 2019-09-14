//
//  ManageCheckoutRequestsViewController.swift
//  Cobalt_Creek_Highschool_Library
//
//  Created by Grant Falkner on 1/8/18.
//  Copyright © 2018 Grant Falkner. All rights reserved.
//

import UIKit
import Firebase

struct request {
    let username : String!
    let time: String!
    var titleArray = [String]()
    let date : String!
    let books : String!
    let UID : String!
    let requestType : String!
    mutating func addTask(task: String){
        titleArray.append(task)
    }
}
func subtractACopy(currentCopies: String,isbn : String){
    let copiesInt = Int(currentCopies)!
    let copiesString = String(copiesInt - 1)
    print(copiesString)
    Database.database().reference().child("verifiedPosts").child(isbn).updateChildValues(["copies": copiesString])
}
class ManageCheckoutRequestsViewController: UIViewController, UITableViewDataSource, UIScrollViewDelegate, UITableViewDelegate {
    var requests = [request]()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColorFromHex(rgbValue: 0x303131, alpha: 1)
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 250;
        tableView.rowHeight = UITableViewAutomaticDimension
        
        Database.database().reference().child("checkoutRequests").observe(.childAdded, with: {snapshot in
            
            var snapshotValue = snapshot.value as? NSDictionary
            let date = snapshotValue!["date"] as? String
            snapshotValue = snapshot.value as? NSDictionary
            let time = snapshotValue!["time"] as? String
            snapshotValue = snapshot.value as? NSDictionary
            let titleArray = snapshotValue!["titleArray"] as! [String]
            snapshotValue = snapshot.value as? NSDictionary
            let books = snapshotValue!["books"] as? String
            snapshotValue = snapshot.value as? NSDictionary
            let username = snapshotValue!["username"] as? String
            snapshotValue = snapshot.value as? NSDictionary
            let UID = snapshotValue!["UID"] as? String
            snapshotValue = snapshot.value as? NSDictionary
            let requestType = snapshotValue!["type"] as? String
            snapshotValue = snapshot.value as? NSDictionary
            
            self.requests.insert(request(username:username, time:time, titleArray: titleArray, date:date,books:books,UID:UID,requestType:requestType), at: 0)
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })

        })

        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let usernameLabel = cell.contentView.viewWithTag(5) as! UILabel
        usernameLabel.text = "\((requests[indexPath.row].username)!)  \((requests[indexPath.row].requestType)!)"
        
        let booksTextView = cell.contentView.viewWithTag(15) as! UITextView
        booksTextView.text = requests[indexPath.row].books
        
        let denyButton = cell.contentView.viewWithTag(20) as! UIButton
        denyButton.addTarget(self, action: #selector(denyButtonAction(sender:)), for: UIControlEvents.touchUpInside)
        
        let acceptButton = cell.contentView.viewWithTag(25) as! UIButton
        acceptButton.addTarget(self, action: #selector(acceptButtonAction(sender:)), for: UIControlEvents.touchUpInside)
        
        return cell
    }
    func denyButtonAction(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        if indexPath != nil {
            let alert = UIAlertController(title: "Deny Request?", message: "Are you sure you would like to deny " + requests[(indexPath?.row)!].username + "'s checkout request?", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive, handler: { action in
                Database.database().reference().child("Request").child(self.requests[(indexPath?.row)!].UID).setValue("Denied")
                Database.database().reference().child("checkoutRequests").child(self.requests[(indexPath?.row)!].UID).removeValue()
                
                for i in 0..<self.requests[(indexPath?.row)!].titleArray.count{
                    Database.database().reference().child("verifiedPosts").child(self.requests[(indexPath?.row)!].titleArray[i]).child(self.requests[(indexPath?.row)!].UID).removeValue()
                }

                self.requests.remove(at: (indexPath?.row)!)
                
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }))
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    func acceptButtonAction(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        if indexPath != nil {
            let alert = UIAlertController(title: "Accept Request?", message: "Are you sure you would like to accept " + requests[(indexPath?.row)!].username + "'s checkout request?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action in
               
                Database.database().reference().child("Request").child(self.requests[(indexPath?.row)!].UID).setValue("Accepted")
                for i in 0..<self.requests[(indexPath?.row)!].titleArray.count{
                    print(self.requests[(indexPath?.row)!].titleArray[i])
                    Database.database().reference().child("verifiedPosts").child(self.requests[(indexPath?.row)!].titleArray[i]).child(self.requests[(indexPath?.row)!].UID).removeValue()
                }
                Database.database().reference().child("checkoutRequests").child(self.requests[(indexPath?.row)!].UID).removeValue()
                
                if (self.requests[(indexPath?.row)!].requestType == "checkout request"){
                    let post : [String : Any] = ["books": self.requests[(indexPath?.row)!].books,
                                                 "date" : self.requests[(indexPath?.row)!].date,
                                                 "time" : self.requests[(indexPath?.row)!].time,
                                                 "username" : self.requests[(indexPath?.row)!].username,
                                                 "titleArray" : self.requests[(indexPath?.row)!].titleArray,
                                                 "UID": self.requests[(indexPath?.row)!].UID,
                                                 "dueDate" : NSDate().timeIntervalSince1970+604800]
                    Database.database().reference().child("checkedOutBooks").child(self.requests[(indexPath?.row)!].UID).setValue(post)
                }
                else if(self.requests[(indexPath?.row)!].requestType == "return request"){
                    Database.database().reference().child("checkedOutBooks").child(self.requests[(indexPath?.row)!].UID).removeValue()
                }
                for i in 0..<self.requests[(indexPath?.row)!].titleArray.count{
                   let array = self.requests[(indexPath?.row)!].titleArray
                    let requestTypeString = self.requests[(indexPath?.row)!].requestType
                    Database.database().reference().child("verifiedPosts").child(self.requests[(indexPath?.row)!].titleArray[i]).observeSingleEvent(of: .value, with: {snapshot in
                        
                        var snapshotValue = snapshot.value as? NSDictionary
                        let copies = snapshotValue!["copies"] as? String
                        snapshotValue = snapshot.value as? NSDictionary
                        if (requestTypeString == "checkout request"){
                            subtractACopy(currentCopies: copies!, isbn: array[i])
                        }
                        if (requestTypeString == "return request"){
                            addACopy(currentCopies: copies!, isbn: array[i])
                        }
                })
                }
                    self.requests.remove(at: (indexPath?.row)!)
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                
            }))
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.isNavigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
