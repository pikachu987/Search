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
            // Get average color.
            let context = CIContext()
            let inputImage: CIImage = ciImage ?? CoreImage.CIImage(cgImage: cgImage!)
            let extent = inputImage.extent
            let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
            let filter = CIFilter(name: "CIAreaAverage", withInputParameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: inputExtent])!
            let outputImage = filter.outputImage!
            let outputExtent = outputImage.extent
            assert(outputExtent.size.width == 1 && outputExtent.size.height == 1)
            
            // Render to bitmap.
            context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: kCIFormatRGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
        } else {
            // Create 1x1 context that interpolates pixels when drawing to it.
            let context = CGContext(data: &bitmap, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
            let inputImage = cgImage ?? CIContext().createCGImage(ciImage!, from: ciImage!.extent)
            
            // Render to bitmap.
            context.draw(inputImage!, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        
        let rgb = RGBColor(red: CGFloat(bitmap[0]) / 255.0, green: CGFloat(bitmap[1]) / 255.0, blue: CGFloat(bitmap[2]) / 255.0, alpha: CGFloat(bitmap[3]) / 255.0)
        return rgb
    }
}
