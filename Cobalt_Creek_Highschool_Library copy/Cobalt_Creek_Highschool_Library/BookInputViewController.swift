//
//  BookInputViewController.swift
//  Cobalt_Creek_Highschool_Library
//
//  Created by Grant Falkner on 8/19/17.
//  Copyright © 2017 Grant Falkner. All rights reserved.
//

import UIKit
import Firebase
import Foundation

//global variable
struct globalVariables {
    static var isbn = ""
    static var selectedGenres: [String] = []
    static var isPreview = false
    static var bookBrowsingPageType = ""
    static var requestStatus = ""
    static var alreadyHasBookCheckedOut = false
}

//artifical string opperations
extension String {
    func index(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    func endIndex(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
    func indexes(of string: String, options: CompareOptions = .literal) -> [Index] {
        var result: [Index] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range.lowerBound)
            start = range.upperBound
        }
        return result
    }
}



//downloading image from url
extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}

//xml parsing
func xmlParse(word: String,xmlData: String) -> String{
    let startOfObject = xmlData.endIndex(of: "<\(word)>")
    let endOfObject = xmlData.index(of: "</\(word)>")
    print(startOfObject)
    
    let substring = xmlData.substring(with: startOfObject!..<endOfObject!)
    
    //special cases
    let ss1 = substring.replacingOccurrences(of: "<br />", with: "")
    let ss2 = ss1.replacingOccurrences(of: "[", with: "")
    let ss3 = ss2.replacingOccurrences(of: "]", with: "")
    let ss4 = ss3.replacingOccurrences(of: "CDATA", with: "")
    let ss5 = ss4.replacingOccurrences(of: "<!", with: "")
    let ss6 = ss5.replacingOccurrences(of: ">", with: "")
    let ss7 = ss6.replacingOccurrences(of: "<b", with: "")
    let ss8 = ss7.replacingOccurrences(of: "</b", with: "")
    let ss9 = ss8.replacingOccurrences(of: "<i", with: "")
    let ss10 = ss9.replacingOccurrences(of: "</i", with: "")
    
    return ss10
}
func addACopy(currentCopies: String,isbn : String){
    let copiesInt = Int(currentCopies)!
    let copiesString = String(copiesInt + 1)
    print(copiesString)
    Database.database().reference().child("verifiedPosts").child(isbn).updateChildValues(["copies": copiesString])
}

class BookInputViewController: UIViewController {
    var bookTitle: String? = ""
    var bookAuthor: String? = ""
    var bookDescripton: String? = ""
    var bookImageURL: String? = ""
    var bookISBN: String? = ""
    var bookRating: String? = ""
    var bookPageCount: String? = ""
    var bookYear: String? = ""
    var bookPublisher: String? = ""
    var bookCoppies: String? = ""
    
        
    

    @IBOutlet weak var addButtonOutlet: UIButton!
    @IBOutlet weak var titleInput: UITextField!
    @IBOutlet weak var titleVerificationLabel: UILabel!
    @IBOutlet weak var bookImage: UIImageView!
    
    @IBAction func homeButton(_ sender: Any) {
        self.navigationController?.isNavigationBarHidden = false
        print("home button pressed")
    }
    
    @IBAction func addManuallyButton(_ sender: Any) {
        self.navigationController?.isNavigationBarHidden = false
    }
    @IBAction func searchButton(_ sender: Any) {
        addButtonOutlet.isHidden = false
        titleVerificationLabel.isHidden = false
        let title = titleInput.text
        let titleNoSpace = title?.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        let urlGoodReads = "https://www.goodreads.com/book/title.xml?key=7bGOgFbcrzLOIhlp5J5cQ&title=" + titleNoSpace!
        //getting api data as string using urlgoodreads
        guard let url = URL(string: urlGoodReads) else{
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let data = data else{
                return
            }
            
            let dataAsString = String(data: data, encoding: .utf8)
            if(dataAsString == "<error>Page not found</error>")||(xmlParse(word: "isbn", xmlData: dataAsString!) == "")
            {
                DispatchQueue.main.async(execute: {
                    self.bookImage.isHidden = true
                    self.titleVerificationLabel.text = "book not in goodreads database... please add manualy or try using the ISBN"
                    self.addButtonOutlet.isHidden = true
                })

                return
            }
            //parsing dataAsString

            self.bookTitle = xmlParse(word: "title", xmlData: dataAsString!)
            self.bookDescripton = xmlParse(word: "description", xmlData: dataAsString!)
            self.bookAuthor = xmlParse(word: "name", xmlData: dataAsString!)
            self.bookImageURL = xmlParse(word: "image_url", xmlData: dataAsString!)
            self.bookISBN = xmlParse(word: "isbn", xmlData: dataAsString!)
            self.bookRating = xmlParse(word: "average_rating", xmlData: dataAsString!)
            self.bookPageCount = xmlParse(word: "num_pages", xmlData: dataAsString!)
            let publicationYear = xmlParse(word: "publication_year", xmlData: dataAsString!)
            let publicationMonth = xmlParse(word: "publication_month", xmlData: dataAsString!)
            let publicationDay = xmlParse(word: "publication_day", xmlData: dataAsString!)
            self.bookYear = publicationMonth + "/" + publicationDay + "/" + publicationYear
            self.bookPublisher = xmlParse(word: "publisher", xmlData: dataAsString!)
            
            
            
            

            //verification ui setup
            DispatchQueue.main.async(execute: {
                self.bookImage.isHidden = false
                self.titleVerificationLabel.text = self.bookTitle! + " by " + self.bookAuthor!
                if (self.bookImageURL != "https://s.gr-assets.com/assets/nophoto/book/111x148-bcc042a9c91a29c1d680899eff700a03.png"){
                if let url = URL.init(string: self.bookImageURL!) {
                    self.bookImage.downloadedFrom(url: url)
                }
                }
                else{
                    self.bookImage.image = #imageLiteral(resourceName: "rsz_image_not_found_")
                    self.bookImageURL = "https://firebasestorage.googleapis.com/v0/b/cobalt-creek-highschool-lib.appspot.com/o/rsz_image_not_found_.png?alt=media&token=5a5b5185-17ad-4794-9410-af2be31f7997"
                }
            })
            }.resume()
    }
    @IBAction func postButton(_ sender: Any) {
        self.navigationController?.isNavigationBarHidden = false
        Database.database().reference().child("verifiedPosts").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(self.bookISBN!){
                print("book has been posted")
                let alert = UIAlertController(title: "Add another copy?", message: "This title is already in the library database. Add another copy?", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action in
                    Database.database().reference().child("verifiedPosts").child(self.bookISBN!).observeSingleEvent(of: .value, with: {snapshot in
                        let snapshotValue = snapshot.value as? NSDictionary
                        self.bookCoppies = snapshotValue!["copies" as Any] as? String
                        addACopy(currentCopies: self.bookCoppies!, isbn: self.bookISBN!)
                        
                        
                    })
                    

                    
                }))
                alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
                
                
                
                self.present(alert, animated: true, completion: nil)

            }else{
                let bookPost : [String : Any] = ["title": self.bookTitle!,
                                                 "author" : self.bookAuthor! ,
                                                 "description": self.bookDescripton!,
                                                 "image" : self.bookImageURL!,
                                                 "rating": self.bookRating!,
                                                 "pageCount" : self.bookPageCount!,
                                                 "year" : self.bookYear!,
                                                 "publisher" : self.bookPublisher!,
                                                 "copies" : "1",]
                Database.database().reference().child("pendingPosts").child(self.bookISBN!).setValue(bookPost)
                globalVariables.isbn = self.bookISBN!
                globalVariables.isPreview = true
                self.performSegue(withIdentifier: "BookInputToGenreSelector", sender: nil)

            }
            
            
        })
        
    }
    override func viewDidLoad() {
        self.view.backgroundColor = UIColorFromHex(rgbValue: 0x303131, alpha: 1)
        
        
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.isNavigationBarHidden = true
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
