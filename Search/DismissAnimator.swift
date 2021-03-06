//
//  DismissAnimator.swift
//  Search
//
//  Created by guanho on 2016. 12. 27..
//  Copyright © 2016년 guanho. All rights reserved.
//

import UIKit

class DismissAnimator : NSObject {
}

extension DismissAnimator : UIViewControllerAnimatedTransitioning {
    static var tx: CGFloat!
    static var ty: CGFloat!
    
    static func abs(_ value: CGFloat) -> CGFloat{
        if value > 0{
            return value
        }else{
            return -value
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else {
                return
        }
        transitionContext.containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        func animate(_ animation: @escaping ((Void) -> Void)){
            UIView.animate(
                withDuration: transitionDuration(using: transitionContext),
                animations: {
                    animation()
            },
                completion: { _ in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                    DismissAnimator.tx = nil
                    DismissAnimator.ty = nil
            }
            )
        }
        
        if DismissAnimator.tx == nil || DismissAnimator.ty == nil{
            animate({ (_) in
                fromVC.view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.main.bounds.size)
            })
        }else{
            if DismissAnimator.tx > 0{
                x = UIScreen.main.bounds.width
            }else if DismissAnimator.tx < 0{
                x = -UIScreen.main.bounds.width
            }
            if DismissAnimator.ty > 0{
                y = UIScreen.main.bounds.height
            }else if DismissAnimator.ty < 0{
                y = -UIScreen.main.bounds.height
            }
            
            if x == 0 && y == 0{
                animate({ (_) in
                    fromVC.view.alpha = 0
                    if let vc = fromVC as? ImageDetailViewController{
                        vc.delete.frame.origin.x = -vc.delete.frame.width
                        vc.titleLbl.frame.origin.x = -vc.titleLbl.frame.width
                        vc.bottom.frame.origin.y = vc.view.frame.height+vc.bottom.frame.height
                        vc.image.frame.origin.y = -vc.image.frame.height
                    }
                })
            }else{
                let pt = CGPoint(x: x, y: y)
                animate({ (_) in
                    fromVC.view.frame = CGRect(origin: pt, size: UIScreen.main.bounds.size)
                })
            }
        }
    }
    
    static func state(_ sender: UIPanGestureRecognizer, view: UIView, interactor:Interactor, callback:((Void)->Void)){
        let percentThreshold:CGFloat = 0.3
        let translation = sender.translation(in: view)
        DismissAnimator.tx = translation.x
        DismissAnimator.ty = translation.y
        
        let horizontalMovement = translation.x / view.bounds.width
        let verticalMovement = translation.y / view.bounds.height
        
        var progress: CGFloat = 0
        if DismissAnimator.abs(horizontalMovement) > DismissAnimator.abs(verticalMovement){
            if horizontalMovement > 0{
                progress = horizontalMovement
            }else{
                progress = -horizontalMovement
            }
        }else{
            if verticalMovement > 0{
                progress = verticalMovement
            }else{
                progress = -verticalMovement
            }
        }
        switch sender.state {
        case .began:
            interactor.hasStarted = true
            callback()
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish
                ? interactor.finish()
                : interactor.cancel()
        default:
            break
        }
    }
}
