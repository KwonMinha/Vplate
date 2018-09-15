//
//  MyTemplateTableViewCell.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 5. 1..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import SnapKit
class MyTemplateTableViewCell: UITableViewCell {
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var duration: UIButton!
    @IBOutlet weak var state: UIButton!
    
    var successLabel: UILabel = UILabel()
    var progressLabel: UILabel = UILabel()
    var progress: GradientProgressView = GradientProgressView()
    
    @IBOutlet weak var modifiedView: UIView!
    @IBOutlet weak var modifiedLabel: UILabel!
    @IBOutlet weak var modifiedImageView: UIImageView!
    
    var info: MyTemplate? {
        didSet {
            //guard let info = self.info else {return}
            if let str = info?.originTemplate.thumbnail,
                let thumbnailURL = URL(string: str) {
                self.thumbnail.kf.setImage(with: thumbnailURL)
            }
            self.title.text = info?.originTemplate.title
            self.duration.setTitle(Util.format(info!.originTemplate.duration), for: .normal)
            self.state.setTitle(info?.state.description, for: .normal)
            
            //수정 indicator image 삽입하기
            switch info?.timesModified {
            case 1:
                self.modifiedLabel.text = "You can re-edit this video\n2 more times!".localized
                self.modifiedImageView.image = #imageLiteral(resourceName: "modifiedOne")
            case 2:
                self.modifiedLabel.text = "You can re-edit this video\n1 more times!".localized
                self.modifiedImageView.image = #imageLiteral(resourceName: "modifiedTwo")
            case 3:
                self.modifiedLabel.text = "It's not editable anymore!".localized
                self.modifiedImageView.image = #imageLiteral(resourceName: "modifiedThree")
            default:
                break
            }
        }
    }
        func updateState(state: TemplateState) {
            self.state.layer.sublayers?.forEach({ (layer) in
                if let layer = layer as? CAGradientLayer {
                    layer.removeFromSuperlayer()
                }
            })
            switch state {
            case .complete:
                self.state.backgroundColor = UIColor.red
                self.state.setTitleColor(.white, for: .normal)
            case .progress, .render, .modified:
                self.state.setTitleColor(.lightGray, for: .normal)
                self.state.backgroundColor = UIColor.white
                if state == .progress {
                    progressLabel.snp.makeConstraints { (make) in
                        make.bottom.equalTo(self.progress.snp.top).inset(-5)
                        if let value = self.info?.value {
                            progress.setProgress(Float(value)/100, animated: true)
                            progressLabel.text = "\(value)%"
                            let width = Double( progress.frame.width / 100 )
                            var leftMargin = Double(value) * width
                            if leftMargin <= 10 {
                                leftMargin = 10
                            }
                            else if ( leftMargin + Double(progressLabel.frame.width) ) >= Double(progress.frame.width - 10) {
                                leftMargin = Double(progress.frame.width + 10 - progressLabel.text!.stringWidth)
                            }
    
                            make.left.equalTo(self.thumbnail.snp.right).inset(-(leftMargin))
                        }
                    }
                }
            case .confirmed:
                self.state.setTitleColor(.white, for: .normal)
                self.state.createGradientLayer(startColor: UIColor.DefaultColor.skyBlue,
                                               endColor: UIColor.DefaultColor.lightGreen,
                                               startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 0))
            }
        }
    
        override func awakeFromNib() {
            setUpUI()
        }
    
        func contentState(state: TemplateState) {
            successLabel.isHidden = true
            progress.isHidden = true
            progressLabel.isHidden = true
            modifiedView.isHidden = true
            
            switch state {
            case .complete:
                successLabel.isHidden = false
            case .progress:
                progress.isHidden = false
                progressLabel.isHidden = false
            case .render:
                break
            case .confirmed:
                break
            case .modified:
                modifiedView.isHidden = false
            }
        }
    
        override func draw(_ rect: CGRect) {
            super.draw(rect)
            self.state.shadowRounded(cornerRadius: self.state.frame.height / 2,
                                     shadowColor: .black,
                                     shadowOffset: CGSize(width: 0, height: 1),
                                     shadowRadius: 1,
                                     shadowOpacity: 0.5)
            progress.cornerRadius = progress.frame.height / 2
        }
    
        func setUpUI(){
            self.contentView.addSubview(successLabel)
            successLabel.text = "Please confirm your video!".localized
            successLabel.font = successLabel.font.withSize(14)
            successLabel.textColor = #colorLiteral(red: 0.2039215686, green: 0.2039215686, blue: 0.2039215686, alpha: 0.92)
            successLabel.textAlignment = .center
            successLabel.snp.makeConstraints { (make) in
                make.left.equalTo(self.thumbnail.snp.right).inset(-10)
                make.right.equalTo(self.contentView.snp.right).inset(10)
                make.bottom.equalTo(self.duration.snp.top).inset(-12)
            }
    
            self.contentView.addSubview(progress)
            progress.snp.makeConstraints { (make) in
                make.left.equalTo(self.thumbnail.snp.right).inset(-10)
                make.right.equalTo(self.contentView.snp.right).inset(10)
                make.bottom.equalTo(self.duration.snp.top).inset(-10)
                make.height.equalTo(6)
            }
            progress.trackTintColor = UIColor(red: 205/255, green: 205/255, blue: 205/255, alpha: 1)
    
            self.contentView.addSubview(progressLabel)
            progressLabel.font = progressLabel.font.withSize(12)
            progressLabel.textColor = UIColor.DefaultColor.lightGreen
            progressLabel.textAlignment = .center
            
            self.contentView.addSubview(modifiedView)
            modifiedView.snp.makeConstraints { (make) in
                make.left.equalTo(self.thumbnail.snp.right).inset(-5)
                make.right.equalTo(self.contentView.snp.right).inset(5)
                //make.bottom.equalTo(self.duration.snp.top).inset(1)
                make.bottom.equalTo(self.contentView.snp.bottom).inset(23)
                //make.bottom.equalTo(self.state.snp.bottom).inset(10)
                
                make.height.equalTo(22) // 너비, 높이 모두 50으로 설정
                //make.center.equalTo(self.contentView)
            }
            
            
    
        }
}
