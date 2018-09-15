//
//  DetailViewController.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 3. 8..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import TagListView
import BMPlayer

class DetailViewController: ViewController{
//    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playerView: Player!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hashLabel: UILabel!
    @IBOutlet weak var durationButton: UIButton!
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var mediaTagListView: TagListView!
    @IBOutlet weak var childScrollView: UIScrollView!
    @IBOutlet weak var priceButton: UIButton!
    
    lazy var listViews: [TagListView] = [tagListView, mediaTagListView]
    var template: Template?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.shouldRotate = true // or false to disable rotation
        
        setUpViewController()
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
        self.playerView.isMuted(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)  
        self.playerView.pause(allowAutoPlay: true)
    }

    override func setUpViewController() {
        guard let template = self.template else {return}
        if let str = template.url,
            let url = URL(string: str) {
            
            BMPlayerConf.topBarShowInCase = BMPlayerTopBarShowCase.always
            self.playerView.setVideo(resource: BMPlayerResource(url: url))
        }
        
        self.playerView.backBlock = { [unowned self] (isFullScreen) in
            if isFullScreen {
                return
            } else {
                let _ = self.navigationController?.popViewController(animated: true)
            }
        }
        
        
        self.titleLabel.text = template.title
        self.hashLabel.text = template.hashString
        self.durationButton.setTitle(Util.format(template.duration), for: .normal)
        self.priceButton.setTitle("Needs Coupon".localized, for: .normal)
//        self.priceButton.setTitle(template.price == 0 ? "FREE" : "\(Int(template.price))$", for: .normal)
        let categorize = template.categorize
        let ratio = template.ratio
        let channel = template.channel
        self.tagListView.addTagsWithImage([ratio.getIconImage() : ratio.getDescription(),
                                           channel.getIconImage() : channel.getDescription(),
                                           categorize.getIconImage() : categorize.getDescription()])
        self.contentLabel.text = template.content
        
        let dic = [ #imageLiteral(resourceName: "VideoIcon") : "\(String(describing: template.videoNum)) "+"Video Clips".localized,
                    #imageLiteral(resourceName: "ImageIcon") : "\(String(describing: template.imageNum)) "+"Images".localized]
        self.mediaTagListView.addTagsWithImage(dic)
        
        
        for listView in listViews {
            listView.alignment = .left
            listView.textFont = UIFont.systemFont(ofSize: 14)
            listView.paddingY = 10
            listView.paddingX = 20
            listView.cornerRadius = (listView.tagViews[0].bounds.height) / 2
            listView.marginX = 10
            listView.marginY = 10
            listView.tagBackgroundColor = .white
            listView.backgroundColor = .clear
            listView.textColor = UIColor(hexString: "#30BBEE")
            listView.shadowColor = .black
            listView.shadowOffset = CGSize(width: 0, height: 5)
            listView.shadowRadius = 3
            listView.shadowOpacity = 0.3
            listView.enableRemoveButton = true
        }
        
        let likeButton = UIButton(type: .custom)
        likeButton.setImage(#imageLiteral(resourceName: "Like_UnFIlled"), for: .normal)
        likeButton.setImage(#imageLiteral(resourceName: "Like_Filled"), for: .selected)
        likeButton.addTarget(self, action: #selector(like(_:)), for: .touchUpInside)
        
        //MARK: Heart Check
        TemplateService.heartValidation(templateId: template.id) { message in
            if message == "like" {
                likeButton.isSelected = true
            } else {
                likeButton.isSelected = false
            }
        }

        self.navigationItem.setRightBarButton(UIBarButtonItem(customView: likeButton), animated: true)
        
        self.view.layoutIfNeeded()
    }
    
    @IBAction func touchUpBuy(_ sender: UIButton) {
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ReceiptViewController.reuseIdentifier) as! ReceiptViewController
        nextVC.template = self.template
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @objc func like(_ sender: UIButton) {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.6
        pulse.fromValue = 0.8
        pulse.toValue = 1.2
        pulse.autoreverses = true
        pulse.repeatCount = 1
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        sender.layer.add(pulse, forKey: nil)
        
     
        
        if sender.isSelected == true {
            TemplateService.deleteHeartTemplate(templateId: (template?.id)!) {
                sender.isSelected = false
            }
        } else {
            TemplateService.addHeartTemplate(templateId: (template?.id)!) {
                sender.isSelected = true
            }
        }
    }
}

