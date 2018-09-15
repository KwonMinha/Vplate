//
//  ImageFilterViewController.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 4. 30..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import CoreImage

@objc protocol ImageFilterDelegate {
    func done(viewController: UIViewController, filtered: UIImage)
}


enum ImageFilter {
    case normal, chrome, fade, instant, noir, process, tonal, transfer, sepia
    
    func getDescription() -> String {
        switch self {
        case .normal: return "Noraml"
        case .chrome: return "Chrome"
        case .fade: return "Fade"
        case .instant: return "Instant"
        case .noir: return "Noir"
        case .process: return "Process"
        case .tonal: return "Tonal"
        case .transfer: return "Transfer"
        case .sepia: return "Sepia"
        }
    }
    
    func getFilterName() -> String {
        switch self {
        case .normal: return ""
        case .chrome: return "CIPhotoEffectChrome"
        case .fade: return "CIPhotoEffectFade"
        case .instant: return "CIPhotoEffectInstant"
        case .noir: return "CIPhotoEffectNoir"
        case .process: return "CIPhotoEffectProcess"
        case .tonal: return "CIPhotoEffectTonal"
        case .transfer: return "CIPhotoEffectTransfer"
        case .sepia: return "CISepiaTone"
        }
    }
    
    func getImage() -> UIImage {
        switch self {
        case .normal: return #imageLiteral(resourceName: "Normal")
        case .chrome: return #imageLiteral(resourceName: "Chrome")
        case .fade: return #imageLiteral(resourceName: "Fade")
        case .instant: return #imageLiteral(resourceName: "Instant")
        case .noir: return #imageLiteral(resourceName: "Noir")
        case .process: return #imageLiteral(resourceName: "Process")
        case .tonal: return #imageLiteral(resourceName: "Tonal")
        case .transfer: return #imageLiteral(resourceName: "Transfer")
        case .sepia: return #imageLiteral(resourceName: "Sepia")
        }
    }
    
    static func getFilterList() -> [ImageFilter] {
        var filterList = [ImageFilter]()
        filterList.append(.normal)
        filterList.append(.chrome)
        filterList.append(.fade)
        filterList.append(.instant)
        filterList.append(.noir)
        filterList.append(.process)
        filterList.append(.tonal)
        filterList.append(.transfer)
        filterList.append(.sepia)
        return filterList
    }
}
class ImageFilterViewController: ViewController {
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    var originalImage: UIImage?
    var delegate: ImageFilterDelegate?
    var filters: [ImageFilter] = ImageFilter.getFilterList()
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func setUpViewController() {
        self.title = "Filter".localized
        guard let originalImage = originalImage else {return}
        self.thumbnail.image = originalImage
        self.collectionView.setUp(target: self, cell: ImageFilterCollectionViewCell.self)
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.done, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "Done".localized, style: UIBarButtonItemStyle.done, target: self, action: #selector(donenTapped))
        self.navigationItem.setRightBarButton(doneButton, animated: true)
    }
    
    @objc func donenTapped() {
        if let image = self.thumbnail.image {
            delegate?.done(viewController: self, filtered: image)
        }
    }
}

extension UIImage {
    func filterEffect(selected: String) -> UIImage {
        // convert UIImage to CIImage
        let inputCIImage = CIImage(image: self)!
    
        let filter = CIFilter(name: selected)!
        filter.setDefaults()
        filter.setValue(inputCIImage, forKey: kCIInputImageKey)
        let outputImage = filter.outputImage!
        let ciContext = CIContext()
        let cgImage = ciContext.createCGImage(outputImage,
                                              from: outputImage.extent)
        return UIImage(cgImage: cgImage!)
    }
}

extension ImageFilterViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImageFilterCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        let filter = filters[indexPath.row]
        cell.filter = filter
        cell.thumbnail.image = filter.getImage()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = collectionView.frame.height
        return CGSize(width: itemSize , height: itemSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let originalImage = self.originalImage else {return}
        let filter = self.filters[indexPath.row]
        DispatchQueue.main.async {
            switch filter{
            case .normal:
                self.thumbnail.image = originalImage
            default:
                self.thumbnail.image = originalImage.filterEffect(selected: filter.getFilterName())
            }
        }
    }
}
