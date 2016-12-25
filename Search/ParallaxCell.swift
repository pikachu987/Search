//
//  ce.swift
//  Search
//
//  Created by guanho on 2016. 12. 23..
//  Copyright © 2016년 guanho. All rights reserved.
//

import UIKit

protocol ParallaxCellDelegate {
    func parallaxDoubleTap(_ imageVO: ImageVO)
    func parallaxLongPressed(_ imageVO: ImageVO)
}

class ParallaxCell: ASCollectionViewParallaxCell {
    var image: ImageVO!
    var delegate: ParallaxCellDelegate?
    
    @IBOutlet var label: UILabel!
    
    override func awakeFromNib() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.doubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.longPressed(_:))))
    }
    
    func doubleTap(_ sender: AnyObject){
        self.delegate?.parallaxDoubleTap(self.image)
    }
    func longPressed(_ sender: UILongPressGestureRecognizer){
        if sender.state == .ended {
        }else if sender.state == .began {
            self.delegate?.parallaxLongPressed(self.image)
        }
    }
}
