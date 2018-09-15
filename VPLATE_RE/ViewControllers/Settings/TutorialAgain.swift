////
////  TutorialAgain.swift
////  VPLATE_RE
////
////  Copyright © 2018년 이광용. All rights reserved.
////
//
//import SnapKit
//import UIKit
//
//extension TutorialAgainViewController {
//    func setUpTutorialView() {
//        guard let keyWindow = UIApplication.shared.keyWindow else {return}
//        tutorialView.frame = keyWindow.frame
//        keyWindow.addSubview(self.tutorialView)
//        tutorialView.backgroundColor =  .clear
//        setNextButton()
//        setFirstTutorial()
//    }
//    
//    @objc func touchUpNextButton(_ sender: UIButton) {
//        tutorialView.reset()
//        switch sender.tag {
//        case 1001:
//            setSecondTutorial()
//        case 1002:
//            setThirdTutorial()
//        case 1003:
//            setForthTutorial()
//        case 1004:
//            tutorialView.removeFromSuperview()
//        default:
//            break
//        }
//        sender.tag += 1
//    }
//    
//    func setNextButton() {
//        fingerImageView.image = #imageLiteral(resourceName: "FingerTip")
//        fingerImageView.contentMode = .scaleAspectFill
//        tutorialView.addSubview(nextButton)
//        nextButton.tag = 1001
//        nextButton.setTitle("Next".localized, for: .normal)
//        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
//        nextButton.setTitleColor(UIColor(red: 228.0 / 255.0, green: 64.0 / 255.0, blue: 45.0 / 255.0, alpha: 1.0),
//                                 for: .normal)
//        nextButton.backgroundColor = .white
//        nextButton.cornerRadius = 18
//        nextButton.snp.makeConstraints { (make) in
//            make.height.equalTo(36)
//            make.bottom.equalTo(tutorialView.snp.bottom).inset(15)
//            make.centerX.equalToSuperview()
//            make.width.equalTo(tutorialView.snp.width).multipliedBy(0.55)
//        }
//        nextButton.addTarget(self, action: #selector(touchUpNextButton(_:)), for: .touchUpInside)
//    }
//    func setFirstTutorial() {
//        tutorialView.makeHole(paths: [cvSceneThumbnailLarge.getPath(),
//                                      sceneCollectionView.getPath(),
//                                      UIBezierPath(ovalIn: menualButton.frame)])
//        tutorialView.addSubview(imageLabel)
//        imageLabel.text = "Sample Image".localized
//        imageLabel.tag = 1000
//        imageLabel.numberOfLines = 0
//        imageLabel.textColor = .white
//        imageLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
//        imageLabel.textAlignment = .center
//        imageLabel.backgroundColor = UIColor(red: 61.0 / 255.0, green: 194.0 / 255.0, blue: 234.0 / 255.0, alpha: 0.4)
//        imageLabel.snp.makeConstraints { (make) in
//            make.edges.equalTo(self.cvSceneThumbnailLarge.snp.edges)
//        }
//        
//        tutorialView.addSubview(fingerImageView)
//        let width = 50
//        let leadingMargin = (self.sceneCollectionView.frame.height * 16/9/2) - CGFloat(width/2)
//        fingerImageView.snp.makeConstraints { (make) in
//            make.top.equalTo(self.sceneCollectionView.snp.top).inset(20)
//            make.leading.equalTo(self.sceneCollectionView.snp.leading).inset(leadingMargin)
//            make.width.height.equalTo(width)
//        }
//        
//        let sceneCollectionLabel = UILabel()
//        tutorialView.addSubview(sceneCollectionLabel)
//        sceneCollectionLabel.text = "First Frame Tutorial".localized
//        sceneCollectionLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
//        sceneCollectionLabel.numberOfLines = 0
//        sceneCollectionLabel.textColor = .white
//        sceneCollectionLabel.textAlignment = .center
//        sceneCollectionLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(fingerImageView.snp.bottom).inset(-10)
//            make.leading.equalTo(tutorialView.snp.leading).inset(10)
//            make.trailing.equalTo(tutorialView.snp.trailing).inset(10)
//        }
//        
//        let manualLabel = UILabel()
//        tutorialView.addSubview(manualLabel)
//        manualLabel.text = "Manual Tutorial".localized
//        manualLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
//        manualLabel.numberOfLines = 2
//        manualLabel.textColor = .white
//        manualLabel.textAlignment = .center
//        manualLabel.snp.makeConstraints { (make) in
//            make.bottom.equalTo(self.menualButton.snp.top)
//            make.trailing.equalTo(self.menualButton.snp.trailing)
//        }
//        menualButton.borderColor = UIColor.DefaultColor.skyBlue
//        menualButton.borderWidth = 5
//    }
//    
//    func setSecondTutorial(){
//        if let frame = customizableSegmentedControl.superview?.convert(customizableSegmentedControl.frame, to: nil) {
//            tutorialView.makeHole(paths: [sceneCollectionView.frame.getPath(),
//                                          frame.getPath()])
//        }
//        
//        let width = 50
//        let leadingMargin = (self.sceneCollectionView.frame.height * 16/9 * 3/2) - CGFloat(width/2)
//        UIView.animate(withDuration: 0.5) {
//            self.fingerImageView.snp.updateConstraints { (make) in
//                make.leading.equalTo(self.sceneCollectionView.snp.leading).inset(leadingMargin)
//            }
//            self.tutorialView.layoutIfNeeded()
//        }
//        
//        imageLabel.text = "Next Frame Tutorial".localized
//        imageLabel.backgroundColor = .clear
//        menualButton.borderWidth = 0
//    }
//    func setThirdTutorial() {
//        guard let barButton = self.navigationItem.rightBarButtonItem,
//            let barButtonView = barButton.value(forKey: "view") as? UIView,
//            var barButtonViewFrame = barButtonView.superview?.convert(barButtonView.frame, to: nil),
//            let segmentFrame = customizableSegmentedControl.superview?.convert(customizableSegmentedControl.frame, to: nil)
//            else {return}
//        barButtonViewFrame = CGRect(x: barButtonViewFrame.minX - 5,
//                                    y: barButtonViewFrame.minY,
//                                    width: barButtonViewFrame.width,
//                                    height: barButtonViewFrame.height)
//        tutorialView.makeHole(paths: [sceneCollectionView.frame.getPath(),
//                                      segmentFrame.getPath(),
//                                      UIBezierPath(ovalIn: barButtonViewFrame)])
//        imageLabel.text = "Completion Tutorial".localized
//        UIView.animate(withDuration: 0.5) {
//            self.fingerImageView.snp.remakeConstraints { (make) in
//                make.top.equalTo(barButtonView.snp.bottom)
//                make.trailing.equalTo(barButtonView.snp.trailing)
//                make.width.height.equalTo(50)
//            }
//            self.tutorialView.layoutIfNeeded()
//        }
//        imageLabel.backgroundColor = .clear
//    }
//    func setForthTutorial() {
//        fingerImageView.removeFromSuperview()
//        tutorialView.componentView.removeFromSuperview()
//        tutorialView.createGradientLayer()
//        imageLabel.text = "Done Tutorial".localized
//        nextButton.setTitle("Done".localized, for: .normal)
//        nextButton.snp.remakeConstraints { (make) in
//            make.height.equalTo(36)
//            make.bottom.equalTo(tutorialView.snp.bottom).inset(15)
//            make.trailing.equalTo(tutorialView.snp.trailing).inset(18)
//            make.width.equalTo(100)
//        }
//        let alienImageView = UIImageView(image: #imageLiteral(resourceName: "Alien"))
//        tutorialView.addSubview(alienImageView)
//        alienImageView.contentMode = .scaleAspectFit
//        alienImageView.snp.makeConstraints { (make) in
//            make.top.equalTo(imageLabel.snp.bottom).inset(48)
//            make.bottom.equalTo(nextButton.snp.top).inset(17)
//            make.centerX.equalTo(tutorialView.snp.centerX)
//        }
//    }
//}
//
