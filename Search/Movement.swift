//
//  Movement.swift
//  Search
//
//  Created by guanho on 2016. 12. 28..
//  Copyright © 2016년 guanho. All rights reserved.
//

import UIKit

protocol MovementDelegate {
    func moveAddSubView(_ moveView: MoveView)
}

class Movement {
    var delegate: MovementDelegate?
    var frame: CGRect!
    var isStart = true
    lazy var movementArray: [MoveView] = {
        return []
    }()
    lazy var colorArray: [UIColor] = {
        var arr = [UIColor]()
        arr.append(UIColor.red)
        arr.append(UIColor.green)
        arr.append(UIColor.black)
        arr.append(UIColor.blue)
        arr.append(UIColor.brown)
        arr.append(UIColor.orange)
        return arr
    }()
    
    func start(_ frame: CGRect){
        self.frame = frame
        self.startThraed()
    }
    
    func startThraed(){
        if self.movementArray.count < 10 && self.isStart{
            self.addView()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+5) {
                self.startThraed()
            }
        }
    }
    
    func stop(){
        self.isStart = false
        for mv in self.movementArray{
            mv.removeFromSuperview()
        }
        self.movementArray.removeAll()
    }
    
    func rdMove(_ mv: MoveView) -> (CGFloat, CGFloat){
        var moveX: CGFloat = 0
        var moveY: CGFloat = 0
        switch arc4random_uniform(2){
        case 0: moveX = 0
        default: moveX = self.frame.width
        }
        switch arc4random_uniform(2){
        case 0: moveY = 80
        default: moveY = self.frame.height+80
        }
        switch arc4random_uniform(2){
        case 0: moveX = self.frame.width/2
        default: moveY = (self.frame.height+80)/2
        }
        if (mv.frame.origin.x == moveX) && (mv.frame.origin.y == moveY){
            return rdMove(mv)
        }else{
            return (moveX, moveY)
        }
    }
    
    func move(_ mv: MoveView){
        let rdMV = self.rdMove(mv)
        let moveX = rdMV.0
        let moveY = rdMV.1
        if !self.isStart{
            return
        }
        UIView.animate(withDuration: 2, animations: {
            mv.frame.origin.x = moveX
            mv.frame.origin.y = moveY
        }) { (_) in
            if self.isStart{
                switch arc4random_uniform(3){
                case 0: mv.frame.origin.x = 0
                case 1: mv.frame.origin.x = self.frame.width/2
                default: mv.frame.origin.x = self.frame.width
                }
                switch arc4random_uniform(3){
                case 0: mv.frame.origin.y = 80
                case 1: mv.frame.origin.y = (self.frame.height+80)/2
                default: mv.frame.origin.y = self.frame.height+80
                }
                self.move(mv)
            }
        }
    }
    
    
    func addView(){
        let mv = MoveView()
        mv.frame = CGRect(x: 0, y: 80, width: 10, height: 10)
        mv.layer.cornerRadius = 5
        mv.layer.masksToBounds = false
        mv.clipsToBounds = true
        let rd: UInt32 = UInt32(self.colorArray.count)
        mv.backgroundColor = self.colorArray[Int(arc4random_uniform(rd))]
        self.movementArray.append(mv)
        self.delegate?.moveAddSubView(mv)
        self.move(mv)
    }
}
