//
//  SignInAccountViewController.swift
//  Cobalt_Creek_Highschool_Library
//
//  Created by Grant Falkner on 8/24/17.
//  Copyright © 2017 Grant Falkner. All rights reserved.
//

import UIKit
import Firebase

class SignInAccountViewController: UIViewController {
    @IBOutlet weak var usernameEmailLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func signInButton(_ sender: Any) {
        let email = self.usernameEmailLabel.text
        let password = self.passwordLabel.text
        
        Auth.auth().signIn(withEmail: email!, password: password!) { (user, error) in
            if (error == nil){
                self.performSegue(withIdentifier: "SignInToHome", sender: nil)
            }
            else{
                self.errorLabel.text = "sign in failed"
            }
        }
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.isNavigationBarHidden = false
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
