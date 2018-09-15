//
//  MyTemplateViewController.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 4. 2..
//  Copyright © 2018년 이광용. All rights reserved.
//
import UIKit
import SwiftyJSON
import ObjectMapper

class MyTemplateViewController: ViewController {
    
    @IBOutlet weak var tableView: PullRefreshTableView!
    @IBOutlet weak var segmentControl: CustomizableSegmentedControl!
    
    var templates: [MyTemplate]?
    var displayTemplates: [MyTemplate] = []
    
    let fullIndicatorView = FullIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //let badgeValue = UserDefaults.standard.string(forKey: "badgeCount")

        setUpViewController()
        getTemplates()
        
        
    }

    override func viewDidDisappear(_ animated: Bool) {
        segmentControl.selectedSegmentIndex = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIApplication.shared.applicationIconBadgeNumber != 0 {
            self.tabBarController?.tabBar.items?[2].badgeValue = String(UIApplication.shared.applicationIconBadgeNumber)
            self.segmentControl.setBadge(index: 3, value: UIApplication.shared.applicationIconBadgeNumber)
        }
        segmentControl.selectedSegmentIndex = 0
        getTemplates()
    }
    
    override func setUpViewController() {
        self.tableView.setUp(target: self, cell: MyTemplateTableViewCell.self)
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.reloadData()
    }
    
//    func setBadge(increase: Bool) {
//        var completeTemplate: [MyTemplate] = []
//
//        completeTemplate = self.templates!.filter({$0.state == TemplateState.complete})
//
//        //let value = self.tabBarController?.tabBar.items?[2].badgeValue
//        //        if var count = Int(value ?? "0") {
//        //            count += (increase ? 1:(count==0 ? 0 :-1))
//        //            self.tabBarController?.tabBar.items?[2].badgeValue = String(describing: count)
//        //            self.segmentControl.setBadge(index: 3, value: count)
//        //        }
//
//        let badgeValue = UserDefaults.standard.string(forKey: "badgeCount")
//
//        self.segmentControl.setBadge(index: 3, value: Int(badgeValue!)!)
//
//        if completeTemplate.count != 0 {
//            let count = completeTemplate.count
//            self.tabBarController?.tabBar.items?[2].badgeValue = String(describing: count)
//            self.segmentControl.setBadge(index: 3, value: count)
//        }
//    }
    
    func updateDatasource(index: Int) {
        switch index {
        case 0:
            self.displayTemplates = self.templates!
        case 1:
            self.displayTemplates = self.templates!.filter({$0.state == TemplateState.progress || $0.state == TemplateState.modified})
        case 2:
            self.displayTemplates = self.templates!.filter({$0.state == TemplateState.render})
        case 3:
            self.displayTemplates = self.templates!.filter({$0.state == TemplateState.confirmed || $0.state == TemplateState.complete})
        default:
            self.displayTemplates = []
        }
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
    
    func fetchTemplates (completion: @escaping ([MyTemplate]?)->()) {
        TemplateService.getMyTemplateData(url: "subtemplates") { (result) in
            switch result {
            case .Success(let response):
                guard let data = response as? Data else {return}
                let dataJSON = JSON(data)
                guard let templates = Mapper<MyTemplate>().mapArray(JSONObject: dataJSON["subTemplates"].object) else {return}
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



extension MyTemplateViewController: UITableViewDelegate, UITableViewDataSource, PullRefreshTableViewDelegate {
    func pullRefreshTableView(tableView: PullRefreshTableView, refreshControl: UIRefreshControl) {
        getTemplates {
            self.updateDatasource(index: self.segmentControl.selectedSegmentIndex)
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayTemplates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyTemplateTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        
        cell.info = displayTemplates[indexPath.row]
        cell.setTransparentSelect()
        cell.updateState(state: (cell.info?.state)!)
        cell.contentState(state: (cell.info?.state)!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let state = displayTemplates[indexPath.row].state
        
        if state == TemplateState.complete || state == TemplateState.confirmed {
            let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: RenderingResultViewController.reuseIdentifier) as! RenderingResultViewController
            
            nextVC.id = displayTemplates[indexPath.row].id
            nextVC.state = displayTemplates[indexPath.row].state
            nextVC.url = displayTemplates[indexPath.row].url
            nextVC.modifiedCount = displayTemplates[indexPath.row].timesModified
            //nextVC.template = displayTemplates[indexPath.row]
            
            DispatchQueue.main.async {
                self.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(nextVC, animated: true)
                self.hidesBottomBarWhenPushed = false
            }
        } else if state == TemplateState.progress || state == TemplateState.modified {
            self.fullIndicatorView.show(true)
            
            TemplateService.getSubTemplateScenesInfo(
                subId: displayTemplates[indexPath.row].id,
                success: { (template: Template) in
                    let editorVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: EditorViewController.reuseIdentifier) as! EditorViewController
                    editorVC.delegate = self
                    editorVC.template = template
                    editorVC.subId = self.displayTemplates[indexPath.row].id
                    
                    if state == TemplateState.modified {
                        editorVC.modifiedCount = self.displayTemplates[indexPath.row].timesModified
                    } else {
                        editorVC.modifiedCount = 0
                    }
                    self.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(editorVC, animated: true)
                    self.hidesBottomBarWhenPushed = false
                    self.fullIndicatorView.show(false)
            },
                failure: { (errString) in
                    self.fullIndicatorView.show(false)
                    self.addAlert(title: "", msg: errString)
            })
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
}

extension MyTemplateViewController: CustomizableSegmentedControlDelegate {
    
    
    func valueChanged(_ sender: CustomizableSegmentedControl) {
        updateDatasource(index: sender.selectedSegmentIndex)
        reloadAndScrollUpTableView()
        
        if sender.selectedSegmentIndex == 3 {
            self.tabBarController?.tabBar.items?[2].badgeValue = nil
            self.segmentControl.noSetBadge(index: 3, value: 0)
        }
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
}
