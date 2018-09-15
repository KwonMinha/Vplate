//
//  NoticeViewController.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 7. 4..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit

class NoticeViewController: ViewController {
    @IBOutlet weak var tableView: UITableView!
    let notices = ["공지사항1", "공지사항2", "공지사항3"]
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
    }
    
    override func setUpViewController() {
        self.tableView.setUp(target: self)
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.selectRow(at: nil, animated: false, scrollPosition: .none)
    }
}


extension NoticeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = notices[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notices.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellTitle = notices[indexPath.row]
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: TextViewController.reuseIdentifier) as! TextViewController
        viewController.title = cellTitle
//        viewController.content =
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
