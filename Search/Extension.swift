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
