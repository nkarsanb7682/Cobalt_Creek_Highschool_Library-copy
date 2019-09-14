//
//  GenreSelectorViewController.swift
//  Cobalt_Creek_Highschool_Library
//
//  Created by Grant Falkner on 9/14/17.
//  Copyright © 2017 Grant Falkner. All rights reserved.
//

import UIKit
import Firebase



class GenreSelectorViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    @IBAction func continueButton(_ sender: Any) {
        Database.database().reference().child("pendingPosts").child(globalVariables.isbn).child("genre").setValue(self.genre)
    }
    var genre : String = "Misc"
    var genres : [String] = ["Misc", "Mystery", "Historical", "Non-Fiction", "Young Adult", "Science Fiction", "Fantasy"];

    @IBOutlet weak var pickerView: UIPickerView!
    override func viewDidLoad() {
        self.view.backgroundColor = UIColorFromHex(rgbValue: 0x303131, alpha: 1)
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self

        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.genres.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genres[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.genre = self.genres[row];
        print(self.genre)
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label: UILabel
        if let view = view as? UILabel { label = view }
        else { label = UILabel() }
        
        label.textColor = UIColorFromHex(rgbValue: 0xD5D5D9, alpha: 1)
        label.textAlignment = .center
        label.font = UIFont(name: "Gil Sans", size: 14)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.text = genres[row]
        
        return label
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
