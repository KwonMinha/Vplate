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
import CropViewController
import Toast_Swift
import SwiftyJSON
import SnapKit

protocol EditorDelegate {
    func editComplete()
}

class EditorViewController: ViewController {
    @IBOutlet weak var sceneLabel: UILabel!
    @IBOutlet weak var sceneCollectionView: UICollectionView!
    @IBOutlet weak var customizableSegmentedControl: CustomizableSegmentedControl!
    @IBOutlet weak var editorCollectionView: UICollectionView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var menualButton: DesignableButton!
    @IBOutlet weak var dismissKeyboardButton: UIButton!
    @IBOutlet weak var bottomTextField: CustomizableTextField!
    @IBOutlet weak var accessoryView: UIView!
    
    @IBOutlet weak var cvSceneThumbnailLarge: UICollectionView!
    @IBOutlet weak var controlThumbPage: UIPageControl!
    @IBOutlet weak var btnLeftArrow: UIButton!
    @IBOutlet weak var btnRightArrow: UIButton!
    
    let tutorialView: TutorialView = TutorialView()
    let fingerImageView = UIImageView()
    let imageLabel = UILabel()
    let nextButton = DesignableButton()
    let fullIndicatorView = FullIndicatorView()
    
    var subId: String?
    var modifiedCount: Int = 0
    var status: Int?
    
    var filledArray: [Int] = []
    var progress: Double?
    
    var bottomInset: CGFloat {
        if #available(iOS 11.0, *) {
            if let inset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
                return inset
            }
        }
        return 0
    }
    var editorDelegate: EditorDelegate?
    var delegate: UIViewController?
    var template: Template?
    var selectedSceneIndexPath: IndexPath = IndexPath() {
        didSet {
            changedSelectedScenedIndex(previous: oldValue)
        }
    }
    var selectedScene: Scene?
    var selectedSegmentType: ClipType?{
        return self.customizableSegmentedControl.selectedType
    }
    var selectedClip: Clip?
    var selectedEditorTextCellIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.heightConstraint.constant = self.view.frame.height - self.sceneCollectionView.frame.maxY - bottomInset
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViewController()
        setUpCollectionView()
        setKeyboardSetting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.sceneCollectionView.reloadData()
        if self.template?.scenes != nil {
            self.sceneCollectionView.selectItem(at: self.selectedSceneIndexPath, animated: true, scrollPosition: .left)
        }
        self.editorCollectionView.reloadData()
        
        UserDefaults.standard.removeObject(forKey: "boolKeyName")
        
        //setUpTutorialView()
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            debugPrint("Not first launch.")
        } else {
            setUpTutorialView()
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
        
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func setUpViewController() {
        self.title = "Template Editor".localized
        self.customizableSegmentedControl.delegate = self
        self.customizableSegmentedControl.fixedValue = 3
        self.customizableSegmentedControl.bottomColor = UIColor(red: 92/255, green: 92/255, blue: 92/255, alpha: 1)
        
        self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Back-1"), style: .plain, target: self, action: #selector(touchUpBack(_:)))
        self.navigationItem.setLeftBarButton(backButton, animated: true)
        let barButton: UIBarButtonItem = UIBarButtonItem(title: "Done".localized,
                                                         style: UIBarButtonItemStyle.done,
                                                         target: self,
                                                         action: #selector(touchUpCompletion(_:)))
        self.navigationItem.setRightBarButton(barButton, animated: true)
        //        UINavigationBar.appearance().barTintColor = UIColor.white
        self.accessoryView.alpha = 0.0
        
        self.bottomTextField.delegate = self
        self.bottomTextField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        self.bottomTextField.underLineHeight = 0
        self.bottomTextField.typingTextColor = UIColor(red: 222.0 / 255.0, green: 64.0 / 255.0, blue: 82.0 / 255.0, alpha: 1.0)
        
        self.selectedSceneIndexPath = IndexPath(row: 0, section: 0)
        
        //MARK: Menual Button Action
        self.menualButton.addTarget(self, action: #selector(touchUpMenualButton), for: .touchUpInside)
    }
    
    @objc func touchUpMenualButton() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "EditTipListViewController") as? EditTipListViewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func setUpCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 2
        
        self.sceneCollectionView.setUp(target: self, cell: SceneCollectionViewCell.self)
        self.sceneCollectionView.showsHorizontalScrollIndicator = false
        self.sceneCollectionView.collectionViewLayout = layout
        
        self.editorCollectionView.setUp(target: self, cell: EditorCollectionViewCell.self)
        self.editorCollectionView.setUp(target: self, cell: EditorTextCollectionViewCell.self)
    }
    
    func changedSelectedScenedIndex(previous: IndexPath) {
        self.customizableSegmentedControl.isEnabled = false
        if !previous.isEmpty && previous != self.selectedSceneIndexPath{
            DispatchQueue.main.async {
                self.sceneCollectionView.reloadItems(at: [previous])
            }
        }
        
        self.selectedScene = self.template?.scenes[selectedSceneIndexPath.row]
        self.sceneLabel.text = "Scene \(selectedScene?.index ?? 0)"
        //        if let urlString = self.selectedScene?.thumbnail[0],
        //            let imageURL = URL(string: urlString) {
        //            self.sceneThumbnailImageView.kf.setImage(with: imageURL)
        //        }
        self.customizableSegmentedControl.removeAllSegments()
        guard let clipTypes = self.selectedScene?.types else {return}
        for (index, clipType) in clipTypes.enumerated() {
            self.customizableSegmentedControl.insertSegment(withTitle: clipType.description, at: index, animated: false)
        }
        
        DispatchQueue.main.async {
            self.customizableSegmentedControl.setSelectedSegmentIndex(0)
            self.reloadAndScrollUpCollectionView()
        }
        self.customizableSegmentedControl.isEnabled = true
    }
    
    //Control Keyboard Notification
    func setKeyboardSetting() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.kyeboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.kyeboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func kyeboardWillShow(_ notification: Notification)
    {
        if let keyboadSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            self.bottomConstraint.constant = keyboadSize.height - bottomInset
            
            if let animationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval{
                UIView.animate(withDuration: animationDuration, animations: {
                    self.view.layoutIfNeeded()
                    self.accessoryView.alpha = 1.0
                })
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
                UIView.animate(withDuration: animationDuration, animations: {
                    self.accessoryView.alpha = 0.0
                    self.view.layoutIfNeeded()
                })
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func touchUpDismissKeyboard(_ sender: UIButton){
        self.view.endEditing(true)
    }
    
    @objc func touchUpCompletion(_ sender: UIBarButtonItem) {
        guard let template = self.template else { return }
        //temp
        //        for scene in template.scenes {
        //            for clip in scene.clips {
        //                if(clip.type == .text) {
        //                    clip.text = "Test \(clip.index)"
        //                    print("TEXT SET : \(clip.text)")
        //                } else if(clip.type == .image) {
        //                    clip.imageUrl = template.scenes[0].clips[0].imageUrl
        //                    print("IMAGE SET : \(clip.imageUrl)")
        //                }
        //            }
        //        }
        //temp
        showAlert(template: template)
    }
    
    @IBAction func actionBtnThumbnailLeft() {
        let currentPage = controlThumbPage.currentPage
        if(currentPage == 0) {
            return
        }
        self.cvSceneThumbnailLarge.scrollToItem(at: IndexPath(row: currentPage-1, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    @IBAction func actionBtnThumbnailRight() {
        let currentPage = controlThumbPage.currentPage
        if let scene = template?.scenes[selectedSceneIndexPath.row]{
            if(currentPage == scene.thumbnail.count - 1) {
                return
            }
        }
        self.cvSceneThumbnailLarge.scrollToItem(at: IndexPath(row: currentPage+1, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    func showAlert(template: Template) {
        let alert = UIAlertController(title: "", message: "Editor Fail Alert".localized, preferredStyle: .alert)
        if(template.isFilled() == false) {
            let alertAction = UIAlertAction(title: "YES".localized, style: .destructive, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            //alert.title = "Alert"
            alert.message = "Editor Done Alert".localized
            let okAction = UIAlertAction(title: "YES".localized, style: .default) { (UIAlertAction) in
                self.fullIndicatorView.show(true)
                
                //수정일 때는 status값 바뀌지 않는다. status = 4 그대로여야함
                //                if self.modifiedCount == 0 { //작업중 0
                //                    self.status = 0
                //                } else {                     //수정 4
                //                    self.status = 4
                //                }
                
                //MARK: Done Button Networking - 100% 저장(렌더링중)
                TemplateService.editTemplate(
                    subId: self.subId!,
                    status: 1,
                    percent: 100,
                    template: template,
                    progress: {(progress: Double) in
                        self.fullIndicatorView.set(value: Int(progress * 100))
                },
                    success: {
                        self.fullIndicatorView.show(false)
                        self.closeViewController()
                },
                    failure: {(errorString: String) in
                        self.fullIndicatorView.show(false)
                        self.addAlert(title: "", msg: errorString)
                })
                
                
            }
            let cancelAction = UIAlertAction(title: "NO".localized, style: .destructive, handler: nil)
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func closeViewController() {
        //self.navigationController?.popToRootViewController(animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "RenderingViewController") as? RenderingViewController {
            self.present(viewController, animated: true, completion: nil)
            editorDelegate?.editComplete()
        }
    }
    
    @objc func touchUpBack(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: "Editor Back Alert".localized, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "YES".localized, style: .default) { (UIAlertAction) in
            
            self.fullIndicatorView.show(true)
            
            //템플릿에 있는 총 scene의 갯수 (ex.무신사 14개)
            let sceneCount = (self.template?.scenes.count)! - 1
            //각 씬의 text, image, video별 클립의 갯수에서 가장 마지막 클립의 index -> 총 clip의 갯수
            let clipCount = (self.template?.scenes[sceneCount].clips.count)! - 1
            
            for i in 0 ..< (self.template?.scenes.count)! {
                for j in 0 ..< (self.template?.scenes[i].clips.count)! {
                    if self.template?.scenes[i].clips[j].filledCount() == 1 {
                        //clip에 값이 채워졌다면 1을 반환
                        self.filledArray.append(1)
                    }
                }
            }
            
            //값이 채워진 clip 갯수
            let filledCount: Double = Double(self.filledArray.count)
            //총 clip 갯수
            let arrayCount: Double = Double((self.template?.scenes[sceneCount].clips[clipCount].index)!)

            //progress bar의 값 도출
            self.progress = floor((filledCount / arrayCount) * 100)
            
            //MARK: Back Button Networking - 중간저장(작업중)
            
            //수정일 때는 status값 바뀌지 않는다. status = 4 그대로여야함
            if self.modifiedCount == 0 {  //작업중 0
                self.status = 0
            } else {                      //수정 4
                self.status = 4
            }
            
            TemplateService.editTemplate(
                subId: self.subId!,
                status: self.status!,
                percent: Int(self.progress!),
                template: self.template!,
                progress: {(progress: Double) in
                    self.fullIndicatorView.set(value: Int(progress * 100))
            },
                success: {
                    self.fullIndicatorView.show(false)
                    //navigationController?.popToRootViewControllerAnimated(true)
                    self.navigationController?.popToRootViewController(animated: true)
                    self.editorDelegate?.editComplete()
            },
                failure: {(errorString: String) in
                    self.fullIndicatorView.show(false)
                    self.addAlert(title: "", msg: errorString)
            })
            
            
        }
        let noAction = UIAlertAction(title: "NO".localized, style: .default, handler: nil)
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func removeFileAtURLIfExists(url: URL) {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: url.path) else { return }
        
        do {
            try fileManager.removeItem(at: url)
        }
        catch let error {
            debugPrint("Couldn't remove existing destination file: \(String(describing: error))")
        }
    }
}

extension EditorViewController: CustomizableSegmentedControlDelegate {
    func valueChanged(_ sender: CustomizableSegmentedControl) {
        self.view.endEditing(true)
        
        if let clips = selectedScene?.clips.filter({ $0.type == sender.selectedType}),
            clips.count > 0 {
            self.editorCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: UICollectionViewScrollPosition.top)
        }
        self.editorCollectionView.reloadData()
    }
}

extension EditorViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case sceneCollectionView :
            return template?.scenes.count ?? 0
        case editorCollectionView :
            return selectedScene?.clips.filter{ $0.type == self.selectedSegmentType}.count ?? 0
        case cvSceneThumbnailLarge :
            guard let template = self.template else {
                return 0
            }
            let count = template.scenes[self.selectedSceneIndexPath.row].thumbnail.count
            if(count <= 1) {
                self.controlThumbPage.isHidden = true
                self.btnLeftArrow.isHidden = true
                self.btnRightArrow.isHidden = true
            } else {
                self.controlThumbPage.isHidden = false
                self.btnLeftArrow.isHidden = false
                self.btnRightArrow.isHidden = false
            }
            self.controlThumbPage.numberOfPages = count
            return count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case sceneCollectionView:
            let cell: SceneCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            if let scene = template?.scenes[indexPath.row]{
                if(scene.thumbnail.count > 0) {
                    let thumbnailPath = scene.thumbnail[0]
                    let url = URL(string: thumbnailPath)
                    cell.imageView.kf.setImage(with: url)
                }
                cell.filled = scene.isFilled()
            }
            return cell
        case editorCollectionView:
            if let type = self.selectedSegmentType, let sceneClips = selectedScene?.clips {
                var clips:[Clip] = []
                for item in sceneClips {
                    if(item.type == type) {
                        clips.append(item)
                    }
                }
                switch type {
                case .video, .image:
                    let cell: EditorCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
                    let clip = clips[indexPath.row]
                    cell.setUp(clip: clip)
                    return cell
                case .text:
                    let cell: EditorTextCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
                    let clip = clips[indexPath.row]
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
                    return cell
                }
            }
            return UICollectionViewCell()
        case cvSceneThumbnailLarge:
            let cell: EditorSceneThumbnailCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            if let scene = template?.scenes[selectedSceneIndexPath.row]{
                if(scene.thumbnail.count > 0) {
                    let thumbnailPath = scene.thumbnail[indexPath.row]
                    let url = URL(string: thumbnailPath)
                    cell.ivThumbnail.kf.setImage(with: url)
                }
            }
            return cell
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
            if let type = self.selectedSegmentType {
                switch type {
                case .video, .image:
                    return CGSize(width: width, height: width * 9/16 + 40)
                case .text:
                    return CGSize(width: width, height: 65 )
                }
            }
            return CGSize(width: 0, height: 0)
        case cvSceneThumbnailLarge:
            let width = cvSceneThumbnailLarge.bounds.size.width
            let height = cvSceneThumbnailLarge.bounds.size.height
            let size = CGSize.init(width: width, height: height)
            return size
        default:
            return CGSize(width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case sceneCollectionView:
            self.selectedSceneIndexPath = indexPath
            self.cvSceneThumbnailLarge.reloadData()
        case editorCollectionView:
            if let type = self.selectedSegmentType {
                switch type {
                case .video, .image:
                    if let clips = selectedScene?.clips.filter({ $0.type == type}) {
                        self.selectedClip = clips[indexPath.row]
                    }
                    var configure = TLPhotosPickerConfigure()
                    configure.singleSelectedMode = true
                    //debugPrint(type.description.localized)
                    configure.defaultCameraRollTitle = type.description.localized
                    configure.doneTitle = "Select".localized
                    configure.tapHereToChange = "Tap here to change".localized
                    
                    configure.usedCameraButton = false
                    configure.selectedColor = UIColor.DefaultColor.skyBlue
                    if let selectedClip = self.selectedClip {
                        configure.minimumDuration = TimeInterval(selectedClip.value)
                    }
                    configure.autoPlay = true
                    
                    let fetchOption = PHFetchOptions()
                    fetchOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                    let mediaType: PHAssetMediaType = type == .video ? .video : .image
                    fetchOption.predicate = NSPredicate(format: "mediaType = %d", mediaType.rawValue)
                    configure.fetchOption = fetchOption
                    
                    let viewController = PhotoPickerWithNavigationViewController()
                    viewController.delegate = self
                    viewController.configure = configure
                    viewController.selectedSegmentType = self.selectedSegmentType
                    viewController.selectedClip = self.selectedClip
                    viewController.fileName = "\("USER")_\(self.template?.title ?? "TEMPLATE")_S\(String(describing: self.selectedScene?.index ?? 0))_C\(String(describing: self.selectedClip?.index ?? 0))"
                    let navController = UINavigationController(rootViewController: viewController)
                    self.present(navController, animated:true, completion: nil)
                case .text:
                    var clips: [Clip] = []
                    if let sceneClips = self.selectedScene?.clips {
                        for clip in sceneClips {
                            if clip.type == .text {
                                clips.append(clip)
                            }
                        }
                        self.selectedClip = clips[indexPath.row]
                        self.selectedEditorTextCellIndexPath = indexPath
                        self.bottomTextField.maxLength = selectedClip?.value ?? 0
                        self.bottomTextField.text = selectedClip?.text
                        if let length = self.bottomTextField.text?.count {
                            switch length {
                            case 0:
                                self.bottomTextField.stateUIUpdate(state: .empty)
                            default:
                                self.bottomTextField.stateUIUpdate(state: .complete)
                            }
                        }
                        self.bottomTextField.becomeFirstResponder()
                        collectionView.reloadData()
                    }
                }
            }
            
        default: break
        }
    }
    
    func reloadAndScrollUpCollectionView() {
        UIView.transition(with: self.editorCollectionView,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.editorCollectionView.reloadData()
        }) { (value) in
            self.editorCollectionView.setContentOffset(CGPoint.zero, animated: true)
        }
    }
}

extension EditorViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = self.cvSceneThumbnailLarge.bounds.size.width
        var index = 0
        let currentOffset: Int = Int(scrollView.contentOffset.x/width * 10)
        if (currentOffset % 10 < 5) {
            index = currentOffset / 10
        } else{
            index = currentOffset / 10 + 1
        }
        self.controlThumbPage.currentPage = index
    }
}

extension EditorViewController: TLPhotosPickerViewControllerDelegate, CropViewControllerDelegate {
    func handleNoCameraPermissions(picker: TLPhotosPickerViewController) {
        let alert = UIAlertController(title: "", message: "No camera permissions granted", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK: Keyboard Settings
extension EditorViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textField = textField as? CustomizableTextField else {return true}
        
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        if prospectiveText.count <= textField.maxLength {
            textField.lenghtUIUpdate(length: prospectiveText.count)
            let cell: EditorTextCollectionViewCell = (editorCollectionView.cellForItem(at: self.selectedEditorTextCellIndexPath) as? EditorTextCollectionViewCell)!
            cell.textField.lenghtUIUpdate(length: prospectiveText.count)
        }
        return prospectiveText.count <= textField.maxLength
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //        if let cell = self.selectedEditorTextCell,
        //            let indexPath = self.editorCollectionView.indexPath(for: cell),
        //            let nextCell = editorCollectionView.cellForItem(at: IndexPath(row: indexPath.row + 1, section: indexPath.section)) as? EditorTextCollectionViewCell {
        //            textField.resignFirstResponder()
        //            nextCell.textField.becomeFirstResponder()
        //        }
        //        else {
        self.view.endEditing(true)
        //        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let textField = textField as? CustomizableTextField else {return}
        if let length = textField.text?.count {
            switch length {
            case 0:
                textField.stateUIUpdate(state: .empty)
                let cell: EditorTextCollectionViewCell = (editorCollectionView.cellForItem(at: self.selectedEditorTextCellIndexPath) as? EditorTextCollectionViewCell)!
                cell.textField.stateUIUpdate(state: .empty)
            default:
                textField.stateUIUpdate(state: .complete)
                let cell: EditorTextCollectionViewCell = (editorCollectionView.cellForItem(at: self.selectedEditorTextCellIndexPath) as? EditorTextCollectionViewCell)!
                cell.textField.stateUIUpdate(state: .complete)
            }
        }
    }
    
    @objc func textFieldEditingChanged(_ textField: UITextField) {
        let cell: EditorTextCollectionViewCell = (editorCollectionView.cellForItem(at: self.selectedEditorTextCellIndexPath) as? EditorTextCollectionViewCell)!
        cell.textField.text = textField.text
        if let text = textField.text, !text.isNilOrEmpty() {
            self.selectedClip?.text = text
        } else {
            self.selectedClip?.text = ""
        }
    }
}
