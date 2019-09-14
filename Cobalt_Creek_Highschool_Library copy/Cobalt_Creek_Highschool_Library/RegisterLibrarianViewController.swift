//
//  RegisterLibrarianViewController.swift
//  Cobalt_Creek_Highschool_Library
//
//  Created by Grant Falkner on 8/23/17.
//  Copyright © 2017 Grant Falkner. All rights reserved.
//

import UIKit
import Firebase

class RegisterLibrarianViewController: UIViewController {
    @IBOutlet weak var LibrarianCodeTextField: UITextField!
    @IBOutlet weak var successLabel: UILabel!
    

    @IBAction func submitCodeButton(_ sender: Any) {
  
        //Get Librarian Code
        Database.database().reference().child("Librarian").observe(.value, with: { (snapshot) in
        let snapshotValue = snapshot.value as? NSDictionary
        let librarianCode = snapshotValue!["LibCode"] as? String
            
        //Test if code from Firebase matches input
        if (librarianCode == self.LibrarianCodeTextField.text){
            //upload user to librarians database
            let currentUser = Auth.auth().currentUser
            let userEmail = String((currentUser?.email)!)!

            Database.database().reference().child("Librarian").child(currentUser!.uid).setValue(userEmail)
            self.performSegue(withIdentifier: "RegisterLibrarianToAccountManagment", sender: nil)
        }
        else{
            self.successLabel.text = "Librarian Code was incorrect"
        }
        
        
       
    })
        
        
    
    }
    override func viewDidLoad() {
        self.view.backgroundColor = UIColorFromHex(rgbValue: 0x303131, alpha: 1)
        
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
