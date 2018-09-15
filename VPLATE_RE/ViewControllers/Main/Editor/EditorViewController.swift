//
//  EditorViewController.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 3. 9..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import TLPhotoPicker
import Photos
import AWSS3
import AWSCore
import CropViewController
import Toast_Swift
import SwiftyJSON
import SnapKit

enum EditorType {
    case video, image, text
}

class EditorViewController: ViewController {
    @IBOutlet weak var sceneLabel: UILabel!
    @IBOutlet weak var sceneThumbnailImageView: UIImageView!
    @IBOutlet weak var sceneCollectionView: UICollectionView!
    @IBOutlet weak var customizableSegmentedControl: CustomizableSegmentedControl!
    @IBOutlet weak var editorCollectionView: UICollectionView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var menualButton: DesignableButton!
    
    var delegate: DetailViewController?
    var token: [NSKeyValueObservation]? = []
    @objc dynamic var template: Template?
    @objc dynamic var selectedSceneIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    var selectedScene: Scene?
    
    var selectedClipIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    @objc dynamic var selectedClip: Clip?
    
    var selectedAsset: PHAsset?
    
    var bottomInset: CGFloat {
        if #available(iOS 11.0, *) {
            if let inset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
                return inset
            }
        }
        return 0
    }
    
    var guideView: UIView = UIView()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.heightConstraint.constant = self.view.frame.height - self.sceneCollectionView.frame.maxY - bottomInset
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
        setUpKVO()
        setKeyboardSetting()
        
    }
    
    func setUpUI() {
        guard let window = UIApplication.shared.keyWindow else {return}
        window.addSubview(guideView)
        guideView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        guideView.snp.makeConstraints { (make) in
            make.edges.equalTo(window)
        }
        
        let menualLabel = UILabel()
        menualLabel.text = "Menual Label"
        menualLabel.textAlignment = .right
        menualLabel.textColor = .white
        let sceneNavLabel = UILabel()
        sceneNavLabel.text = "sceneNav Label"
        sceneNavLabel.textColor = .white
        let clipTabLabel = UILabel()
        clipTabLabel.text = "clipTab Label"
        clipTabLabel.textColor = .white
        let clipLabel = UILabel()
        clipLabel.text = "clip Label"
        clipLabel.textColor = .white
        
        guideView.addSubview(menualLabel)
        guideView.addSubview(sceneNavLabel)
        guideView.addSubview(clipTabLabel)
        guideView.addSubview(clipLabel)
        
        menualLabel.snp.makeConstraints { (make) in
            make.trailing.equalTo(self.menualButton.snp.trailing)
            make.top.equalTo(self.menualButton.snp.bottom)
            make.leading.equalTo(self.view.snp.leading)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.sceneCollectionView.reloadData()
        self.sceneCollectionView.selectItem(at: self.selectedSceneIndexPath, animated: true, scrollPosition: .left)
        self.editorCollectionView.reloadData()
        UIApplication.shared.statusBarStyle = .lightContent
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        setUpUI()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func setUpViewController() {
        self.title = "Template Editor"
    
        self.template =  self.delegate?.template?.copy()
        
        self.sceneCollectionView.setUp(target: self, cell: SceneCollectionViewCell.self)
        self.sceneCollectionView.showsHorizontalScrollIndicator = false
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 2
        self.sceneCollectionView.collectionViewLayout = layout
        
        self.editorCollectionView.setUp(target: self, cell: EditorCollectionViewCell.self)
        self.editorCollectionView.setUp(target: self, cell: EditorTextCollectionViewCell.self)
        
        self.customizableSegmentedControl.delegate = self
        self.customizableSegmentedControl.fixedValue = 3
        self.customizableSegmentedControl.bottomColor = UIColor(red: 92/255, green: 92/255, blue: 92/255, alpha: 1)
        let barButton: UIBarButtonItem = UIBarButtonItem(title: "DONE",
                                                         style: UIBarButtonItemStyle.done,
                                                         target: self,
                                                         action: #selector(touchUpCompletion(_:)))
        self.navigationItem.setRightBarButton(barButton, animated: true)
        
        self.sceneCollectionView.reloadData()
        self.editorCollectionView.reloadData()
    }
    
    func setUpKVO() {
        let option: NSKeyValueObservingOptions = [.initial, .new, .prior, .old]
        self.token?.append(self.observe(\.selectedSceneIndexPath, options: option) { (object, changed) in
            if let newValue = changed.newValue {
                self.sceneLabel.text = "Scene \(newValue.row + 1)"
                self.selectedScene = self.template?.scenes?[newValue.row]
                self.customizableSegmentedControl.selectedSegmentIndex = 0
                self.sceneThumbnailImageView.image = self.selectedScene?.thumbnail
                
                self.customizableSegmentedControl.removeAllSegments()
                if let clipTypes = self.selectedScene?.types {
                    for (index, clipType) in clipTypes.enumerated() {
                        self.customizableSegmentedControl.insertSegment(withTitle: clipType.description, at: index, animated: false)
                    }
                    self.customizableSegmentedControl.selectedSegmentIndex = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                    if let oldValue = changed.oldValue {
                        if oldValue != newValue {
                            self.sceneCollectionView.reloadItems(at: [oldValue])
                        }
                    }
                    self.editorCollectionView.reloadData()
                })  
            }
        })
    }
    
    func setKeyboardSetting() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.kyeboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.kyeboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func kyeboardWillShow(_ notification: Notification)
    {
        if let keyboadSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            self.bottomConstraint.constant = keyboadSize.height
            
            if let animationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval{
                UIView.animate(withDuration: animationDuration, animations: { self.view.layoutIfNeeded()})
            }
            self.view.layoutIfNeeded()
        }
    }
    @objc func kyeboardWillHide(_ notification: Notification)
    {
        if (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue != nil
        {
            self.bottomConstraint.constant = 0
            
            if let animationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval{
                UIView.animate(withDuration: animationDuration, animations: { self.view.layoutIfNeeded()})
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func touchUpCompletion(_ sender: UIBarButtonItem) {
        var completeClips: [Clip] = []
        if let scenes = template?.scenes {
            for scene in scenes {
                if let textClip = scene.clips?.filter({$0.type == .text && $0.text != nil}) {
                    completeClips.append(contentsOf: textClip)
                }
                if let imageClip = scene.clips?.filter({$0.type == .image && $0.imageURL != nil}) {
                    completeClips.append(contentsOf: imageClip)
                }
                if let videoClip = scene.clips?.filter({$0.type == .video && $0.videoURL != nil}) {
                    completeClips.append(contentsOf: videoClip)
                }
            }
        }
        let videoCount = (template?.clips["video"] ?? 0)
        let imageCount = (template?.clips["image"] ?? 0)
        let textCount = (template?.clips["text"] ?? 0)
        
        let alert = UIAlertController(title: "Warning", message: "Editing works left", preferredStyle: .alert)
        if completeClips.count != videoCount + imageCount + textCount {
            let alertAction = UIAlertAction(title: "OK", style: .destructive, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            alert.title = "Alert"
            alert.message = "Great. Informations you selected will be rendered to video. Do you agree?"
            let okAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
                guard let template = self.template else {return}
                EditorService.uploadClips(url: "api/v1/upload", title: template.title, clips: completeClips, completion: { (result) in
                    switch result {
                    case .Success(let response):
                        guard let data = response as? Data else {return}
                        let dataJSON = JSON(data)
                        print(dataJSON)
                        guard let window = UIApplication.shared.keyWindow else {return}
                        window.makeToast("🎉Successfully uploaded🎉")
                        self.navigationController?.popViewController(animated: true)
                    case .Failure(let failureCode):
                        self.view.makeToast("Sign In Failure : \(failureCode)")
                    case .FailDescription(let err):
                        self.view.makeToast(err)
                    }
                })
            }
            let cancelAction = UIAlertAction(title: "CANCEL", style: .destructive, handler: nil)
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func enableTouchUp() {
        
    }
    
}

extension EditorViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case sceneCollectionView :
            return template?.scenes?.count ?? 0
        case editorCollectionView :
            let type = self.customizableSegmentedControl.selectedType
            return selectedScene?.clips?.filter{ $0.type == type}.count ?? 0
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case sceneCollectionView:
            let cell: SceneCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            if let scene = template?.scenes?[indexPath.row] {
                cell.imageView.image = scene.thumbnail
                cell.filled = scene.isFilled!
            }
            return cell
        case editorCollectionView:
            if let type = self.customizableSegmentedControl.selectedType,
                let clips = selectedScene?.clips?.filter({$0.type == type}) {
                switch type {
                case .video, .image:
                    let cell: EditorCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
                    let clip = clips[indexPath.row]
                    cell.setUp(clip: clip)
                    return cell
                case .text:
                    let cell: EditorTextCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
                    let clip = clips[indexPath.row]
                    cell.textField.delegate = self
                    cell.maxLenght = Int(clip.value)
                    cell.textField.text = clip.text
                    if let length = cell.textField.text?.count {
                        switch length {
                        case 0:
                            cell.textField.stateUIUpdate(state: .empty)
                        default:
                            cell.textField.stateUIUpdate(state: .complete)
                        }
                    }
                    
                    cell.numberLabel.text =  String(format: "%02d", clip.index)
                    cell.textField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: UIControlEvents.editingChanged)
                    return cell
                }
            }
            return UICollectionViewCell()
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        switch collectionView {
        case sceneCollectionView:
            return CGSize(width: height * 16/9, height: height)
        case editorCollectionView:
            let width = collectionView.frame.width
            if let type = self.customizableSegmentedControl.selectedType {
                switch type {
                case .video, .image:
                    return CGSize(width: width, height: width * 9/16 + 40)
                case .text:
                    return CGSize(width: width, height: 60)
                }
            }
            return CGSize(width: 0, height: 0)
        default:
            return CGSize(width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case sceneCollectionView:
            self.selectedSceneIndexPath = indexPath
        case editorCollectionView:
            if let type = self.customizableSegmentedControl.selectedType {
                switch type {
                case .video, .image:
                    self.selectedClipIndexPath = indexPath
                    if let clips = selectedScene?.clips?.filter({ $0.type == type}) {
                        self.selectedClip = clips[indexPath.row]
                    }
                    var configure = TLPhotosPickerConfigure()
                    //                    configure.allowedLivePhotos = (index != 0)
                    configure.singleSelectedMode = true
                    configure.doneTitle = "DONE"
                    //                    configure.tapHereToChange = "이곳을 탭하여 카메라 롤을 변경하세요"
                    configure.usedCameraButton = false
                    configure.selectedColor = UIColor.DefaultColor.skyBlue
                    configure.minimumDuration = TimeInterval(self.selectedClip!.value)
                    configure.autoPlay = true
                    
                    let fetchOption = PHFetchOptions()
                    let mediaType: PHAssetMediaType = type == .video ? .video : .image
                    fetchOption.predicate = NSPredicate(format: "mediaType = %d", mediaType.rawValue)
                    configure.fetchOption = fetchOption
                    
                    let viewController = PhotoPickerWithNavigationViewController()
                    viewController.delegate = self
                    viewController.configure = configure
                    viewController.fileName = "\(self.template?.title ?? "") \(String(describing: self.selectedClip?.index ?? 0))"
                    let navController = UINavigationController(rootViewController: viewController) // Creating a navigation controller with VC1 at the root of the navigation stack.
                    self.present(navController, animated:true, completion: nil)
                    
//                    self.navigationController?.pushViewController(viewController, animated: true)
                case .text: break
                }
            }
            
        default: break
        }
    }
}

extension EditorViewController: CustomizableSegmentedControlDelegate {
    func valueChanged(_ sender: CustomizableSegmentedControl) {
        self.editorCollectionView.reloadData()
        if let clips = selectedScene?.clips?.filter({ $0.type.rawValue ==  sender.selectedSegmentIndex}),
            clips.count > 0 {
            self.editorCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: UICollectionViewScrollPosition.top)
        }
    }
}

extension EditorViewController: TLPhotosPickerViewControllerDelegate, CropViewControllerDelegate {
    func handleNoCameraPermissions(picker: TLPhotosPickerViewController) {
        let alert = UIAlertController(title: "", message: "No camera permissions granted", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension EditorViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textField = textField as? CustomizableTextField else {return true}
        
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        if prospectiveText.count <= textField.maxLength {
            textField.lenghtUIUpdate(length: prospectiveText.count)
        }
        return prospectiveText.count <= textField.maxLength
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let textField = textField as? CustomizableTextField else {return true}
        let cell = textField.superview?.superview as! UICollectionViewCell
        let collectionView = cell.superview as! UICollectionView
        
        if let textFieldIndexPath = collectionView.indexPath(for: cell) {
            if let nextEditorCell = editorCollectionView.cellForItem(at: IndexPath(row: textFieldIndexPath.row + 1, section: 0)) as? EditorTextCollectionViewCell{
                nextEditorCell.textField.becomeFirstResponder()
            }
            else {
                self.view.endEditing(true)
            }
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard let textField = textField as? CustomizableTextField else {return true}
        
        
        if let length = textField.text?.count {
            textField.lenghtUIUpdate(length: length)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let textField = textField as? CustomizableTextField else {return}
        
        if let length = textField.text?.count {
            switch length {
            case 0:
                textField.stateUIUpdate(state: .empty)
            default:
                textField.stateUIUpdate(state: .complete)
            }
        }
    }
    
    @objc func textFieldEditingChanged(_ textField: UITextField) {
        let cell = textField.superview?.superview as! UICollectionViewCell
        let collectionView = cell.superview as! UICollectionView
        let textFieldIndexPath = collectionView.indexPath(for: cell)
        if let clips = selectedScene?.clips?.filter({$0.type == .text}),
            let indexPath = textFieldIndexPath {
            self.selectedClip = clips[indexPath.row]
            if let text = textField.text, !text.isNilOrEmpty() {
                self.selectedClip?.text = textField.text
            } else {
                self.selectedClip?.text  = nil
            }
        }
    }
}
