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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
