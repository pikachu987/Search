//
//  LoadingView.swift
//  Search
//
//  Created by guanho on 2016. 12. 29..
//  Copyright © 2016년 guanho. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    var loadingArray: [LoadingLineView] = []
    
    func setLoading(){
        let cnt = Int(ceil(self.frame.height/40))
        for idx in 0...cnt-1{
            if let customView = Bundle.main.loadNibNamed("LoadingLineView", owner: self, options: nil)?.first as? LoadingLineView {
                customView.frame = CGRect(x: -self.frame.width, y: CGFloat(idx*40), width: self.frame.width, height: 40)
                customView.setWidth(self.frame.width)
                self.addSubview(customView)
                customView.setAnimation()
            }
        }
    }
    
    func stop(){
        self.isHidden = true
        for lineView in self.loadingArray{
            lineView.isAnimated = false
        }
    }
    
    func start(){
        self.isHidden = false
        for lineView in self.loadingArray{
            lineView.isAnimated = false
            lineView.setAnimation()
        }
    }
}
