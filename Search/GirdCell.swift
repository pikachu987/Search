//
//  ImageCell.swift
//  Search
//
//  Created by guanho on 2016. 12. 23..
//  Copyright © 2016년 guanho. All rights reserved.
//

import UIKit

protocol GridCellDelegate {
    func gridDoubleTap(_ imageVO: ImageVO)
    func gridLongPressed(_ imageVO: ImageVO)
}

class GridCell: UICollectionViewCell {
    var image: ImageVO!
    var delegate: GridCellDelegate?
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var label: UILabel!
    
    override func awakeFromNib() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.doubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.longPressed(_:))))
    }
    
    override func prepareForReuse() {
        self.imageView.image = nil
    }
    
    func doubleTap(_ sender: AnyObject){
        self.delegate?.gridDoubleTap(self.image)
    }
    func longPressed(_ sender: UILongPressGestureRecognizer){
        if sender.state == .ended {
        }else if sender.state == .began {
            self.delegate?.gridLongPressed(self.image)
        }
    }
}
