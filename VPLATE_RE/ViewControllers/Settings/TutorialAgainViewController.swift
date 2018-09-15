//
//  TutorialAgainViewController.swift
//  VPLATE_RE
//
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import BMPlayer

class TutorialAgainViewController: UIViewController {
    @IBOutlet weak var player: Player!
    
    var url: String?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate


    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.shouldRotate = true // or false to disable rotation
        
        let langStr = Locale.current.languageCode

        if langStr == "ko" {
            self.url = "https://s3.ap-northeast-2.amazonaws.com/static-vplate/%ED%8A%9C%ED%86%A0%EB%A6%AC%EC%96%BC+%EB%8B%A4%EC%8B%9C%EB%B3%B4%EA%B8%B0/%E1%84%92%E1%85%A1%E1%86%AB%E1%84%80%E1%85%B3%E1%86%AF%E1%84%87%E1%85%A5%E1%84%8C%E1%85%A5%E1%86%AB.mp4"
        } else {
            self.url = "https://s3.ap-northeast-2.amazonaws.com/static-vplate/%ED%8A%9C%ED%86%A0%EB%A6%AC%EC%96%BC+%EB%8B%A4%EC%8B%9C%EB%B3%B4%EA%B8%B0/%E1%84%8B%E1%85%A7%E1%86%BC%E1%84%8B%E1%85%A5%E1%84%87%E1%85%A5%E1%84%8C%E1%85%A5%E1%86%AB.mp4"
        }
        
        BMPlayerConf.topBarShowInCase = BMPlayerTopBarShowCase.horizantalOnly
        self.player.setVideo(resource: BMPlayerResource(url: URL(string: self.url!)!))
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }

}
