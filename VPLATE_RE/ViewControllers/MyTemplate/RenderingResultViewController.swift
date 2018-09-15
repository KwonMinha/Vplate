//
//  RenderingResultViewController.swift
//  VPLATE_RE
//
//  Created by mokjinook on 2018. 8. 8..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import BMPlayer
import SwiftyJSON
import ObjectMapper
import Photos
import FacebookShare
import FBSDKLoginKit
import FBSDKShareKit

class RenderingResultViewController: ViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var player: Player!
    @IBOutlet weak var viewEdit: UIView!
    @IBOutlet weak var viewNoComplete: UIView!
    @IBOutlet weak var viewComplete: UIView!
    @IBOutlet weak var buttonAlbum: UIButton!
    @IBOutlet weak var buttonFacebook: UIButton!
    @IBOutlet weak var buttonInstagram: UIButton!
    @IBOutlet weak var buttonMore: UIButton!
    @IBOutlet weak var buttonTerms: UIButton!
    
    var id: String?
    var state: TemplateState?
    var url: String?
    var modifiedCount: Int?
    let indicatorView = FullIndicatorView()
    var saveViedoUrl: String?
    var imagePicker:UIImagePickerController = UIImagePickerController()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewEdit.borderWidth = 1
        self.viewEdit.borderColor = UIColor.init(hexString: "#ff122d")
        
        if self.state == .confirmed {
            self.title = "Share".localized
            self.reloadView(isComplete: true)
        } else {
            self.title = "Rendering Complete".localized
            self.reloadView(isComplete: false)
        }
        BMPlayerConf.topBarShowInCase = BMPlayerTopBarShowCase.horizantalOnly
        self.player.setVideo(resource: BMPlayerResource(url: URL(string: self.url!)!))
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.player.isMuted(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.player.pause(allowAutoPlay: true)
    }
    
    func reloadView(isComplete: Bool) {
        if(isComplete) {
            self.viewNoComplete.isHidden = true
            self.viewComplete.isHidden = false
        } else {
            self.viewNoComplete.isHidden = false
            self.viewComplete.isHidden = true
        }
    }
    
    func closeViewController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showShareDialog<C: ContentProtocol>(_ content: C, mode: ShareDialogMode = .automatic) {
        let dialog = ShareDialog(content: content)
        dialog.presentingViewController = self
        dialog.mode = mode
        do {
            try dialog.show()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //MARK: Save Video
    func saveVideo() {
        self.indicatorView.show(true)
        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: self.url!),
                let urlData = NSData(contentsOf: url) {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                let filePath="\(documentsPath)/tempFile.mp4"
                DispatchQueue.main.async {
                    urlData.write(toFile: filePath, atomically: true)
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                    }) { completed, error in
                        if completed {
                            self.indicatorView.show(false)
                            let alertController = UIAlertController(title: nil, message: "Your video has been saved to your album".localized, preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "YES".localized, style: .default, handler: nil)
                            alertController.addAction(defaultAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    //MARK: Bottom Button Action
    @IBAction func actionBtnTerms(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            saveVideo()
        case 1:
            self.indicatorView.show(true)
            DispatchQueue.main.async {
                
                if let url = URL(string: self.url!),
                    let urlData = NSData(contentsOf: url) {
                    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                    let filePath="\(documentsPath)/tempFile.mp4"
                    DispatchQueue.main.async {
                        urlData.write(toFile: filePath, atomically: true)
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                        }) { completed, error in
                            if completed {
                                DispatchQueue.main.async {
                                    var assetPlaceholder: PHObjectPlaceholder!
                                    PHPhotoLibrary.shared().performChanges({
                                        let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(string: filePath) as URL!)
                                        assetPlaceholder = assetRequest?.placeholderForCreatedAsset
                                    }, completionHandler: { (success, error) in
                                        if success {
                                            let localID = assetPlaceholder.localIdentifier
                                            let assetID = localID.replacingOccurrences(of: "/.*", with: "", options: NSString.CompareOptions.regularExpression, range: nil)
                                            let ext = "mp4"
                                            let assetURLStr = "assets-library://asset/asset.\(ext)?id=\(assetID)&ext=\(ext)"
                                            
                                            DispatchQueue.main.async {
                                                let video = Video(url: URL(string: assetURLStr)!)
                                                let content = VideoShareContent(video: video)
                                                do {
                                                    self.indicatorView.show(false)
                                                    try ShareDialog.show(from: self, content: content)
                                                } catch {
                                                    self.addAlert(title: nil, msg: "Please install Facebook".localized)
                                                    print(error.localizedDescription)
                                                }
                                            }
                                        } else {
                                            if let errorMessage = error?.localizedDescription {
                                                print(errorMessage)
                                            }
                                        }
                                    })
                                }
                                
                                
                            }
                        }
                    }
                }
            }
            
        case 2:
            print("share on instagram")
            self.indicatorView.show(true)
            
            DispatchQueue.main.async {
                if let url = URL(string: self.url!),
                    let urlData = NSData(contentsOf: url) {
                    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                    let filePath="\(documentsPath)/tempFile.mp4"
                    DispatchQueue.main.async {
                        urlData.write(toFile: filePath, atomically: true)
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                        }) { completed, error in
                            if completed {
                                
                                DispatchQueue.main.async {
                                    var assetPlaceholder: PHObjectPlaceholder!
                                    PHPhotoLibrary.shared().performChanges({
                                        let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(string: filePath) as URL!)
                                        assetPlaceholder = assetRequest?.placeholderForCreatedAsset
                                    }, completionHandler: { (success, error) in
                                        if success {
                                            let localID = assetPlaceholder.localIdentifier
                                            let assetID = localID.replacingOccurrences(of: "/.*", with: "", options: NSString.CompareOptions.regularExpression, range: nil)
                                            let ext = "mp4"
                                            let assetURLStr = "assets-library://asset/asset.\(ext)?id=\(assetID)&ext=\(ext)"
                                            
                                            DispatchQueue.main.async {
                                                let url = URL(string: assetURLStr)
                                                let instagramURL: NSURL = NSURL(string: "instagram://library?LocalIdentifier=\(assetURLStr)")!
                                                if UIApplication.shared.canOpenURL(instagramURL as URL) {
                                                    self.indicatorView.show(false)
                                                    UIApplication.shared.openURL(instagramURL as URL)
                                                } else {
                                                    print(error?.localizedDescription)
                                                }
                                            }
                                        } else {
                                            if let errorMessage = error?.localizedDescription {
                                                print(errorMessage)
                                            }
                                        }
                                    })
                                }
                                
                            }
                        }
                    }
                }
            }
            
        case 3:
            print("more share")
            self.indicatorView.show(true)
            DispatchQueue.main.async {
                if let url = URL(string: self.url!),
                    let urlData = NSData(contentsOf: url) {
                    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                    let filePath="\(documentsPath)/tempFile.mp4"
                    DispatchQueue.main.async {
                        urlData.write(toFile: filePath, atomically: true)
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                        }) { completed, error in
                            if completed {
                                DispatchQueue.main.async {
                                    var assetPlaceholder: PHObjectPlaceholder!
                                    PHPhotoLibrary.shared().performChanges({
                                        let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(string: filePath) as URL!)
                                        assetPlaceholder = assetRequest?.placeholderForCreatedAsset
                                    }, completionHandler: { (success, error) in
                                        if success {
                                            let localID = assetPlaceholder.localIdentifier
                                            let assetID = localID.replacingOccurrences(of: "/.*", with: "", options: NSString.CompareOptions.regularExpression, range: nil)
                                            let ext = "mp4"
                                            let assetURLStr = "assets-library://asset/asset.\(ext)?id=\(assetID)&ext=\(ext)"
                                            
                                            DispatchQueue.main.async {
                                                let videoURL = NSURL(fileURLWithPath: filePath)
                                                
                                                let activityViewController : UIActivityViewController = UIActivityViewController(
                                                    activityItems: [videoURL], applicationActivities: nil)
                                                activityViewController.popoverPresentationController?.sourceView = self.view
                                                activityViewController.popoverPresentationController?.sourceRect = self.view.frame
                                                
                                                activityViewController.excludedActivityTypes = [
                                                    UIActivityType.postToWeibo,
                                                    UIActivityType.print,
                                                    UIActivityType.assignToContact,
                                                    UIActivityType.saveToCameraRoll,
                                                    UIActivityType.addToReadingList,
                                                    UIActivityType.postToFlickr,
                                                    UIActivityType.postToVimeo,
                                                    UIActivityType.postToTencentWeibo,
                                                    UIActivityType.copyToPasteboard,
                                                    UIActivityType.saveToCameraRoll
                                                ]
                                                self.indicatorView.show(false)
                                                self.present(activityViewController, animated: true, completion: nil)
                                            }
                                            
                                        } else {
                                            if let errorMessage = error?.localizedDescription {
                                                print(errorMessage)
                                            }
                                        }
                                    })
                                }
                            }
                        }
                    }
                }
            }
        case 4:
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: TermsViewController.reuseIdentifier) as! TermsViewController
            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
            self.hidesBottomBarWhenPushed = false
        default:
            break
        }
    }
    
    @IBAction func actionBtnEdit() {
        guard let count = self.modifiedCount else { return }
        if count == 3 {
            self.addAlert(title: nil, msg: "Can't modify anymore".localized)
        } else {
            self.indicatorView.show(true)
            
            TemplateService.reEditTemplate(subId: self.id!) {
                TemplateService.getSubTemplateScenesInfo(
                    subId: self.id!,
                    success: { (template: Template) in
                        let editorVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: EditorViewController.reuseIdentifier) as! EditorViewController
                        editorVC.delegate = self
                        editorVC.template = template
                        editorVC.subId = self.id!
                        editorVC.modifiedCount = self.modifiedCount!
                        self.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(editorVC, animated: true)
                        self.hidesBottomBarWhenPushed = false
                        self.indicatorView.show(false)
                },
                    failure: { (errString) in
                        self.indicatorView.show(false)
                        self.addAlert(title: "", msg: errString)
                })
            }
        }
    }
    
    @IBAction func actionBtnComplete() {
        TemplateService.comfirmTemplate(subId: self.id!) {
            self.addAlert(title: nil, msg: "The video is confirmed".localized)
            self.reloadView(isComplete: true)
        }
    }
}

extension RenderingResultViewController: EditorDelegate {
    func editComplete() {
        self.closeViewController()
    }
}

extension UIApplication {
    
    class var topViewController: UIViewController? {
        return getTopViewController()
    }
    
    private class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return getTopViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}

extension Equatable {
    func share() {
        let activity = UIActivityViewController(activityItems: [self], applicationActivities: nil)
        UIApplication.topViewController?.present(activity, animated: true, completion: nil)
    }
}
