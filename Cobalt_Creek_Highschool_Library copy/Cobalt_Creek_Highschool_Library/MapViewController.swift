//
//  MapViewController.swift
//  Cobalt_Creek_Highschool_Library
//
//  Created by Grant Falkner on 9/28/17.
//  Copyright © 2017 Grant Falkner. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var zoomingContent: UIView!
    
    @IBOutlet weak var zoomingContentOutlet: UIView!
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var scrollViewOutlet: UIScrollView!
    
    @IBAction func historicalButton(_ sender: Any) {
        print("historial doubletapped")
        globalVariables.selectedGenres = ["Historical"]
        self.performSegue(withIdentifier: "MapToBookBrowsingTable", sender: nil)
        
    }
    @IBAction func youngAdultButton(_ sender: Any) {
        print("young adult doubletapped")
        globalVariables.selectedGenres = ["Young Adult"]
        self.performSegue(withIdentifier: "MapToBookBrowsingTable", sender: nil)
    }
    @IBAction func scienceFictionButton(_ sender: Any) {
        print("Science Fiction doubletapped")
        globalVariables.selectedGenres = ["Science Fiction"]
        self.performSegue(withIdentifier: "MapToBookBrowsingTable", sender: nil)
    }
    @IBAction func nonFictionButton(_ sender: Any) {
        print("non fiction doubletapped")
        globalVariables.selectedGenres = ["Non Fiction"]
        self.performSegue(withIdentifier: "MapToBookBrowsingTable", sender: nil)
    }
    @IBAction func fantacyButton(_ sender: Any) {
        print("fantacy doubletapped")
        globalVariables.selectedGenres = ["Fantasy"]
        self.performSegue(withIdentifier: "MapToBookBrowsingTable", sender: nil)
    }
    @IBAction func mysteryButton(_ sender: Any) {
        print("mystery button doubletapped")
        globalVariables.selectedGenres = ["Mystery"]
        self.performSegue(withIdentifier: "MapToBookBrowsingTable", sender: nil)
    }
    
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColorFromHex(rgbValue: 0x303131, alpha: 1)
        scrollViewOutlet.minimumZoomScale = 1.0
        scrollViewOutlet.maximumZoomScale = 5.0
        
        scrollViewOutlet.delegate = self
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomingContent
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
