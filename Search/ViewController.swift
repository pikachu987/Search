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
    
    lazy var list : Array<ImageVO> = {
        return [ImageVO]()
    }()
    
    lazy var googleWV: UIWebView = {
        return self.wvLoad()
    }()
    
    lazy var naverWV: UIWebView = {
        return self.wvLoad()
    }()
    
    lazy var daumWV: UIWebView = {
        return self.wvLoad()
    }()
    
    lazy var imageCrawling: ImageCrawling = {
        let imageCrawling = ImageCrawling()
        imageCrawling.delegate = self
        return imageCrawling
    }()
    
    lazy var addBtn: UIButton = {
        return self.addBtnLoad()
    }()
    
    lazy var cancelBtn: UIButton = {
        return self.cancelBtnLoad()
    }()
    
    lazy var savedView: SavedView? = {
        return self.savedViewLoad()
    }()
    
    let interactor = Interactor()
    
    var group: DispatchGroup!
    var queue: DispatchQueue!
    var reload = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.register(UINib(nibName: "Header", bundle: nil), forSupplementaryViewOfKind: "Header", withReuseIdentifier: "header")
        self.collectionView.delegate = self
        self.collectionView.asDataSource = self
    }
    
    
    func wvLoad() -> UIWebView{
        let wv = UIWebView()
        wv.delegate = self
        wv.frame = CGRect(x: 0, y: 80, width: self.view.frame.width, height: self.view.frame.height-80)
        wv.isHidden = true
        self.view.addSubview(wv)
        return wv
    }
    
    func addBtnLoad() -> UIButton{
        let addBtn = UIButton()
        addBtn.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 50)
        addBtn.backgroundColor = UIColor.black
        addBtn.setTitle("More", for: .normal)
        addBtn.setTitleColor(UIColor.white, for: .normal)
        addBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.moreAction)))
        self.view.addSubview(addBtn)
        return addBtn
    }
    
    func cancelBtnLoad() -> UIButton{
        let cancelBtn = UIButton()
        cancelBtn.frame = CGRect(x: 0, y: self.view.frame.height-50, width: self.view.frame.width, height: 50)
        cancelBtn.backgroundColor = UIColor.black
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.setTitleColor(UIColor.white, for: .normal)
        cancelBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.cancelAction)))
        cancelBtn.isHidden = true
        view.addSubview(cancelBtn)
        return cancelBtn
    }
    
    func savedViewLoad() -> SavedView?{
        if let customView = Bundle.main.loadNibNamed("SavedView", owner: self, options: nil)?.first as? SavedView {
            let savedView = customView
            savedView.isHidden = true
            savedView.frame = self.view.frame
            view.addSubview(savedView)
            return savedView
        }
        return nil
    }
    
    
    
    
    func moreAction(){
        let alert = UIAlertController(title: "", message: "찾으시는 이미지가 없으신가요?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Google", style: .default) { (_) in
            self.googleWV.isHidden = false
            self.cancelBtn.isHidden = false
        })
        alert.addAction(UIAlertAction(title: "Naver", style: .default) { (_) in
            self.naverWV.isHidden = false
            self.cancelBtn.isHidden = false
        })
        alert.addAction(UIAlertAction(title: "Daum", style: .default) { (_) in
            self.daumWV.isHidden = false
            self.cancelBtn.isHidden = false
        })
        self.present(alert, animated: false, completion: nil)
    }
    
    func cancelAction(){
        self.cancelBtn.isHidden = true
        UIView.animate(withDuration: 0.5, animations: {
            self.googleWV.alpha = 0
            self.naverWV.alpha = 0
            self.daumWV.alpha = 0
        }) { (_) in
            self.googleWV.isHidden = true
            self.naverWV.isHidden = true
            self.daumWV.isHidden = true
            self.googleWV.alpha = 1
            self.naverWV.alpha = 1
            self.daumWV.alpha = 1
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
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}



extension ViewController{
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ImageDetailViewController{
            if let cell = sender as? GridCell{
                let path = self.collectionView.indexPath(for: cell)
                vc.imageVO = self.list[path!.row]
            }else if let cell = sender as? ParallaxCell{
                let path = self.collectionView.indexPath(for: cell)
                vc.imageVO = self.list[path!.row]
            }
            vc.transitioningDelegate = self
            vc.interactor = interactor
        }
    }
}




extension ViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        self.group = DispatchGroup()
        self.queue = DispatchQueue.global()
        self.list = [ImageVO]()
        self.googleWV.isHidden = true
        self.naverWV.isHidden = true
        self.daumWV.isHidden = true
        self.cancelBtn.isHidden = true
        self.collectionView.contentOffset = .zero
        self.googleWV.loadRequest(URLRequest(url: URL(string: self.imageCrawling.searchUrl(.google, search: self.search.text!))!))
        self.naverWV.loadRequest(URLRequest(url: URL(string: self.imageCrawling.searchUrl(.naver, search: self.search.text!))!))
        self.daumWV.loadRequest(URLRequest(url: URL(string: self.imageCrawling.searchUrl(.daum, search: self.search.text!))!))
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
        if self.list.count > indexPath.row{
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
        }
        return gridCell
    }
    
    func collectionView(_ asCollectionView: ASCollectionView, parallaxCellForItemAtIndexPath indexPath: IndexPath) -> ASCollectionViewParallaxCell {
        let parallaxCell = collectionView.dequeueReusableCell(withReuseIdentifier: "parallaxCell", for: indexPath) as! ParallaxCell
        if self.list.count > indexPath.row{
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
            UIView.animate(withDuration: 0.5, animations: {
                self.addBtn.frame.origin.y = self.view.frame.height-50
            })
        }else{
            UIView.animate(withDuration: 0.5, animations: {
                self.addBtn.frame.origin.y = self.view.frame.height
            })
        }
    }
}







extension ViewController: UIWebViewDelegate{
    func webViewDidFinishLoad(_ webView: UIWebView) {
        var urlContent = webView.stringByEvaluatingJavaScript(from: "document.documentElement.outerHTML")
        urlContent = urlContent?.replacingOccurrences(of: "\\", with: "", options: .literal, range: nil)
        urlContent = urlContent?.replacingOccurrences(of: "\\\\", with: "", options: .literal, range: nil)
        //print("\r\n\r\n\r\n\(urlContent!)\r\n\r\n\r\n")
        self.addBtn.frame.origin.y = self.view.frame.height
        
        queue.async(group: group) {
            if webView == self.googleWV{
                self.imageCrawling.parse(urlContent!, type: .google)
            }else if webView == self.naverWV{
                self.imageCrawling.parse(urlContent!, type: .naver)
            }else if webView == self.daumWV{
                self.imageCrawling.parse(urlContent!, type: .daum)
            }
        }
        _ = group.wait(timeout: .distantFuture)
        self.collectionView.reloadData()
    }
}






extension ViewController: CrawlingDelegate{
    func crawlingAdd(_ imageVO: ImageVO) {
        self.list.append(imageVO)
    }
    func crawlingReload() {
        if self.reload == false{
            self.reload = true
            self.collectionView.reloadData()
        }
    }
}






extension ViewController: GridCellDelegate{
    func gridDoubleTap(_ imageView: UIImageView) {
        
    }
    func gridLongPressed(_ imageView: UIImageView, imageVO: ImageVO) {
        UIPasteboard.general.string = imageVO.imageURL
        self.savedView?.isHidden = false
        imageView.boom()
        self.delay(1) {
            imageView.reset()
        }
        UIView.animate(withDuration: 1.5, animations: {
            self.savedView?.alpha = 0
        }) { (_) in
            self.savedView?.alpha = 1
            self.savedView?.isHidden = true
        }
    }
}






extension ViewController: ParallaxCellDelegate{
    func parallaxDoubleTap(_ imageView: UIImageView) {
        
    }
    func parallaxLongPressed(_ imageView: UIImageView, imageVO: ImageVO) {
        UIPasteboard.general.string = imageVO.imageURL
        self.savedView?.isHidden = false
        imageView.boom()
        self.delay(1) {
            imageView.reset()
        }
        UIView.animate(withDuration: 1.5, animations: {
            self.savedView?.alpha = 0
        }) { (_) in
            self.savedView?.alpha = 1
            self.savedView?.isHidden = true
        }
    }
}



extension ViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}
