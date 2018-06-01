//
//  ImageModalViewController.swift
//  AppstemProject
//
//  Created by Alex Hoff on 5/31/18.
//

import UIKit

class ImageModalViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var item: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let image = item {
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
