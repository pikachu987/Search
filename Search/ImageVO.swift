//
//  ImageVO.swift
//  Search
//
//  Created by guanho on 2016. 12. 23..
//  Copyright © 2016년 guanho. All rights reserved.
//

import Foundation

class ImageVO {
    var imageURL: String?
    var imageData: Data?
    var imageDetail: String?
    var title: String?
    
    init(imageURL: String, title: String) {
        self.imageURL = imageURL
        self.title = title
    }
}
