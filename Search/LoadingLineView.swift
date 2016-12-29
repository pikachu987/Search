//
//  LoadingLineView.swift
//  Search
//
//  Created by guanho on 2016. 12. 29..
//  Copyright © 2016년 guanho. All rights reserved.
//

import UIKit

class LoadingLineView: UIView {
    var width: CGFloat!
    var isAnimated = true
    func setWidth(_ width: CGFloat){
        self.width = width
    }
    func setAnimation(){
        if isAnimated{
            let rd = arc4random_uniform(5)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+Double(rd)) {
                UIView.animate(withDuration: 5, animations: {
                    self.frame.origin.x = self.width
                }, completion: { (_) in
                    self.frame.origin.x = -self.width
                    self.setAnimation()
                })
            }
        }
    }
}
