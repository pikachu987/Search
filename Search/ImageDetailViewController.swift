//
//  ImageDetail.swift
//  Search
//
//  Created by guanho on 2016. 12. 26..
//  Copyright © 2016년 guanho. All rights reserved.
//

import UIKit
import Photos

class ImageDetailViewController: UIViewController {
    var imageVO: ImageVO!
    var image: UIImageView!
    var interactor: Interactor? = nil
    
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var delete: UIButton!
    @IBOutlet var bottom: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(data: self.imageVO.imageData!)
        var width = self.view.frame.width
        if (image?.size.width)! < width{
            width = (image?.size.width)!
        }
        let height = width*(image?.size.height)!/(image?.size.width)!
        
        self.image = UIImageView(frame: CGRect(x: (self.view.frame.width-width)/2, y: (self.view.frame.height-height)/2, width: width, height: height))
        self.image.image = image
        self.image.isUserInteractionEnabled = true
        self.image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageAction(_:))))
        self.view.addSubview(self.image)
        
        self.titleLbl.text = self.imageVO.title
    }
    
    
    @IBAction func handleGesture(_ sender: UIPanGestureRecognizer) {
        DismissAnimator.state(sender, view: self.view, interactor: self.interactor!){
            dismiss(animated: true, completion: nil)
        }
    }
    
    func alphaAction(_ alpha: CGFloat){
        self.delete.alpha = alpha
        self.bottom.alpha = alpha
        self.titleLbl.alpha = alpha
    }
    func hiddenAction(_ isHidden: Bool){
        self.delete.isHidden = isHidden
        self.bottom.isHidden = isHidden
        self.titleLbl.isHidden = isHidden
    }
    
    func imageAction(_ sender: Any){
        if self.delete.isHidden{
            self.alphaAction(0)
            self.hiddenAction(false)
            UIView.animate(withDuration: 0.4, animations: {
                self.alphaAction(1)
            })
        }else{
            UIView.animate(withDuration: 0.4, animations: {
                self.alphaAction(0)
            }, completion: { (_) in
                self.hiddenAction(true)
                self.alphaAction(1)
            })
        }
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        
    }
    @IBAction func saveAction(_ sender: Any) {
        self.galleryAccess {
            PhotoAlbumUtil.saveImageInAlbum(UIImage(data: self.imageVO.imageData!)!, albumName: "search", completion: { (result) in
                switch result {
                case .success:
                    DispatchQueue.main.async(execute: {
                        let alert = UIAlertController(title: "", message: "갤러리에 저장되었습니다.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "확인", style: .default))
                        self.present(alert, animated: true, completion: nil)
                    })
                    break
                case .error:
                    break
                case .denied:
                    break
                }
            })
        }
    }
    @IBAction func shareAction(_ sender: Any) {
        let vc = UIActivityViewController(activityItems: [UIImage(data: self.imageVO.imageData!)!], applicationActivities: [])
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func copyAction(_ sender: Any) {
        UIPasteboard.general.string = self.imageVO.imageURL
        let alert = UIAlertController(title: "", message: "복사되었습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func openAction(_ sender: Any) {
        if let url = Foundation.URL(string: self.imageVO.link!){
            if UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:])
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    
    func galleryAccess(callback: @escaping ((Void)->Void)){
        if PHPhotoLibrary.authorizationStatus().rawValue == 3{
            callback()
        }else{
            PHPhotoLibrary.requestAuthorization() {
                (status) in
                switch status {
                case .authorized:
                    DispatchQueue.main.async {
                        callback()
                    }
                    break
                default:
                    let alert = UIAlertController(title: "", message: "설정창에서 사진 접근 허용을 해주세요.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { (_) in
                        if #available(iOS 8.0, *) {
                            UIApplication.shared.openURL(NSURL(string: "\(UIApplicationOpenSettingsURLString)com.pikachu987.Search") as! URL)
                        }else{
                            UIApplication.shared.open(NSURL(string: "\(UIApplicationOpenSettingsURLString)com.pikachu987.Search") as! URL, options: [:], completionHandler: nil)
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}



extension ImageDetailViewController{
    override var prefersStatusBarHidden: Bool{
        return true
    }
}
