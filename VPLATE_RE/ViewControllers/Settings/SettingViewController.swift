//
//  SettingViewController.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 6. 27..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit

class SettingViewController: ViewController {
    @IBOutlet weak var tableView: UITableView!
    let lightSwitch = UISwitch(frame: CGRect.zero)
    let titles = ["Account Setting".localized, "View Tutorial Again".localized, "Terms".localized, "Notices".localized, "Push Alarm".localized, "Log Out".localized]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.selectRow(at: nil, animated: false, scrollPosition: .none)
    }
    
    override func setUpViewController() {
        self.tableView.setUp(target: self)
        self.tableView.alwaysBounceVertical = false
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .singleLineEtched
        self.tableView.showsVerticalScrollIndicator = false
        self.lightSwitch.isOn = false
        self.lightSwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
    }
    
    @objc func switchValueChanged(_ sender: UISwitch) {
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let cellTitle = titles[indexPath.row]
        cell.textLabel?.text = cellTitle
        if cellTitle == "Push Alarm".localized {
            lightSwitch.tag = indexPath.row
            cell.accessoryView = lightSwitch
            cell.setTransparentSelect()
        }
        else {
            cell.accessoryType = .disclosureIndicator
        }

        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellTitle = titles[indexPath.row]
        switch cellTitle {
        case "Account Setting".localized:
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: AccountSettingViewController.reuseIdentifier)
            viewController.title = cellTitle
            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
            self.hidesBottomBarWhenPushed = false
        case "View Tutorial Again".localized:
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: TutorialAgainViewController.reuseIdentifier)
            viewController.title = cellTitle
            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
            self.hidesBottomBarWhenPushed = false
        case "Terms".localized:
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: TextViewController.reuseIdentifier) as! TextViewController
            viewController.title = cellTitle
            //        viewController.content =
            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
            self.hidesBottomBarWhenPushed = false
        case "Notices".localized:
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: NoticeViewController.reuseIdentifier)
            viewController.title = cellTitle
            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
            self.hidesBottomBarWhenPushed = false
        case "Log Out".localized:
            break
        default: break
        }
    }
}
