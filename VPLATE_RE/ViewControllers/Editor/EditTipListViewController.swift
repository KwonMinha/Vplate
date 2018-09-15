//
//  EditTipListViewController.swift
//  VPLATE_RE
//
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import Kingfisher

class EditTipListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var editTipLists: [EditTipListData] = [EditTipListData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Editing Tips".localized
        
        tableView.delegate = self
        tableView.dataSource = self
        
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        
        editTipListInit()
        tableView.separatorStyle = .none
    }

    override func viewDidAppear(_ animated: Bool) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.isTranslucent = true
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    func editTipListInit() {
        TemplateService.editTipListInit { (editTipListData) in
            self.editTipLists = editTipListData
            self.tableView.reloadData()
        }
    }
}

extension EditTipListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return editTipLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditTipListTableViewCell", for: indexPath) as! EditTipListTableViewCell
        let index = editTipLists[indexPath.row]
        
        cell.thumbnailimageView?.kf.setImage(with: URL(string: index.thumbnail!))
        cell.titleLabel.text = index.title
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let editTipVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: EditTipViewController.reuseIdentifier) as! EditTipViewController
        
        editTipVC.tipId = editTipLists[indexPath.row]._id

        self.navigationController?.pushViewController(editTipVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}
