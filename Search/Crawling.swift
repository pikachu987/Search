//
//  Crawling.swift
//  Search
//
//  Created by guanho on 2016. 12. 26..
//  Copyright © 2016년 guanho. All rights reserved.
//

import UIKit
import Kanna

enum Craw {
    case google
    case naver
    case daum
}

protocol CrawlingDelegate {
    func crawlingAdd(_ imageVO: ImageVO)
    func crawlingReload()
    func crawlingNoData(_ type: Craw)
}

class ImageCrawling {
    var delegate: CrawlingDelegate?
    func searchUrl(_ type: Craw, search: String) -> String{
        if type == .google{
            return "https://www.google.co.kr/search?q=\(search.queryValue())&espv=2&biw=1228&bih=680&source=lnms&tbm=isch&sa=X&ved=0ahUKEwjB2ajayonRAhUGE5QKHejeBBoQ_AUIBigB"
        }else if type == .naver{
            return "https://m.search.naver.com/search.naver?where=m_image&mode=default&sm=mtb_bac&query=\(search.queryValue())&sort=0&res_fr=0&res_to=0&color=0&datetype=0&startdate=0&enddate=0&nso=so:r,a:all,p:all"
        }else if type == .daum{
            return "https://m.search.daum.net/search?w=img&q=\(search.queryValue())&DA=IIM"
        }
        return ""
    }
    func arrTag(_ type: Craw) -> String{
        if type == .google{
            return "div.rg_di"
        }else if type == .naver{
            return "a.item_grid"
        }else if type == .daum{
            return "figure.wrap_thumb"
        }
        return ""
    }
    func imgSrc(_ type: Craw, element: XMLElement) -> String?{
        if type == .google{
            return element.at_css("a.rg_l")?.at_xpath("img")?["data-src"]
        }else if type == .naver{
            return element.at_xpath("img")?["src"]
        }else if type == .daum{
            return element.at_css("img.thumb_img")?["src"]
        }
        return ""
    }
    func title(_ type: Craw, element: XMLElement) -> String?{
        do {
            if type == .google{
                let meta = element.at_css("div.rg_meta")
                let metaData = try JSONSerialization.jsonObject(with: (meta?.innerHTML?.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)))!, options: []) as! [String:AnyObject]
                return (metaData["s"] as? String)!
            }else if type == .naver{
                let meta = element.at_xpath("span")
                let metaData = try JSONSerialization.jsonObject(with: (meta?.text?.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)))!, options: []) as! [String:AnyObject]
                return (metaData["title"] as? String)!.removingPercentEncoding!
            }else if type == .daum{
                let meta = element.at_xpath("figcaption")
                return meta?.content
            }
        } catch{}
        return ""
    }
    
    func link(_ type: Craw, element: XMLElement) -> String?{
        do {
            if type == .google{
                let meta = element.at_css("div.rg_meta")
                let metaData = try JSONSerialization.jsonObject(with: (meta?.innerHTML?.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)))!, options: []) as! [String:AnyObject]
                return (metaData["ru"] as? String)!
            }else if type == .naver{
                let meta = element.at_xpath("span")
                let metaData = try JSONSerialization.jsonObject(with: (meta?.text?.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)))!, options: []) as! [String:AnyObject]
                return (metaData["link"] as? String)!.removingPercentEncoding!
            }else if type == .daum{
                let meta = element.at_css("a.link_thumb")
                return meta?["href"]
            }
        } catch{}
        return ""
    }
    
    func parse(_ html: String, type: Craw){
        if let doc = HTML(html: html, encoding: .utf8){
            var idx = 0
            for element in doc.css(self.arrTag(type)){
                let imgSrc = self.imgSrc(type, element: element)
                let title = self.title(type, element: element)
                let link = self.link(type, element: element)
                
                if imgSrc != nil && imgSrc != "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7"{
                    self.delegate?.crawlingAdd(ImageVO(imageURL: imgSrc!, title: title!, link: link!))
                    idx += 1
                }
            }
            if idx == 0{
                DispatchQueue.main.async {
                    self.delegate?.crawlingNoData(type)
                }
            }
            DispatchQueue.main.async {
                self.delegate?.crawlingReload()
            }
        }
    }
}
