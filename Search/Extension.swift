//
//  Extension.swift
//  Search
//
//  Created by guanho on 2016. 12. 23..
//  Copyright © 2016년 guanho. All rights reserved.
//

import Foundation
import UIKit

extension String {
    public func substring(from:Int = 0, to:Int = -1) -> String {
        var toTmp = to
        if toTmp < 0 {
            toTmp = self.characters.count + toTmp
        }
        let range = self.characters.index(self.startIndex, offsetBy: from)..<self.characters.index(self.startIndex, offsetBy: toTmp+1)
        return self.substring(with: range)
    }
    public func substring(from:Int = 0, length:Int) -> String {
        let range = self.characters.index(self.startIndex, offsetBy: from)..<self.characters.index(self.startIndex, offsetBy: from+length)
        return self.substring(with: range)
    }
    public func range() -> Range<Index>{
        let range = self.characters.index(self.startIndex, offsetBy: 0)..<self.characters.index(self.startIndex, offsetBy: self.characters.count-1)
        return range
    }
    public func queryValue() -> String{
        let value = self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        return value!
    }
}

extension UIImage{
    func areaAverage() -> RGBColor {
        var bitmap = [UInt8](repeating: 0, count: 4)
        if #available(iOS 9.0, *) {
            let context = CIContext()
            let inputImage: CIImage = ciImage ?? CoreImage.CIImage(cgImage: cgImage!)
            let extent = inputImage.extent
            let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
            let filter = CIFilter(name: "CIAreaAverage", withInputParameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: inputExtent])!
            let outputImage = filter.outputImage!
            let outputExtent = outputImage.extent
            assert(outputExtent.size.width == 1 && outputExtent.size.height == 1)
            context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: kCIFormatRGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
        } else {
            let context = CGContext(data: &bitmap, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
            let inputImage = cgImage ?? CIContext().createCGImage(ciImage!, from: ciImage!.extent)
            context.draw(inputImage!, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        
        let rgb = RGBColor(red: CGFloat(bitmap[0]) / 255.0, green: CGFloat(bitmap[1]) / 255.0, blue: CGFloat(bitmap[2]) / 255.0, alpha: CGFloat(bitmap[3]) / 255.0)
        return rgb
    }
    
    fileprivate struct AssociatedKeys {
        static var aRGBBitmapContextName = "aRGBBitmapContext"
    }
    
    fileprivate var aRGBBitmapContext:CGContext?{
        get{
            return (objc_getAssociatedObject(self, &AssociatedKeys.aRGBBitmapContextName) as! CGContext?)
        }
        set{
            if let newValue = newValue{
                willChangeValue(forKey: AssociatedKeys.aRGBBitmapContextName)
                objc_setAssociatedObject(self, &AssociatedKeys.aRGBBitmapContextName, newValue as CGContext, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                didChangeValue(forKey: AssociatedKeys.aRGBBitmapContextName)
            }
        }
    }
    
    func createARGBBitmapContextFromImage() -> CGContext{
        if aRGBBitmapContext != nil{
            return aRGBBitmapContext!
        }else{
            let pixelsWidth = self.cgImage?.width
            let pixelsHeitht = self.cgImage?.height
            let bitmapBytesPerRow = pixelsWidth! * 4
            let bitmapByteCount = bitmapBytesPerRow * pixelsHeitht!
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapData = malloc(bitmapByteCount)
            let context = CGContext(data: bitmapData,width: pixelsWidth!,height: pixelsHeitht!,bitsPerComponent: 8,bytesPerRow: bitmapBytesPerRow,space: colorSpace, bitmapInfo: CGBitmapInfo().rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)!
            aRGBBitmapContext = context
            return context
        }
    }
    
    func getPixelColorAtLocation(_ point:CGPoint) -> UIColor{
        let pixelData=self.cgImage!.dataProvider!.data
        let data:UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let pixelInfo: Int = ((Int(self.size.width) * Int(point.y)) + Int(point.x)) * 4
        
        let b = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let r = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    func scaleImageToSize(_ size:CGSize) -> UIImage{
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let res = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return res!
    }
}


extension UIImageView{
    
    fileprivate struct AssociatedKeys {
        static var BoomCellsName = "XXYBoomCells"
        static var ScaleSnapshotName = "XXYBoomScaleSnapshot"
    }
    fileprivate var boomCells:[CALayer]?{
        get{
            return objc_getAssociatedObject(self, &AssociatedKeys.BoomCellsName) as? [CALayer]
        }
        set{
            if let newValue = newValue{
                willChangeValue(forKey: AssociatedKeys.BoomCellsName)
                objc_setAssociatedObject(self, &AssociatedKeys.BoomCellsName, newValue as [CALayer], .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                didChangeValue(forKey: AssociatedKeys.BoomCellsName)
            }
        }
    }
    fileprivate var scaleSnapshot:UIImage?{
        get{
            return objc_getAssociatedObject(self, &AssociatedKeys.ScaleSnapshotName) as? UIImage
        }
        set{
            if let newValue = newValue{
                willChangeValue(forKey: AssociatedKeys.ScaleSnapshotName)
                objc_setAssociatedObject(self, &AssociatedKeys.ScaleSnapshotName, newValue as UIImage, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                didChangeValue(forKey: AssociatedKeys.ScaleSnapshotName)
            }
        }
    }
    @objc fileprivate func scaleOpacityAnimations(){
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.toValue = 0.01
        scaleAnimation.duration = 0.15
        scaleAnimation.fillMode = kCAFillModeForwards
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = 0
        opacityAnimation.duration = 0.15
        opacityAnimation.fillMode = kCAFillModeForwards
        
        layer.add(scaleAnimation, forKey: "lscale")
        layer.add(opacityAnimation, forKey: "lopacity")
        layer.opacity = 0
    }
    @objc fileprivate func cellAnimations(){
        for shape in boomCells!{
            shape.position = center
            shape.opacity = 1
            let moveAnimation = CAKeyframeAnimation(keyPath: "position")
            moveAnimation.path = makeRandomPath(shape).cgPath
            moveAnimation.isRemovedOnCompletion = false
            moveAnimation.fillMode = kCAFillModeForwards
            moveAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.240000, 0.590000, 0.506667, 0.026667)
            moveAnimation.duration = TimeInterval(arc4random()%10) * 0.05 + 0.3
            
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.toValue = makeScaleValue()
            scaleAnimation.duration = moveAnimation.duration
            scaleAnimation.isRemovedOnCompletion = false
            scaleAnimation.fillMode = kCAFillModeForwards
            
            let opacityAnimation = CABasicAnimation(keyPath: "opacity")
            opacityAnimation.fromValue = 1
            opacityAnimation.toValue = 0
            opacityAnimation.duration = moveAnimation.duration
            opacityAnimation.isRemovedOnCompletion = true
            opacityAnimation.fillMode = kCAFillModeForwards
            opacityAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.380000, 0.033333, 0.963333, 0.260000)
            
            shape.opacity = 0
            shape.add(scaleAnimation, forKey: "scaleAnimation")
            shape.add(moveAnimation, forKey: "moveAnimation")
            shape.add(opacityAnimation, forKey: "opacityAnimation")
        }
    }
    
    fileprivate func makeShakeValue(_ p:CGFloat) -> CGFloat{
        let basicOrigin = -CGFloat(10)
        let maxOffset = -2 * basicOrigin
        return basicOrigin + maxOffset * (CGFloat(arc4random()%101)/CGFloat(100)) + p
    }
    
    fileprivate func makeScaleValue() -> CGFloat{
        return 1 - 0.7 * (CGFloat(arc4random() % 61)/CGFloat(50))
    }
    
    fileprivate func makeRandomPath(_ aLayer:CALayer) -> UIBezierPath{
        let particlePath = UIBezierPath()
        particlePath.move(to: layer.position)
        let basicLeft = -CGFloat(1.3 * layer.frame.size.width)
        let maxOffset = 2 * abs(basicLeft)
        let randomNumber = arc4random()%101
        let endPointX = basicLeft + maxOffset * (CGFloat(randomNumber)/CGFloat(100)) + aLayer.position.x
        let controlPointOffSetX = (endPointX - aLayer.position.x)/2  + aLayer.position.x
        let controlPointOffSetY = layer.position.y - 0.2 * layer.frame.size.height - CGFloat(arc4random() % UInt32(1.2 * layer.frame.size.height))
        let endPointY = layer.position.y + layer.frame.size.height/2 + CGFloat(arc4random() % UInt32(layer.frame.size.height/2))
        particlePath.addQuadCurve(to: CGPoint(x: endPointX, y: endPointY), controlPoint: CGPoint(x: controlPointOffSetX, y: controlPointOffSetY))
        return particlePath
    }
    
    fileprivate func colorWithPoint(_ x:Int,y:Int,image:UIImage) -> UIColor{
        let pixelData = image.cgImage?.dataProvider?.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(image.size.width) * y) + x) * 4
        
        let a = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let r = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    fileprivate func removeBoomCells(){
        if boomCells == nil {
            return
        }
        for item in boomCells!{
            item.removeFromSuperlayer()
        }
        boomCells?.removeAll(keepingCapacity: false)
        boomCells = nil
    }
    func snapshot() -> UIImage{
        UIGraphicsBeginImageContext(layer.frame.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func boom(){
        let shakeXAnimation = CAKeyframeAnimation(keyPath: "position.x")
        shakeXAnimation.duration = 0.2
        shakeXAnimation.values = [makeShakeValue(layer.position.x),makeShakeValue(layer.position.x),makeShakeValue(layer.position.x),makeShakeValue(layer.position.x),makeShakeValue(layer.position.x)]
        let shakeYAnimation = CAKeyframeAnimation(keyPath: "position.y")
        shakeYAnimation.duration = shakeXAnimation.duration
        shakeYAnimation.values = [makeShakeValue(layer.position.y),makeShakeValue(layer.position.y),makeShakeValue(layer.position.y),makeShakeValue(layer.position.y),makeShakeValue(layer.position.y)]
        
        
        layer.add(shakeXAnimation, forKey: "shakeXAnimation")
        layer.add(shakeYAnimation, forKey: "shakeYAnimation")
        
        _ = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(UIImageView.scaleOpacityAnimations), userInfo: nil, repeats: false)
        
        if boomCells == nil{
            boomCells = [CALayer]()
            for i in 0...16{
                for j in 0...16{
                    if scaleSnapshot == nil{
                        scaleSnapshot = snapshot().scaleImageToSize(CGSize(width: 34, height: 34))
                    }
                    let pWidth = min(frame.size.width,frame.size.height)/17
                    let color = scaleSnapshot!.getPixelColorAtLocation(CGPoint(x: CGFloat(i * 2), y: CGFloat(j * 2)))
                    let shape = CALayer()
                    shape.backgroundColor = color.cgColor
                    shape.opacity = 0
                    shape.cornerRadius = pWidth/2
                    shape.frame = CGRect(x: CGFloat(i) * pWidth, y: CGFloat(j) * pWidth, width: pWidth, height: pWidth)
                    layer.superlayer?.addSublayer(shape)
                    boomCells?.append(shape)
                }
            }
        }
        
        _ = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(UIImageView.cellAnimations), userInfo: nil, repeats: false)
    }
    func reset(){
        layer.opacity = 1
    }
    open override class func initialize() {
        class Static {
            static let token: Int = 0
        }
        
        let originalSelector = #selector(UIImageView.willMove(toSuperview:))
        let swizzledSelector = #selector(UIImageView.XXY_willMoveToSuperview(_:))
        
        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        
        let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        
        if didAddMethod {
            class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    }
    
    func XXY_willMoveToSuperview(_ newSuperView:UIView){
        removeBoomCells()
        XXY_willMoveToSuperview(newSuperView)
    }
    
    
}
