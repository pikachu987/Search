//
//  ViewController.swift
//  Search
//
//  Created by guanho on 2016. 12. 23..
//  Copyright © 2016년 guanho. All rights reserved.
//

import UIKit
import Kanna


class ViewController: UIViewController {
    @IBOutlet weak var search: UITextField!
    @IBOutlet weak var collectionView: ASCollectionView!
    var list : Array<ImageVO> = [ImageVO]()
    
    var googleWV: UIWebView!
    var naverWV: UIWebView!
    var daumWV: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.register(UINib(nibName: "Header", bundle: nil), forSupplementaryViewOfKind: "Header", withReuseIdentifier: "header")
        self.collectionView.delegate = self
        self.collectionView.asDataSource = self
        
        self.naverWV = UIWebView()
        self.googleWV = UIWebView()
        self.daumWV = UIWebView()
        
        self.googleWV.delegate = self
        self.googleWV.frame = self.view.frame
        self.googleWV.frame.size.height = self.view.frame.height*3
        self.googleWV.isHidden = true
        self.view.addSubview(googleWV)
        
        self.naverWV.delegate = self
        self.naverWV.frame = self.view.frame
        self.naverWV.frame.size.height = self.view.frame.height*3
        self.naverWV.isHidden = true
        self.view.addSubview(naverWV)
        
        self.daumWV.delegate = self
        self.daumWV.frame = self.view.frame
        self.daumWV.frame.size.height = self.view.frame.height*3
        self.daumWV.isHidden = true
        self.view.addSubview(daumWV)
    }

    
    
    func searchAction(){
        let searchStr = self.search.text!
        let googleUrl = "https://www.google.co.kr/search?q=\(searchStr.queryValue())&espv=2&biw=1228&bih=680&source=lnms&tbm=isch&sa=X&ved=0ahUKEwjB2ajayonRAhUGE5QKHejeBBoQ_AUIBigB"
        let naverUrl = "https://m.search.naver.com/search.naver?where=m_image&mode=default&sm=mtb_bac&query=\(searchStr.queryValue())&sort=0&res_fr=0&res_to=0&color=0&datetype=0&startdate=0&enddate=0&nso=so:r,a:all,p:all"
        let daumUrl = "https://m.search.daum.net/search?w=img&q=\(searchStr.queryValue())&DA=IIM"
        
        self.list = [ImageVO]()
        self.googleWV.loadRequest(URLRequest(url: URL(string: googleUrl)!))
        self.naverWV.loadRequest(URLRequest(url: URL(string: naverUrl)!))
        self.daumWV.loadRequest(URLRequest(url: URL(string: daumUrl)!))
    }
    
    
    func add(){
        //let naverAddScript = ""
        //self.naverWV.stringByEvaluatingJavaScript(from: naverAddScript)
    }
    
    
    func resultImage(idx: Int, callback: @escaping ((UIImage) -> Void)){
        let row = self.list[idx]
        if row.imageData == nil{
            if let imageUrl = Foundation.URL(string: row.imageURL!){
                if let imageData = try? Data(contentsOf: imageUrl){
                    row.imageData = imageData
                    callback(UIImage(data: row.imageData!)!)
                }
            }
        }else{
            callback(UIImage(data: row.imageData!)!)
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.searchAction()
        return false
    }
}

extension ViewController: ASCollectionViewDelegate{
}

extension ViewController: ASCollectionViewDataSource{
    func numberOfItemsInASCollectionView(_ asCollectionView: ASCollectionView) -> Int {
        return self.list.count
    }
    
    func collectionView(_ asCollectionView: ASCollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let gridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GridCell
        let row = self.list[indexPath.row]
        gridCell.label.text = row.title
        gridCell.image = row
        gridCell.delegate = self
        DispatchQueue.global().async {
            self.resultImage(idx: indexPath.row){(image: UIImage) in
                DispatchQueue.main.async {
                    gridCell.imageView.image = image
                    let imageColor = image.areaAverage()
                    let color = UIColor(red: 1-imageColor.red!, green: 1-imageColor.green!, blue: 1-imageColor.blue!, alpha: 1)
                    gridCell.label.textColor = color
                }
            }
        }
        
        return gridCell
    }
    
    func collectionView(_ asCollectionView: ASCollectionView, parallaxCellForItemAtIndexPath indexPath: IndexPath) -> ASCollectionViewParallaxCell {
        let parallaxCell = collectionView.dequeueReusableCell(withReuseIdentifier: "parallaxCell", for: indexPath) as! ParallaxCell
        let row = self.list[indexPath.row]
        parallaxCell.label.text = row.title
        parallaxCell.image = row
        parallaxCell.delegate = self
        DispatchQueue.global().async {
            self.resultImage(idx: indexPath.row){(image: UIImage) in
                DispatchQueue.main.async {
                    parallaxCell.updateParallaxImage(image)
                    let imageColor = image.areaAverage()
                    let color = UIColor(red: 1-imageColor.red!, green: 1-imageColor.green!, blue: 1-imageColor.blue!, alpha: 1)
                    parallaxCell.label.textColor = color
                }
            }
        }
        return parallaxCell
    }
    
    func collectionView(_ asCollectionView: ASCollectionView, headerAtIndexPath indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: ASCollectionViewElement.Header, withReuseIdentifier: "header", for: indexPath)
        return header
    }
    
    func loadMoreInASCollectionView(_ asCollectionView: ASCollectionView) {
        
    }
}


extension ViewController: UITableViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        if deltaOffset <= 0{
            self.add()
        }
    }
}


extension ViewController: UIWebViewDelegate{
    func webViewDidFinishLoad(_ webView: UIWebView) {
        var urlContent = webView.stringByEvaluatingJavaScript(from: "document.documentElement.outerHTML")
        urlContent = urlContent?.replacingOccurrences(of: "\\", with: "", options: .literal, range: nil)
        urlContent = urlContent?.replacingOccurrences(of: "\\\\", with: "", options: .literal, range: nil)
        //print("\r\n\r\n\r\n\(urlContent!)\r\n\r\n\r\n")
        
        DispatchQueue.global().async {
            if webView == self.googleWV{
                self.googleCrawling(urlContent!)
            }else if webView == self.naverWV{
                self.naverCrawling(urlContent!)
            }else if webView == self.daumWV{
                self.daumCrawling(urlContent!)
            }
        }
    }
    
    
    func googleCrawling(_ html: String){
        if let doc = HTML(html: html, encoding: .utf8){
            for element in doc.css("div.rg_di"){
                let img = element.at_css("a.rg_l")
                let imgSrc = img?.at_xpath("img")?["data-src"]
                
                let meta = element.at_css("div.rg_meta")
                var title = ""
                do {
                    let metaData = try JSONSerialization.jsonObject(with: (meta?.innerHTML?.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)))!, options: []) as! [String:AnyObject]
                    title = (metaData["s"] as? String)!
                } catch{}
                
                if imgSrc != nil{
                    let imageVO = ImageVO(imageURL: imgSrc!, title: title)
                    self.list.append(imageVO)
                }
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    func naverCrawling(_ html: String){
        if let doc = HTML(html: html, encoding: .utf8){
            let grid = doc.css("div.photo_grid").first!
            for element in grid.css("a.item_grid"){
                let img = element.at_xpath("img")
                let imgSrc = img?["src"]
                
                let meta = element.at_xpath("span")
                var title = ""
                do {
                    let spanData = try JSONSerialization.jsonObject(with: (meta?.text?.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)))!, options: []) as! [String:AnyObject]
                    title = (spanData["title"] as? String)!.removingPercentEncoding!
                } catch{}
                if imgSrc != nil && imgSrc != "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7"{
                    let imageVO = ImageVO(imageURL: imgSrc!, title: title)
                    self.list.append(imageVO)
                }
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    func daumCrawling(_ html: String){
        if let doc = HTML(html: html, encoding: .utf8){
            let list = doc.css("div#imageList").first!
            for element in list.css("figure.wrap_thumb"){
                let img = element.at_css("img.thumb_img")
                let imgSrc = img?["src"]
                
                let meta = element.at_xpath("figcaption")
                let title = meta?.content
                if imgSrc != nil{
                    let imageVO = ImageVO(imageURL: imgSrc!, title: title!)
                    self.list.append(imageVO)
                }
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
}

extension ViewController: GridCellDelegate{
    func gridDoubleTap(_ imageVO: ImageVO) {
        
    }
    func gridLongPressed(_ imageVO: ImageVO) {
        
    }
}

extension ViewController: ParallaxCellDelegate{
    func parallaxDoubleTap(_ imageVO: ImageVO) {
        
    }
    func parallaxLongPressed(_ imageVO: ImageVO) {
        
    }
}
