//
//  BookBrowsingHomeViewController.swift
//  Cobalt_Creek_Highschool_Library
//
//  Created by Grant Falkner on 9/28/17.
//  Copyright © 2017 Grant Falkner. All rights reserved.
//

import UIKit

class BookBrowsingHomeViewController: UIViewController {
    @IBAction func browseAllBooksButton(_ sender: Any) {
        globalVariables.selectedGenres = ["Misc", "Mystery", "Historical", "Non-Fiction", "Young Adult", "Science Fiction", "Fantasy"]
        globalVariables.bookBrowsingPageType = "Library"
    }
    @IBAction func bookBagButton(_ sender: Any) {
        globalVariables.bookBrowsingPageType = "BookBag"
        globalVariables.selectedGenres = ["Misc", "Mystery", "Historical", "Non-Fiction", "Young Adult", "Science Fiction", "Fantasy"]
    }
    @IBAction func browseByCatagoryButton(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColorFromHex(rgbValue: 0x303131, alpha: 1)
        globalVariables.selectedGenres.removeAll()
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
