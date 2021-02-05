//
//  ImageViewController.swift
//  Camera
//
//  Created by 阿迦井翔 on 2021/02/03.
//

import UIKit

class ImageViewController: UIViewController {
    
    var image: UIImage!
    @IBOutlet weak var imageV: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        imageV.image = image

    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    

}
