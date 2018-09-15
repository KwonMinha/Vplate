//
//  FilterViewController.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 2. 20..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit

class FilterViewController: ViewController {
    var delegate: HomeViewController?
    var slideDelegate: SlideMenuView?
    
    @IBOutlet weak var categorizeCollectionView: UICollectionView!
    @IBOutlet weak var ratioCollectionView: UICollectionView!
    @IBOutlet weak var channelCollectionView: UICollectionView!
    @IBOutlet weak var filterSettingButton: DesignableButton!
    var collectionViews: [UICollectionView] {
      return [self.categorizeCollectionView, self.ratioCollectionView, self.channelCollectionView]
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        for (index, collectionView) in collectionViews.enumerated() {
            guard let delegate = self.delegate else {return}
            switch index {
            case 0:
                let indexPath = IndexPath(row: delegate.selectedCategorizeIndex, section: 0)
                collectionView.selectItem(at: indexPath,
                                          animated: true,
                                          scrollPosition: .centeredHorizontally)
            case 1:
                let indexPath = IndexPath(row: delegate.selectedRatioIndex, section: 0)
                collectionView.selectItem(at: indexPath,
                                          animated: true,
                                          scrollPosition: .centeredHorizontally)
            case 2:
                let indexPath = IndexPath(row: delegate.selectedChannelIndex, section: 0)
                collectionView.selectItem(at: indexPath,
                                          animated: true,
                                          scrollPosition: .centeredHorizontally)
            default: break
            }
        }
    }
    
    override func setUpViewController() {
        for collectionView in collectionViews {
            collectionView.setUp(target: self, cell: FilterCollectionViewCell.self)
            collectionView.showsHorizontalScrollIndicator = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for collectionView in collectionViews {
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.minimumLineSpacing = 10
                layout.itemSize = CGSize(width: collectionView.frame.height, height:collectionView.frame.height)
                layout.scrollDirection = .horizontal
                layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
                layout.invalidateLayout()
            }
        }
        filterSettingButton.createGradientLayer(startColor: UIColor.DefaultColor.skyBlue,
                                                endColor: UIColor.DefaultColor.lightGreen,
                                                startPoint: CGPoint(x: 0, y: 0),
                                                endPoint: CGPoint(x: 1, y: 0))
    }
    
    @IBAction func touchUpDecideFilter(_ sender: UIButton) {
        self.slideDelegate?.isOpened = false
        if let categorizeIndex = categorizeCollectionView.indexPathsForSelectedItems?.first?.row,
            let ratioIndex = ratioCollectionView.indexPathsForSelectedItems?.first?.row,
            let channelIndex = channelCollectionView.indexPathsForSelectedItems?.first?.row {
            self.delegate?.updateFilter(categorize: categorizeIndex,
                                        ratio: ratioIndex,
                                        channel: channelIndex)
        }
    }
}

extension FilterViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case categorizeCollectionView:
            return Categorize.count
        case ratioCollectionView:
            return Ratio.count
        case channelCollectionView:
            return Channel.count
        default :
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FilterCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        switch collectionView {
        case categorizeCollectionView:
            guard let categorize = Categorize(rawValue: indexPath.row) else { return cell }
            cell.titleLabel.text = categorize.getDescription()
            cell.iconImageView.image = categorize.getIconImage().tinted(with: UIColor(red: 203/255, green: 203/255, blue: 203/255, alpha: 1))
        case ratioCollectionView:
            guard let ratio = Ratio(rawValue: indexPath.row) else { return cell }
            cell.titleLabel.text = ratio.getDescription()
            cell.iconImageView.image = ratio.getIconImage().tinted(with: UIColor(red: 203/255, green: 203/255, blue: 203/255, alpha: 1))
        case channelCollectionView:
            guard let channel = Channel(rawValue: indexPath.row) else { return cell }
            cell.titleLabel.text = channel.getDescription()
            cell.iconImageView.image = channel.getIconImage().tinted(with: UIColor(red: 203/255, green: 203/255, blue: 203/255, alpha: 1))
        default :
            break
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 3
        
        return CGSize(width: width, height: collectionView.frame.height)
    }
}


