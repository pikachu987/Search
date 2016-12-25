//
//  ViewController.swift
//  Search
//
//  Created by guanho on 2016. 12. 23..
//  Copyright © 2016년 guanho. All rights reserved.
//

import UIKit
import Kanna

extension ViewController: UIWebViewDelegate{
    func webViewDidFinishLoad(_ webView: UIWebView) {
        var urlContent = webView.stringByEvaluatingJavaScript(from: "document.documentElement.outerHTML")
        urlContent = urlContent?.replacingOccurrences(of: "\\", with: "", options: .literal, range: nil)
        urlContent = urlContent?.replacingOccurrences(of: "\\\\", with: "", options: .literal, range: nil)
        //print("\r\n\r\n\r\n\(urlContent!)\r\n\r\n\r\n")
        if self.type == "naver"{
            self.naverCrawling(urlContent!)
        }
    }
}
class ViewController: UIViewController {
    @IBOutlet weak var search: UITextField!
    @IBOutlet var collectionView: ASCollectionView!
    var list = [ImageVO]()
    var type: String? = "naver"
    
    var googleWV: UIWebView!
    var naverWV: UIWebView!
    var daumWV: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "Header", bundle: nil), forSupplementaryViewOfKind: "Header", withReuseIdentifier: "header")
        self.collectionView.delegate = self
        self.collectionView.asDataSource = self
        
        self.naverWV = UIWebView()
        
        self.naverWV.delegate = self
        self.naverWV.frame = self.view.frame
        self.naverWV.frame.size.height = self.view.frame.height*3
        self.naverWV.isHidden = true
        self.view.addSubview(naverWV)
    }

    
    @IBAction func urlAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "", message: "SearchEngine", preferredStyle: .actionSheet)
        let google = UIAlertAction(title: "google", style: .default){ (action: UIAlertAction) in
            sender.setTitle(action.title!, for: .normal)
            self.type = action.title!
        }
        let naver = UIAlertAction(title: "naver", style: .default){ (action: UIAlertAction) in
            sender.setTitle(action.title!, for: .normal)
            self.type = action.title!
        }
        let daum = UIAlertAction(title: "daum", style: .default){ (action: UIAlertAction) in
            sender.setTitle(action.title!, for: .normal)
            self.type = action.title!
        }
        alert.addAction(google)
        alert.addAction(naver)
        alert.addAction(daum)
        self.present(alert, animated: false, completion: nil)
    }
    
    func searchAction(){
        let searchStr = self.search.text!
        var urlStr = ""
        self.list = [ImageVO]()
        if self.type == "google"{
            urlStr = "https://www.google.co.kr/search?q=\(searchStr.queryValue())&espv=2&biw=1228&bih=680&source=lnms&tbm=isch&sa=X&ved=0ahUKEwjB2ajayonRAhUGE5QKHejeBBoQ_AUIBigB"
        }else if self.type == "naver"{
            urlStr = "https://m.search.naver.com/search.naver?where=m_image&mode=default&sm=mtb_bac&query=\(searchStr.queryValue())&sort=0&res_fr=0&res_to=0&color=0&datetype=0&startdate=0&enddate=0&nso=so:r,a:all,p:all"
            self.naverWV.loadRequest(URLRequest(url: URL(string: urlStr)!))
        }else if self.type == "daum"{
            
        }
    }
    
    func naverCrawling(_ html: String){
        if let doc = HTML(html: html, encoding: .utf8){
            let grid = doc.css("div.photo_grid").first!
            for aTag in grid.css("a.item_grid"){
                let img = aTag.at_xpath("img")
                let span = aTag.at_xpath("span")
                print(span)
                let imgSrc = img?["src"]
                if imgSrc != "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7"{
                    //let title = aTag?.css("span.data_img").first?.css("span.data_txt").first?.at_xpath("em")?.content
                    let imageVO = ImageVO(imageURL: imgSrc!, title: "")
                    self.list.append(imageVO)
                }
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
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
        DispatchQueue.global().async {
            self.resultImage(idx: indexPath.row){(image: UIImage) in
                DispatchQueue.main.async {
                    gridCell.imageView.image = image
                }
            }
        }
        
        return gridCell
    }
    
    func collectionView(_ asCollectionView: ASCollectionView, parallaxCellForItemAtIndexPath indexPath: IndexPath) -> ASCollectionViewParallaxCell {
        let parallaxCell = collectionView.dequeueReusableCell(withReuseIdentifier: "parallaxCell", for: indexPath) as! ParallaxCell
        let row = self.list[indexPath.row]
        parallaxCell.label.text = row.title
        DispatchQueue.global().async {
            self.resultImage(idx: indexPath.row){(image: UIImage) in
                DispatchQueue.main.async {
                    parallaxCell.updateParallaxImage(image)
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
            
        }
    }
}
