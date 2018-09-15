//
//  TaCoController.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 1. 26..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
extension UITableView  {
    func setUp(target: UITableViewDelegate & UITableViewDataSource, cell: UITableViewCell.Type? = nil) {
        self.delegate = target
        self.dataSource = target
        if let cell = cell {
            self.register(UINib(nibName: cell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: cell.reuseIdentifier)
        }
    }
    
    func dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }
}
extension UICollectionView {
    func setUp(target: UICollectionViewDelegate & UICollectionViewDataSource, cell: UICollectionViewCell.Type? = nil){
        self.delegate = target
        self.dataSource = target
        if let cell = cell {
            self.register(UINib(nibName: cell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: cell.reuseIdentifier)
        }
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }
}

