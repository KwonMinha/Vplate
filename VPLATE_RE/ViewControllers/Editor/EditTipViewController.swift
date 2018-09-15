//
//  EditTipViewController.swift
//  VPLATE_RE
//
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import BMPlayer
import Kingfisher

class EditTipViewController: UIViewController {
    @IBOutlet weak var editTipTableView: UITableView!
    
    var editTips: [EditTipData] = [EditTipData]()
    
    var tipId: String?

    var maintitle: String?
    var subTitle: String?
    var videoUrl: String?
    
    var editTip: EditTip?
    
     let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Editing Tips".localized
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        
        editTipTableView.delegate = self
        editTipTableView.dataSource = self
        editTipInit()
        editTipTableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.tabBarController?.tabBar.isHidden = false
        }
    }
    
    func editTipInit() {
        TemplateService.editTipInit(tipId: self.tipId!) { (editTip, editTipData) in
            self.editTip = editTip
            self.editTips = editTipData
            self.videoUrl = editTip.videoUrl
            self.maintitle = editTip.title
            self.subTitle = editTip.subtitle
            self.editTipTableView.reloadData()
        }
    }

}

extension EditTipViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return editTips.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditTipVideoTableViewCell", for: indexPath) as! EditTipVideoTableViewCell
            
            BMPlayerConf.topBarShowInCase = BMPlayerTopBarShowCase.horizantalOnly

            if editTip?.videoUrl == nil {
                
            } else {
                cell.player.setVideo(resource: BMPlayerResource(url: URL(string: (editTip?.videoUrl)!)!))
            }
            
            cell.labelTitle.text = self.editTip?.title
            cell.labelSubTitle.text = self.editTip?.subtitle

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditTipImageTableViewCell", for: indexPath) as! EditTipImageTableViewCell
            cell.imageViewTip.kf.setImage(with: URL(string: editTips[indexPath.row].imageUrl!))
            cell.labelContent.text = editTips[indexPath.row].content
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
