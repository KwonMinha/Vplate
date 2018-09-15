//
//  PullRefreshTableView.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 7. 3..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import Lottie
protocol PullRefreshTableViewDelegate {
    func pullRefreshTableView(tableView: PullRefreshTableView, refreshControl: UIRefreshControl)
}

class PullRefreshTableView: UITableView {
    lazy var pullRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = UIColor.clear
        
        return refreshControl
    }()
    
    var indicator = LOTAnimationView(name: "indicator")
    
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    func setUp() {
        pullRefreshControl.addSubview(indicator)
        indicator.backgroundColor = .clear
        
        indicator.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(self.frame.width)
            make.height.equalTo(50)
        }
        
        indicator.contentMode = .scaleAspectFit
        indicator.loopAnimation = true
        indicator.play()
        self.addSubview(pullRefreshControl)
    }
    
    func endRefresh() {
        pullRefreshControl.endRefreshing()
    }
    @objc func handleRefresh(_ sender: UIRefreshControl) {
        (delegate as? PullRefreshTableViewDelegate)?.pullRefreshTableView(tableView: self, refreshControl: sender)
    }

}
