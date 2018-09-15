//
//  LikeViewController.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 4. 2..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import SnapKit
import SwiftyJSON
import ObjectMapper

class FavoriteViewController: ViewController {
    @IBOutlet weak var tableView: PullRefreshTableView!
    
    var templates: [FavoriteTemplate]?
    var displayTemplates:[FavoriteTemplate] = []
    
    var detailTemplates: Template?
    //var displayTemplates: [Template] = []
    
    let fullIndicatorView = FullIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViewController()
        getTemplates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getTemplates()
    }
    
    override func setUpViewController() {
        self.tableView.setUp(target: self, cell: LikeTableViewCell.self)
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.reloadData()
    }
    
    func getTemplates(completion: (()->())? = nil) {
        fetchTemplates { (templates) in
            self.templates = templates
            self.displayTemplates = templates!
            self.tableView.reloadData()
            if let completion = completion {
                completion()
            }
            self.tableView.endRefresh()
        }
    }
    
    func fetchTemplates (completion: @escaping ([FavoriteTemplate]?)->()) {
        TemplateService.getFavoriteTemplateData(url: "likes") { (result) in
            switch result {
            case .Success(let response):
                guard let data = response as? Data else {return}
                let dataJSON = JSON(data)
                guard let templates = Mapper<FavoriteTemplate>().mapArray(JSONObject: dataJSON["likes"].object) else {return}
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

extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource, PullRefreshTableViewDelegate {
    func pullRefreshTableView(tableView: PullRefreshTableView, refreshControl: UIRefreshControl) {
        getTemplates {
            //self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LikeTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.info = displayTemplates[indexPath.row]
        cell.setTransparentSelect()
        cell.likeButton.addTarget(self, action: #selector(touchUpLikeButton(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: DetailViewController.reuseIdentifier) as! DetailViewController
        //        nextVC.template = displayTemplates[indexPath.row]
        //        DispatchQueue.main.async {
        //            self.hidesBottomBarWhenPushed = true
        //            self.navigationController?.pushViewController(nextVC, animated: true)
        //            self.hidesBottomBarWhenPushed = false
        //        }
        
        
        
        //        HomeService.getTemplateData(url: "templates") { (result) in
        //            switch result {
        //            case .Success(let response):
        //                guard let data = response as? Data else {return}
        //                let dataJSON = JSON(data)
        //                guard let templates = Mapper<Template>().mapArray(JSONObject: dataJSON["templates"].object) else {return}
        //                completion(templates)
        //            case .Failure(let failureCode):
        //                self.view.makeToast("Network Failure Code : \(failureCode)")
        //                completion(nil)
        //            case .FailDescription(let err):
        //                self.view.makeToast(err)
        //                completion(nil)
        //            }
        //        }
        
        TemplateService.getTemplateDetailData(templateId: displayTemplates[indexPath.row].originTemplate.id) { (result) in
            switch result {
            case .Success(let response):
                guard let data = response as? Data else {return}
                let dataJSON = JSON(data)
                guard let templates = Mapper<Template>().map(JSONObject: dataJSON["template"].object) else {return}
                self.detailTemplates = templates
                let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: DetailViewController.reuseIdentifier) as! DetailViewController
                nextVC.template = self.detailTemplates
                DispatchQueue.main.async {
                    self.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(nextVC, animated: true)
                    self.hidesBottomBarWhenPushed = false
                }
                
                
            case .Failure(let failureCode):
                self.view.makeToast("Network Failure Code : \(failureCode)")
            //completion(nil)
            case .FailDescription(let err):
                self.view.makeToast(err)
                //completion(nil)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayTemplates.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / 5
    }
    
    @objc func touchUpLikeButton(_ sender: UIButton) {
        if let cell = sender.superview?.superview as? LikeTableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            //            self.displayTemplates[indexPath.row].setLiked(liked: false)
            
            //heart delete networking
            TemplateService.deleteHeartTemplate(templateId: displayTemplates[indexPath.row].originTemplate.id) {
                self.displayTemplates.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
}
