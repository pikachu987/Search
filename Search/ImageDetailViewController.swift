//
//  ImageDetail.swift
//  Search
//
//  Created by guanho on 2016. 12. 26..
//  Copyright © 2016년 guanho. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController {
    var imageVO: ImageVO!
    var image: UIImageView!
    var interactor: Interactor? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(data: self.imageVO.imageData!)
        var width = self.view.frame.width
        if (image?.size.width)! < width{
            width = (image?.size.width)!
        }
        let height = width*(image?.size.height)!/(image?.size.width)!
        
        self.image = UIImageView(frame: CGRect(x: (self.view.frame.width-width)/2, y: (self.view.frame.height-height)/2, width: width, height: height))
        self.image.image = image
        self.view.addSubview(self.image)
    }
    
    
    @IBAction func handleGesture(_ sender: UIPanGestureRecognizer) {
        DismissAnimator.state(sender, view: self.view, interactor: self.interactor!){
            dismiss(animated: true, completion: nil)
        }
    }
}



extension ImageDetailViewController{
    override var prefersStatusBarHidden: Bool{
        return false
    }
}
