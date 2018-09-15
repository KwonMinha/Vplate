//
//  HomeViewController.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 2. 20..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import SwiftyJSON
import ObjectMapper

class HomeViewController: ViewController {
    var slideInMenuView = SlideMenuView()
    var selectedCategorizeIndex: Int = 0
    var selectedRatioIndex: Int = 0
    var selectedChannelIndex: Int = 0
    var templates: [Template]?
    var displayTemplates: [Template] = []
    var slideButton = UIButton(type: .custom)
    let indicatorView = FullIndicatorView()
    @IBOutlet weak var tableView: PullRefreshTableView!
    
    var url: String?
    
    let userdefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViewController()
        getTemplates(indicator: self.indicatorView)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIApplication.shared.applicationIconBadgeNumber != 0 {
            self.tabBarController?.tabBar.items?[2].badgeValue = String(UIApplication.shared.applicationIconBadgeNumber)
        }
    }
    
    override func setUpViewController() {
        self.tableView.setUp(target: self, cell: HomeTableViewCell.self)
        
        let imageView = UIImageView(image:#imageLiteral(resourceName: "Logo"))
        self.navigationItem.titleView = imageView
        
        self.updateFilter(categorize: 0, ratio: 0, channel: 0)
        
        slideButton.setImage(#imageLiteral(resourceName: "Filter"), for: .normal)
        slideButton.setImage(#imageLiteral(resourceName: "Close"), for: .selected)
        slideButton.addTarget(self, action: #selector(controlSlideView(_:)), for: .touchUpInside)
        self.navigationItem.setRightBarButton(UIBarButtonItem(customView: slideButton), animated: true)
        
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
    }
    
    
    @objc func controlSlideView(_ sender: UIButton) {
        
        self.slideInMenuView.delegate = self
        switch self.slideInMenuView.isOpened {
        case true:
            self.slideInMenuView.isOpened = false
        case false:
            self.slideInMenuView.setUp()
            self.slideInMenuView.isOpened = true
        }
    }
    
    func updateFilter(categorize: Int, ratio: Int, channel: Int) {
        self.selectedCategorizeIndex = categorize
        self.selectedRatioIndex = ratio
        self.selectedChannelIndex = channel
        guard let templates = self.templates else {return}
        
        let selectCategorize = Categorize(rawValue: categorize)
        let selectRatio = Ratio(rawValue: ratio)
        let selectChannel = Channel(rawValue: channel)
        
        self.displayTemplates.removeAll()
        for template in templates {
            if((template.categorize == selectCategorize || selectCategorize == .all) &&
                (template.ratio == selectRatio || selectRatio == .all) &&
                (template.channel == selectChannel || selectChannel == .all)) {
                self.displayTemplates.append(template)
            }
        }
        self.tableView.reloadData()
    }
    
    func reloadAndScrollUpTableView() {
        UIView.transition(with: self.tableView,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.tableView.reloadData()
        }) { (value) in
            let indexPath = NSIndexPath(row: NSNotFound, section: 0)
            self.tableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
        }
    }
    
    func getTemplates(indicator: FullIndicatorView? = nil, completion: (()->())? = nil) {
        indicator?.show(true)
        fetchTemplates { (templates) in
            if let templates = templates {
                self.templates = templates
                self.displayTemplates = templates
                self.tableView.reloadData()
                if let completion = completion {
                    completion()
                }
            }
            indicator?.show(false)
            self.tableView.endRefresh()
        }
    }
    
    func fetchTemplates (completion: @escaping ([Template]?)->()) {
        let langStr = Locale.current.languageCode // 사용자 설정 언어정보

        if langStr == "ko" {
            self.url = "templates"
        } else {
            self.url = "engtemplates"
        }
        
        HomeService.getTemplateData(url: "templates") { (result) in
            switch result {
            case .Success(let response):
                
                guard let data = response as? Data else {return}
                let dataJSON = JSON(data)
                guard let templates = Mapper<Template>().mapArray(JSONObject: dataJSON["templates"].object) else {return}
                completion(templates)
            case .Failure(let failureCode):
                self.view.makeToast("Network Failure Code : \(failureCode)")
                completion(nil)
            case .FailDescription(let err):
                self.view.makeToast(err)
                completion(nil)
            }
        }
    }
}


extension HomeViewController: UITableViewDelegate, UITableViewDataSource, PullRefreshTableViewDelegate {
    func pullRefreshTableView(tableView: PullRefreshTableView, refreshControl: UIRefreshControl) {
        getTemplates {
            self.updateFilter(categorize: self.selectedCategorizeIndex,
                              ratio: self.selectedRatioIndex,
                              channel: self.selectedChannelIndex)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayTemplates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HomeTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.info = displayTemplates[indexPath.row]
        cell.setTransparentSelect()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let width = self.tableView.frame.width
        return width * 9/16 + 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: DetailViewController.reuseIdentifier) as! DetailViewController
        nextVC.template = displayTemplates[indexPath.row]
        DispatchQueue.main.async {
            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(nextVC, animated: true)
            self.hidesBottomBarWhenPushed = false
        }
    }
}

extension HomeViewController: SlideMenuDelegate {
    func slideMenu(state: Bool) {
        slideButton.isSelected = state
    }
}
