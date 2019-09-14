//
//  ManualInputViewController.swift
//  Cobalt_Creek_Highschool_Library
//
//  Created by Grant Falkner on 9/7/17.
//  Copyright © 2017 Grant Falkner. All rights reserved.
//

import UIKit
import Firebase

class ManualInputViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var publisherTextField: UITextField!
    @IBOutlet weak var dateOfPublicationTextField: UITextField!
    @IBOutlet weak var pageNumberTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var genreTextField: UITextField!
    @IBOutlet weak var ratingTextField: UITextField!
    @IBOutlet weak var scrollViewOutlet: UIScrollView!
    
    let picker = UIPickerView()
    let datePickerView = UIDatePicker()
    
    
    
    var StorageRef: StorageReference!
    
    var genres : [String] = ["Fantasy", "Mystery", "Historical", "Non-Fiction", "Young Adult", "Science Fiction", "Misc"];
    let currentTimeString = String(Int(Date().timeIntervalSince1970)).replacingOccurrences(of: "-", with: "").replacingOccurrences(of: ":", with: "").replacingOccurrences(of: " ", with: "") + "date"

    
    @IBAction func postButton(_ sender: Any) {
               let bookPost : [String : Any] = ["title": self.titleTextField!.text!,
                                         "author" : self.authorTextField.text! ,
                                         "description": self.descriptionTextView.text!,
                                         "rating": self.ratingTextField.text!,
                                         "pageCount" : self.pageNumberTextField.text!,
                                         "year" : self.dateOfPublicationTextField.text!,
                                         "publisher" : self.publisherTextField.text!,
                                         "genre" : self.genreTextField.text!,
                                         "copies" : "1",]
                    
        Database.database().reference().child("pendingPosts").child(currentTimeString).setValue(bookPost)
            globalVariables.isbn = self.currentTimeString
            globalVariables.isPreview = true
        
    }
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColorFromHex(rgbValue: 0x303131, alpha: 1)
        
        self.addDoneButtonOnKeyboard()
        super.viewDidLoad()
        
         self.scrollViewOutlet.contentSize = CGSize(width: 300, height: 800)

        
        
        ratingTextField.delegate = self
        titleTextField.delegate = self
        authorTextField.delegate = self
        pageNumberTextField.delegate = self
        publisherTextField.delegate = self
        
        picker.delegate   = self
        picker.dataSource = self
        
        datePickerView.datePickerMode = UIDatePickerMode.date
        dateOfPublicationTextField.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged), for: UIControlEvents.valueChanged)
        
        self.genreTextField.inputView = picker
        // Do any additional setup after loading the view.
    }
    
    func datePickerValueChanged(sender: UIDatePicker){
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.short
        
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateOfPublicationTextField.text = dateFormatter.string(from: sender.date)
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
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
        self.genreTextField.text = self.genres[row];
    }
    
    //Keyboard Adjustments
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
        
        self.genreTextField.inputAccessoryView = doneToolbar
        self.dateOfPublicationTextField.inputAccessoryView = doneToolbar
        self.descriptionTextView.inputAccessoryView = doneToolbar

    }
    func doneButtonAction() {
        self.genreTextField.resignFirstResponder()
        self.dateOfPublicationTextField.resignFirstResponder()
        self.descriptionTextView.resignFirstResponder()
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
