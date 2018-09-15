//
//  PhotoPickerWithNavigationViewController.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 3. 28..
//  Copyright © 2018년 이광용. All rights reserved.
//

import Foundation
import TLPhotoPicker
import CropViewController
import Photos

protocol PopToEditorVCDelegate {
    func popAction(imageURL: String?, videoURL: String?)
}

class PhotoPickerWithNavigationViewController: TLPhotosPickerViewController, CropViewControllerDelegate, PopToEditorVCDelegate, ImageFilterDelegate{
    var selectedSegmentType: ClipType?
    var selectedClip: Clip?
    var fileName: String?
    
    let indicatorView = FullIndicatorView()
    
    override func makeUI() {
        super.makeUI()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        self.customNavItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .stop, target: nil, action: #selector(customAction))
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.DefaultColor.skyBlue
    }
    @objc func customAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func doneButtonTap() {
        if let asset = self.selectedAssets.first,
            let type = self.selectedSegmentType,
            let fileName = self.fileName,
            let selectedClip = self.selectedClip {
            switch type {
            case .video:
                guard let phAsset = asset.phAsset else {return}
                let trimVC =  TrimViewController.init(nibName: "TrimViewController", bundle: nil)
                trimVC.delegate = self
                trimVC.fileName = fileName + ".mp4"
                let duration = selectedClip.time
                trimVC.duration = Double(duration)
                PHImageManager.default().requestAVAsset(forVideo: phAsset, options: nil, resultHandler: { (avAsset, _, _) in
                    trimVC.asset = avAsset
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(trimVC, animated: true)
                    }
                })
            case .image:
                switch asset.type {
                case .photo, .livePhoto:
                    if let img = asset.fullResolutionImage {
                        self.navigateToCropController(image: img)
                    }
                    else {
                        indicatorView.show(true)
                        asset.cloudImageDownload(progressBlock: { (progressValue) in
                            let value = Int( progressValue * 100 )
                            DispatchQueue.main.async {
                                self.indicatorView.set(value: value)
                            }
                        }, completionBlock: { (img) in
                            self.indicatorView.show(false)
                            if let img = img {
                                self.navigateToCropController(image: img)   
                            }
                        })
                        
                    }
                case .video:
                    break
                }
                
            case .text: break
            }
        }
    }
    
    func navigateToCropController(image: UIImage) {
        let cropController = CropViewController(croppingStyle: CropViewCroppingStyle.default, image: image)
        cropController.delegate = self
        guard let clip = self.selectedClip else {return}
        cropController.customAspectRatio = CGSize(width: clip.width, height: clip.height)
        cropController.rotateButtonsHidden = true
        cropController.aspectRatioLockEnabled = true
        cropController.aspectRatioPickerButtonHidden = true
        cropController.resetAspectRatioEnabled = false
        cropController.doneButtonTitle = "Next".localized
        cropController.cancelButtonTitle = ""
        cropController.toolbar.cancelTextButton.setImage(#imageLiteral(resourceName: "Back-1"), for: .normal)
        cropController.toolbar.cancelTextButton.tintColor = UIColor.DefaultColor.skyBlue
        cropController.toolbar.cancelTextButton.setTitleColor(UIColor.DefaultColor.skyBlue, for: .normal)
        cropController.toolbar.doneTextButton.setTitleColor(UIColor.DefaultColor.skyBlue, for: .normal)
        cropController.toolbarPosition = .top
        self.navigationController?.pushViewController(cropController, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        guard let clip = self.selectedClip else {return}
        let deviceWidth = UIScreen.main.bounds.size.width
        let resizeWidth = deviceWidth * 2
        let resizeHeight = resizeWidth * (CGFloat(clip.height) / CGFloat(clip.width))
        let resizeImage = self.resizeImage(image: image, targetSize: CGSize.init(width: clip.width, height: clip.height))
        let nextVC = ImageFilterViewController.init(nibName: "ImageFilterViewController", bundle: nil)
        nextVC.originalImage = resizeImage
        nextVC.delegate = self
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize.init(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize.init(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        let rect = CGRect.init(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let resizeImage = newImage else {
            return image
        }
        return resizeImage
    }
    
    func done(viewController: UIViewController, filtered: UIImage) {
        viewController.navigationController?.popToRootViewController(animated: true)
        guard let fileName = self.fileName else {return}
        if let imageURL = saveImage(image: filtered, name: fileName) {
            popAction(imageURL: imageURL, videoURL: nil)
        }
    }
    
    func saveImage(image:UIImage, name:String) -> String? {
        let selectedImage: UIImage = image
        guard let data = UIImagePNGRepresentation(selectedImage) else {return nil}
        
        if let folderURL = URL.createFolder(folderName: "VPALTE") {
            let filePath = folderURL.appendingPathComponent(name + ".png", isDirectory: false)
            do {
                try data.write(to: filePath, options: .atomic)
                return filePath.absoluteString
            }
            catch(let err) {
                debugPrint(err.localizedDescription)
            }
        }
        return nil
    }
    
    func popAction(imageURL: String?, videoURL: String?) {
        guard let selectedClip = self.selectedClip else {return}
        debugPrint(imageURL)
        if(imageURL != nil) {
            selectedClip.imageUrl = imageURL!
        } else if(videoURL != nil) {
            selectedClip.videoUrl = videoURL!
        }
        self.dismiss(animated: true, completion: nil) //popViewController(animated: true)
    }
}
extension URL {
    static func createFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = documentDirectory.appendingPathComponent(folderName)
            if !fileManager.fileExists(atPath: filePath.path) {
                do {
                    try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error.localizedDescription)
                    
                    return nil
                }
            }
            
            return filePath
        } else {
            return nil
        }
    }
}
