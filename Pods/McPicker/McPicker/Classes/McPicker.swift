/*
 Copyright (c) 2017 Kevin McGill <kevin@mcgilldevtech.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import UIKit

open class McPicker: UIView {
    open var customizeType: Bool?
    open var fontSize: CGFloat = 25.0

    /**
        The custom label to use with the picker.
     
        ```
             let customLabel = UILabel()
             customLabel.textAlignment = .center
             customLabel.textColor = .white
             customLabel.font = UIFont(name:"American Typewriter", size: 30)!
     
             mcPicker.label = customLabel // Set your custom label
         ```
     */
    open var label: UILabel?

    public var toolbarButtonsColor: UIColor? {
        didSet {
            applyToolbarButtonItemsSettings { (barButtonItem) in
                barButtonItem.tintColor = toolbarButtonsColor
            }
        }
    }
    public var toolbarDoneButtonColor: UIColor? {
        didSet {
            applyToolbarButtonItemsSettings(withAction: #selector(McPicker.done)) { (barButtonItem) in
                barButtonItem.tintColor = toolbarDoneButtonColor
            }
        }
    }
    public var toolbarCancelButtonColor: UIColor? {
        didSet {
            applyToolbarButtonItemsSettings(withAction: #selector(McPicker.cancel)) { (barButtonItem) in
                barButtonItem.tintColor = toolbarCancelButtonColor
            }
        }
    }
    public var toolbarBarTintColor: UIColor? {
        didSet { toolbar.barTintColor = toolbarBarTintColor }
    }
    public var toolbarItemsFont: UIFont? {
        didSet {
            applyToolbarButtonItemsSettings { (barButtonItem) in
                barButtonItem.setTitleTextAttributes([.font: toolbarItemsFont!], for: .normal)
                barButtonItem.setTitleTextAttributes([.font: toolbarItemsFont!], for: .selected)
            }
        }
    }
    public var pickerBackgroundColor: UIColor? {
        didSet { picker.backgroundColor = pickerBackgroundColor }
    }
    /**
        Sets the picker's components row position and picker selections to those String values.

        [Int:[Int:Bool]] equates to [Component: [Row: isAnimated]
    */
    public var pickerSelectRowsForComponents: [Int: [Int: Bool]]? {
        didSet {
            for component in pickerSelectRowsForComponents!.keys {
                if let row = pickerSelectRowsForComponents![component]?.keys.first,
                    let isAnimated = pickerSelectRowsForComponents![component]?.values.first {
                    pickerSelection[component] = pickerData[component][row]
                    picker.selectRow(row, inComponent: component, animated: isAnimated)
                }
            }
        }
    }
    public var showsSelectionIndicator: Bool? {
        didSet { picker.showsSelectionIndicator = showsSelectionIndicator ?? false }
    }

    internal var popOverContentSize: CGSize {
        return CGSize(width: Constant.pickerHeight + Constant.toolBarHeight, height: Constant.pickerHeight + Constant.toolBarHeight)
    }
    internal var pickerSelection: [Int:String] = [:]
    internal var pickerData: [[String]] = []
    internal var numberOfComponents: Int {
        return pickerData.count
    }
    internal let picker: UIPickerView = UIPickerView()
    internal let backgroundView: UIView = UIView()
    internal let toolbar: UIToolbar = UIToolbar()
    internal var isPopoverMode = false
    internal var mcPickerPopoverViewController: McPickerPopoverViewController?
    internal enum AnimationDirection {
        case `in`, out // swiftlint:disable:this identifier_name
    }

    fileprivate var doneHandler:(_ selections: [Int:String]) -> Void = {_ in }
    fileprivate var cancelHandler:() -> Void = { }

    private var appWindow: UIWindow {
        guard let window = UIApplication.shared.keyWindow else {
            debugPrint("KeyWindow not set. Returning a default window for unit testing.")
            return UIWindow()
        }
        return window
    }

    private enum Constant {
        static let pickerHeight: CGFloat = 216.0
        static let toolBarHeight: CGFloat = 44.0
        static let backgroundAlpha: CGFloat =  0.75
        static let animationSpeed: TimeInterval = 0.25
        static let barButtonFixedSpacePadding: CGFloat = 0.02
    }

    convenience public init(data: [[String]]) {
        self.init(frame: CGRect.zero)
        self.pickerData = data
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    internal override init(frame: CGRect) {
        super.init(frame: frame)
    }

    // MARK: Show
    //
    open class func show(data: [[String]], cancelHandler:@escaping () -> Void, doneHandler:@escaping (_ selections: [Int:String]) -> Void) {
        McPicker(data:data).show(cancelHandler: cancelHandler, doneHandler: doneHandler)
    }

    open class func show(data: [[String]], doneHandler:@escaping (_ selections: [Int:String]) -> Void) {
        McPicker(data:data).show(cancelHandler: {}, doneHandler: doneHandler)
    }

    open func show(doneHandler:@escaping (_ selections: [Int:String]) -> Void) {
        show(cancelHandler: {}, doneHandler: doneHandler)
    }

    open func show(cancelHandler:@escaping () -> Void, doneHandler:@escaping (_ selections: [Int:String]) -> Void) {
        self.doneHandler = doneHandler
        self.cancelHandler = cancelHandler
        animateViews(direction: .in)
    }

    // MARK: Show As Popover
    //
    open class func showAsPopover(data: [[String]],
                                  fromViewController: UIViewController,
                                  sourceView: UIView? = nil,
                                  sourceRect: CGRect? = nil,
                                  barButtonItem: UIBarButtonItem? = nil,
                                  cancelHandler:@escaping () -> Void,
                                  doneHandler:@escaping (_ selections: [Int:String]) -> Void) {
        McPicker(data: data).showAsPopover(fromViewController: fromViewController,
                                           sourceView: sourceView,
                                           sourceRect: sourceRect,
                                           barButtonItem: barButtonItem,
                                           cancelHandler: cancelHandler,
                                           doneHandler: doneHandler)
    }

    open class func showAsPopover(data: [[String]],
                                  fromViewController: UIViewController,
                                  sourceView: UIView? = nil,
                                  sourceRect: CGRect? = nil,
                                  barButtonItem: UIBarButtonItem? = nil,
                                  doneHandler:@escaping (_ selections: [Int:String]) -> Void) {
        McPicker(data: data).showAsPopover(fromViewController: fromViewController,
                                           sourceView: sourceView,
                                           sourceRect: sourceRect,
                                           barButtonItem: barButtonItem,
                                           cancelHandler: {},
                                           doneHandler: doneHandler)
    }

    open func showAsPopover(fromViewController: UIViewController,
                            sourceView: UIView? = nil,
                            sourceRect: CGRect? = nil,
                            barButtonItem: UIBarButtonItem? = nil,
                            doneHandler:@escaping (_ selections: [Int:String]) -> Void) {
        self.showAsPopover(fromViewController: fromViewController,
                           sourceView: sourceView,
                           sourceRect: sourceRect,
                           barButtonItem: barButtonItem,
                           cancelHandler: {},
                           doneHandler: doneHandler)
    }

    open func showAsPopover(fromViewController: UIViewController,
                            sourceView: UIView? = nil,
                            sourceRect: CGRect? = nil,
                            barButtonItem: UIBarButtonItem? = nil,
                            cancelHandler:@escaping () -> Void,
                            doneHandler:@escaping (_ selections: [Int:String]) -> Void) {

        if sourceView == nil && barButtonItem == nil {
            fatalError("You must set at least 'sourceView' or 'barButtonItem'")
        }

        self.isPopoverMode = true
        self.doneHandler = doneHandler
        self.cancelHandler = cancelHandler

        mcPickerPopoverViewController = McPickerPopoverViewController(mcPicker: self)
        mcPickerPopoverViewController?.modalPresentationStyle = UIModalPresentationStyle.popover

        let popover = mcPickerPopoverViewController?.popoverPresentationController
        popover?.delegate = self

        if let sView = sourceView {
            popover?.sourceView = sView
            popover?.sourceRect = sourceRect ?? sView.bounds
        } else {
            popover?.barButtonItem = barButtonItem
        }

        fromViewController.present(mcPickerPopoverViewController!, animated: true)
    }

    open func setToolbarItems(items: [McPickerBarButtonItem]) {
        toolbar.items = items
    }

    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)

        if newWindow != nil {
            NotificationCenter.default.addObserver(self, selector: #selector(McPicker.sizeViews), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        } else {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        }
    }

    @objc internal func sizeViews() {
        let size = isPopoverMode ? popOverContentSize : self.appWindow.bounds.size
        self.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        let backgroundViewY = isPopoverMode ? 0 : self.bounds.size.height - (Constant.pickerHeight + Constant.toolBarHeight)
        backgroundView.frame = CGRect(x: 0, y: backgroundViewY, width: self.bounds.size.width, height: Constant.pickerHeight + Constant.toolBarHeight)
        toolbar.frame = CGRect(x: 0, y: 0, width: backgroundView.bounds.size.width, height: Constant.toolBarHeight)
        picker.frame = CGRect(x: 0, y: toolbar.bounds.size.height, width: backgroundView.bounds.size.width, height: Constant.pickerHeight)
    }

    internal func addAllSubviews() {
        backgroundView.addSubview(picker)
        backgroundView.addSubview(toolbar)
        self.addSubview(backgroundView)
    }

    internal func dismissViews() {
        if isPopoverMode {
            mcPickerPopoverViewController?.dismiss(animated: true, completion: nil)
            mcPickerPopoverViewController = nil // Release, as to not create a retain cycle.
        } else {
            animateViews(direction: .out)
        }
    }

    internal func animateViews(direction: AnimationDirection) {
        var backgroundFrame = backgroundView.frame

        if direction == .in {
            // Start transparent
            //
            self.backgroundColor = UIColor.black.withAlphaComponent(0)

            // Start picker off the bottom of the screen
            //
            backgroundFrame.origin.y = self.appWindow.bounds.size.height
            backgroundView.frame = backgroundFrame

            // Add views
            //
            addAllSubviews()
            appWindow.addSubview(self)

            // Animate things on screen
            //
            UIView.animate(withDuration: Constant.animationSpeed, animations: {
                self.backgroundColor = UIColor.black.withAlphaComponent(Constant.backgroundAlpha)
                backgroundFrame.origin.y = self.appWindow.bounds.size.height - self.backgroundView.bounds.height
                self.backgroundView.frame = backgroundFrame
            })
        } else {
            // Animate things off screen
            //
            UIView.animate(withDuration: Constant.animationSpeed, animations: {
                self.backgroundColor = UIColor.black.withAlphaComponent(0)
                backgroundFrame.origin.y = self.appWindow.bounds.size.height
                self.backgroundView.frame = backgroundFrame
            }, completion: { _ in
                self.removeFromSuperview()
            })
        }
    }

    @objc internal func done() {
        self.doneHandler(self.pickerSelection)
        self.dismissViews()
    }

    @objc internal func cancel() {
        self.cancelHandler()
        self.dismissViews()
    }

    private func setup() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(McPicker.cancel))
        tapGestureRecognizer.delegate = self
        self.addGestureRecognizer(tapGestureRecognizer)

        let fixedSpace = McPickerBarButtonItem.fixedSpace(width: appWindow.bounds.size.width * Constant.barButtonFixedSpacePadding)
        setToolbarItems(items: [fixedSpace, McPickerBarButtonItem.cancel(mcPicker: self),
                                McPickerBarButtonItem.flexibleSpace(), McPickerBarButtonItem.done(mcPicker: self), fixedSpace])

        self.backgroundColor = UIColor.black.withAlphaComponent(Constant.backgroundAlpha)
        backgroundView.backgroundColor = UIColor.white

        picker.delegate = self
        picker.dataSource = self

        sizeViews()

        // Default selection to first item per component
        //
        for (index, element) in pickerData.enumerated() {
            pickerSelection[index] = element.first
        }
    }

    private func applyToolbarButtonItemsSettings(withAction: Selector? = nil, settings: (_ barButton: UIBarButtonItem) -> Void) {
        for item in toolbar.items ?? [] {
            if let action = withAction, action == item.action {
                settings(item)
            }

            if withAction == nil {
                settings(item)
            }
        }
    }
}

extension McPicker : UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return self.numberOfComponents
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
}

extension McPicker : UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel

        if pickerLabel == nil {
            pickerLabel = UILabel()

            if let goodLabel = label {
                pickerLabel?.textAlignment = goodLabel.textAlignment
                pickerLabel?.font = goodLabel.font
                pickerLabel?.textColor = goodLabel.textColor
                pickerLabel?.backgroundColor = goodLabel.backgroundColor
                pickerLabel?.numberOfLines = goodLabel.numberOfLines
            } else {
                pickerLabel?.textAlignment = .center
                pickerLabel?.font = UIFont.systemFont(ofSize: self.fontSize)
            }
        }

        pickerLabel?.text = pickerData[component][row]

        return pickerLabel!
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Customize Cocoapod
        self.pickerSelection[component] = pickerData[component][row]
//        if let type = customizeType {
//            if (type && component == 0) {
//                let address: Metropolitan = Address.metropolitan.filter{ $0.rawValue == pickerData[0][row] }[0]
//                pickerData[1] = Address.city(metropolitan: address)
//                picker.reloadComponent(1)
//                picker.selectRow(0, inComponent: 1, animated: true)
//                pickerSelection[1] = pickerData[1][0]
//            }
//        }
    }
    
    // Customize Cocoapod
    public enum Metropolitan: String {
        case seoul = "서울특별시",
        busan = "부산광역시",
        daegu = "대구광역시",
        incheon = "인천광역시",
        gwangju = "광주광역시",
        daejeon = "대전광역시",
        ulsan = "울산광역시",
        sejong = "세종특별자치시",
        gyeonggi_N = "경기도 북부",
        gyeonggi_S = "경기도 남부",
        gangwon = "강원도",
        chungcheong_N = "충청북도",
        chungcheong_S = "충청남도",
        jeolla_N = "전라북도",
        jeolla_S = "전라남도",
        kyungsang_N = "경상북도",
        kyungsang_S = "경상남도",
        jeju = "제주특별자치도"
    }
    
    public struct Address {
        static let metropolitan: [Metropolitan] = [.seoul, .busan, .daegu, .incheon, .gwangju, .daejeon, .ulsan, .sejong, .gyeonggi_N, .gyeonggi_S, .gangwon, .chungcheong_N, .chungcheong_S, .jeolla_N, .jeolla_S, .kyungsang_N, .kyungsang_S, .jeju]
        
        static func city(metropolitan: Metropolitan) -> [String] {
            switch metropolitan {
            case .seoul:
                return ["종로구", "중구", "용산구", "성동구", "광진구", "동대문구", "중랑구", "성북구", "강북구", "도봉구", "노원구", "은평구", "서대문구", "마포구", "양천구", "강서구", "구로구", "금천구", "영등포구", "동작구", "관악구", "서초구", "강남구", "송파구", "강동구"]
            case .busan:
                return ["중구", "서구", "동구", "영도구", "부산진구", "동래구", "남구", "북구", "강서구", "해운대구", "사하구", "금정구", "연제구", "수영구", "사상구", "기장군"]
            case .daegu:
                return ["중구", "동구", "서구", "남구", "북구", "수성구", "달서구", "달성군"]
            case .incheon:
                return ["중구", "동구", "남구", "연수구", "남동구", "부평구", "계양구", "서구", "강화군", "옹진군"]
            case .gwangju:
                return ["동구", "서구", "남구", "북구", "광산구"]
            case .daejeon:
                return ["동구", "중구", "서구", "유성구", "대덕구"]
            case .ulsan:
                return ["중구", "남구", "동구", "북구", "울주군"]
            case .sejong:
                return ["세종특별자치시"]
            case .gyeonggi_N:
                return ["고양시 덕양구", "고양시 일산동구", "고양시 일산서구", "의정부시", "동두천시", "구리시", "남양주시", "파주시", "양주시", "포천시", "연천군", "가평군"]
            case .gyeonggi_S:
                return ["수원시 장안구", "수원시 권선구", "수원시 팔달구", "수원시 영통구", "성남시 수정구", "성남시 중원구", "성남시 분당구", "안양시 만안구", "안양시 동안구", "안산시 상록구", "안산시 단원구", "용인시 처인구", "용인시 기흥구", "용인시 수지구", "광명시", "평택시", "과천시", "오산시", "시흥시", "군포시", "의왕시", "하남시", "이천시", "안성시", "김포시", "화성시", "광주시", "여주시", "부천시", "양평군"]
            case .gangwon:
                return ["춘천시", "원주시", "강릉시", "동해시", "태백시", "속초시", "삼척시", "홍천군", "횡성군", "영월군", "평창군", "정선군", "철원군", "화천군", "양구군", "인제군", "고성군", "양양군"]
            case .chungcheong_N:
                return [ "청주시 상당구", "청주시 서원구", "청주시 흥덕구", "청주시 청원구", "충주시", "제천시", "보은군", "옥천군", "영동군", "진천군", "괴산군", "음성군", "단양군", "증평군"]
            case .chungcheong_S:
                return ["천안시 동남구", "천안시 서북구", "공주시", "보령시", "아산시", "서산시", "논산시", "계룡시", "당진시", "금산군", "부여군", "서천군", "청양군", "홍성군", "예산군", "태안군"]
            case .jeolla_N:
                return ["전주시 완산구", "전주시 덕진구", "군산시", "익산시", "정읍시", "남원시", "김제시", "완주군", "진안군", "무주군", "장수군", "임실군", "순창군", "고창군", "부안군"]
            case .jeolla_S:
                return ["목포시", "여수시", "순천시", "나주시", "광양시", "담양군", "곡성군", "구례군",  "고흥군", "보성군", "화순군", "장흥군", "강진군", "해남군", "영암군", "무안군", "함평군", "영광군", "장성군", "완도군", "진도군", "신안군"]
            case .kyungsang_N:
                return ["포항시 남구", "포항시 북구", "경주시", "김천시", "안동시", "구미시", "영주시", "영천시", "상주시", "문경시", "경산시", "군위군", "의성군", "청송군", "영양군", "영덕군", "청도군", "고령군", "성주군", "칠곡군", "예천군", "봉화군", "울진군", "울릉군"]
            case .kyungsang_S:
                return ["창원시 의창구", "창원시 성산구", "창원시 마산합포구", "창원시 마산회원구", "창원시 진해구", "진주시", "통영시", "사천시", "김해시", "밀양시", "거제시", "양산시", "의령군", "함안군", "창녕군", "고성군", "남해군", "하동군", "산청군", "함양군", "거창군", "합천군"]
            case .jeju:
                return ["제주시", "서귀포시"]
            }
        }
    }

}

extension McPicker : UIPopoverPresentationControllerDelegate {

    public func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        self.cancelHandler()
    }

    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // This *forces* a popover to be displayed on the iPhone
        return .none
    }

    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        // This *forces* a popover to be displayed on the iPhone X Plus
        return .none
    }
}

extension McPicker : UIGestureRecognizerDelegate {

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let goodView = touch.view {
            return goodView == self
        }
        return false
    }
}
