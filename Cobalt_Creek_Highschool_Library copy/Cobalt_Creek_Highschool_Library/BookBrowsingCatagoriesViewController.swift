//
//  BookBrowsingCatagoriesViewController.swift
//  Cobalt_Creek_Highschool_Library
//
//  Created by Grant Falkner on 10/9/17.
//  Copyright © 2017 Grant Falkner. All rights reserved.
//

import UIKit

func radioButton(buttonPushcount: Int,genre: String)-> UIImage{
    if (buttonPushcount%2 == 0){
        globalVariables.selectedGenres = globalVariables.selectedGenres.filter({ $0 != genre })
        for element in globalVariables.selectedGenres {
            print(element)
        }
        return #imageLiteral(resourceName: "Empty Radio")
        
    }
    else{
        globalVariables.selectedGenres.insert(genre, at: 0)
        for element in globalVariables.selectedGenres {
            print(element)
        }
        return #imageLiteral(resourceName: "Full Radio")
    }
    
}

class BookBrowsingCatagoriesViewController: UIViewController {
    @IBOutlet weak var historicalButtonOutlet: UIButton!
    @IBOutlet weak var nonFictionButtonOutlet: UIButton!
    @IBOutlet weak var fantacyButtonOutlet: UIButton!
    @IBOutlet weak var youngAdultButtonOutlet: UIButton!
    @IBOutlet weak var scienceFictionButtonOutlet: UIButton!
    @IBOutlet weak var mysteryButtonOutlet: UIButton!
    
    var historicalPushCount = 0, nonFictionPushCount = 0, fantacyPushCount = 0, youngAdultPushCount = 0, scienceFicitonPushcount = 0, mysteryPushCount = 0
    
    @IBAction func historicalButton(_ sender: Any) {
        historicalPushCount = historicalPushCount + 1
        historicalButtonOutlet.setImage(radioButton(buttonPushcount: historicalPushCount,genre: "Historical"), for: .normal)
    }
    @IBAction func nonFictionButton(_ sender: Any) {
        nonFictionPushCount = nonFictionPushCount + 1
        nonFictionButtonOutlet.setImage(radioButton(buttonPushcount: nonFictionPushCount,genre: "Non-Fiction"), for: .normal)
    }
    @IBAction func fantacyButton(_ sender: Any) {
        fantacyPushCount = fantacyPushCount + 1
        fantacyButtonOutlet.setImage(radioButton(buttonPushcount: fantacyPushCount,genre: "Fantacy"), for: .normal)
    }
    @IBAction func youngAdultButton(_ sender: Any) {
        youngAdultPushCount = youngAdultPushCount + 1
        youngAdultButtonOutlet.setImage(radioButton(buttonPushcount: youngAdultPushCount,genre: "Young Adult"), for: .normal)
    }
    @IBAction func scienceFictionButton(_ sender: Any) {
        scienceFicitonPushcount = scienceFicitonPushcount + 1
        scienceFictionButtonOutlet.setImage(radioButton(buttonPushcount: scienceFicitonPushcount,genre: "Science Fiction"), for: .normal)
    }
    @IBAction func mysteryButton(_ sender: Any) {
        mysteryPushCount = mysteryPushCount + 1
        mysteryButtonOutlet.setImage(radioButton(buttonPushcount: mysteryPushCount, genre: "Mystery"), for: .normal)
    }
    @IBAction func searchButton(_ sender: Any) {
        globalVariables.bookBrowsingPageType = "Library"
        if (globalVariables.selectedGenres.isEmpty){
            globalVariables.selectedGenres = ["Misc", "Mystery", "Historical", "Non-Fiction", "Young Adult", "Science Fiction", "Fantasy"]
        }
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
