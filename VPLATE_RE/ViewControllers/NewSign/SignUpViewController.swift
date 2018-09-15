//
//  SignUpViewController.swift
//  VPLATE_RE
//
//  Created by KanghoonOh on 2018. 5. 21..
//  Copyright © 2018년 KanghoonOh. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import FBSDKCoreKit
import FirebaseAuth
import SwiftyJSON
import SafariServices

class SignUpViewController: UIViewController, GradientService {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var signupButton: ConfirmButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var kakaoButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var cautionLabel: ActiveLabel!
    
    let userdefault = UserDefaults.standard
    
    let spalshView = SplashView()
    
    enum SignType: Int {
        case email
        case kakaotalk
        case facebook
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupAction()
        //test(splash: self.spalshView)
    }
    
    func test(splash: SplashView) {
        splash.show(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    private func setupUI() {
        self.view.layoutIfNeeded()
        self.setGradient(view: self.backgroundView)
        
        self.signupButton.isSelected = true
        self.kakaoButton.roundBorder()
        self.facebookButton.roundBorder()
        self.kakaoButton.dropShadow()
        self.facebookButton.dropShadow()
        self.loginButton.setAttributedTitle(underLineString(title: "Log In".localized, fontSize: 12), for: .normal)
        self.setupCautionLabel()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = .clear
    }
    
    private func setupAction() {
        self.signupButton.addTarget(self, action: #selector(touchUpSignUpButton), for: .touchUpInside)
        self.loginButton.addTarget(self, action: #selector(touchUpLoginButton), for: .touchUpInside)
        self.facebookButton.addTarget(self, action: #selector(touchUpFaceBookButton), for: .touchUpInside)
        self.kakaoButton.addTarget(self, action: #selector(touchUpKaKaoButton), for: .touchUpInside)
    }
    
    private func underLineString(title: String, fontSize: CGFloat) -> NSAttributedString {
        let attrs = [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: fontSize),
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.underlineStyle : 1] as [NSAttributedStringKey : Any]
        
        return NSMutableAttributedString(string: title, attributes: attrs)
    }
    
    func cautionLabelAction(termsType: ActiveType, policyType: ActiveType) {
        cautionLabel.enabledTypes.append(termsType)
        cautionLabel.enabledTypes.append(policyType)
        
        cautionLabel.customize { label in
            label.configureLinkAttribute = { (type, attributes, _) in
                var atts = attributes
                switch type {
                case termsType:
                    atts[NSAttributedStringKey.font] = UIFont.systemFont(ofSize: 12)
                    atts[NSAttributedStringKey.foregroundColor] = UIColor.white
                    atts[NSAttributedStringKey.underlineStyle] = 1
                case policyType:
                    atts[NSAttributedStringKey.font] = UIFont.systemFont(ofSize: 12)
                    atts[NSAttributedStringKey.foregroundColor] = UIColor.white
                    atts[NSAttributedStringKey.underlineStyle] = 1
                default:
                    break
                }
                
                return atts
            }
            
            label.handleCustomTap(for: termsType) {[weak self] _ in
                guard let `self` = self, let url = URL(string: "https://www.vplate.io/vplate---%EC%86%90%EC%89%AC%EC%9A%B4-%EA%B4%91%EA%B3%A0%EC%98%81%EC%83%81-%EC%A0%9C%EC%9E%91-%ED%85%9C%ED%94%8C%EB%A6%BF-%EC%84%9C%EB%B9%84%EC%8A%A4--%EC%9D%B4%EC%9A%A9%EC%95%BD%EA%B4%80.html") else { return }
                let viewController = SFSafariViewController(url: url)
                UIApplication.shared.statusBarStyle = .default
                self.present(viewController, animated: true, completion: nil)
            }
            label.handleCustomTap(for: policyType) {[weak self] _ in
                guard let `self` = self, let url = URL(string: "https://www.vplate.io/vplate---%EC%86%90%EC%89%AC%EC%9A%B4-%EA%B4%91%EA%B3%A0%EC%98%81%EC%83%81-%EC%A0%9C%EC%9E%91-%ED%85%9C%ED%94%8C%EB%A6%BF-%EC%84%9C%EB%B9%84%EC%8A%A4---%EA%B0%9C%EC%9D%B8%EC%A0%95%EB%B3%B4%EC%B2%98%EB%A6%AC%EB%B0%A9%EC%B9%A8.html") else { return }
                let viewController = SFSafariViewController(url: url)
                UIApplication.shared.statusBarStyle = .default
                self.present(viewController, animated: true, completion: nil)
            }
        }
    }
    
    private func setupCautionLabel() {
        
        let langStr = Locale.current.languageCode // 사용자 설정 언어정보
        
        if langStr == "ko" {
            let termsType = ActiveType.custom(pattern: "\\서비스 약관\\b")
            let policyType = ActiveType.custom(pattern: "개인정보 보호정책")
            
            cautionLabelAction(termsType: termsType, policyType: policyType)
        } else {
            let termsType = ActiveType.custom(pattern: "\\Terms of Service\\b")
            let policyType = ActiveType.custom(pattern: "Privacy Policy")
            
            cautionLabelAction(termsType: termsType, policyType: policyType)
            
        }
    }
    
    private func getFacebookUserData() {
        if FBSDKAccessToken.current() == nil {
            print("Facebook Token Error")
            return
        }
        
        let connection = GraphRequestConnection()
        
        connection.add(UserDataRequest()) { [weak self]
            (response: HTTPURLResponse?, result: GraphRequestResult<UserDataRequest>) in
            guard let `self` = self else { return }
            
            switch result {
            case .success(let graphResponse) :
                print("name : \(graphResponse.name)", "id: \(graphResponse.id)", "email: \(graphResponse.email)")
                self.snsLoginButtonAction(uid: graphResponse.id, email: graphResponse.email)
            case .failed :
                break
            }
            
        }
        
        connection.start()
    }
    
    private func getKakaoTalkUserData() {
        KOSessionTask.meTask { (profile, error) in
            
            if profile != nil {
                let user: KOUser = profile as! KOUser
                let uid: String = String(describing: user.id!)
                let email = uid + "@kakao.com"
                print("\(user.id ?? 0)")
                self.snsLoginButtonAction(uid: uid, email: email)
            }
            
        }
    }
    
//    private func snsLoginAction(graphResponse: UserDataRequest.Response) {
    private func snsLoginButtonAction(uid: String, email: String?) {
        SignService.snsCheck(uid: uid) { [weak self] (result) in
            switch result {
            case .success(let msg):
                print(msg)
                if msg == "sns available" {
                    self?.snsSignUpAction(uid: uid, email: email)
                } else if msg == "sns exists" {
                    self?.snsLoginAction(uid: uid, email: email)
                    
                } else {
                }
            case .failure():
                self?.networkingError()
                
            default:
                break
            }
        }
    }
    
    //MARK: SNS Sign Up
    private func snsSignUpAction(uid: String, email: String?) {
        let storyboard = UIStoryboard(name: "Sign", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "SNSPersonalInformationViewController") as? SNSPersonalInformationViewController {
            let user: [String:String] = ["socialKey": uid,
                                         "userEmail":email ?? ""]
            viewController.user = user
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    //MARK: SNS Sign In
    private func snsLoginAction(uid: String, email: String?) {
        SignService.snsSignIn(email: email ?? "", uid: uid) { [weak self] (result) in
            switch result {
            case .success(let token):
                Token.setToken(token: token)
                self?.userdefault.set(token, forKey: "token")
                DispatchQueue.main.async {
                    UIApplication.shared.statusBarStyle = .default
                }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTab") as? UITabBarController {
                    self?.present(tabBarController, animated: true, completion: nil)
                }
            case .error(let msg):
                print(msg)
            case .failure():
                self?.networkingError()
            }
        }
    }
    
    private func snsRegisterAction(type: Int, parameter: [String:Any]) {
        SignService.getSignData(url: "user/register", parameter: parameter) { (result) in
            
            switch result {
            case .Success(let response):
                guard let data = response as? Data else { return }
                print(JSON(data))
            case .Failure(let failureCode):
                print(failureCode)
            case .FailDescription(let err):
                print(err)
            }
        }
    }
    
    private func snsLoginAction(type: Int, parameter: [String:Any]) {
        SignService.getSignData(url: "user/login", parameter: parameter) { (result) in

            switch result {
            case .Success(let response):
                guard let data = response as? Data else { return }
            case .Failure(let failureCode):
                print(failureCode)
            case .FailDescription(let err):
                print(err)
            }
        }
    }
    
    @objc func touchUpSignUpButton() {
        let storyboard = UIStoryboard(name: "Sign", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "CellPhoneViewController") as? CellPhoneViewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @objc func touchUpLoginButton() {
        let storyboard = UIStoryboard(name: "Sign", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @objc func touchUpKaKaoButton2() {
        self.view.makeToast("We're working a fixing this bug\nPlease sign in by email".localized)
    }
    
    @objc func touchUpKaKaoButton() {
        let session: KOSession = KOSession.shared()
        
        if session.isOpen() {
            session.close()
        }
        
//        session.presentingViewController = self
//        session.open(completionHandler: {(error) -> Void in
//
//            if(error == nil) {
//                if session.isOpen() {
//                    print("success")
//                    self.getKakaoTalkUserData()
//                } else {
//                    print("fail")
//                }
//            } else {
//                self.addAlert(title: "", msg: "\(error!)")
//            }
//
//        }, authTypes: [NSNumber(value: KOAuthType.talk.rawValue), NSNumber(value: KOAuthType.account.rawValue)])
        session.open(completionHandler: { (error) -> Void in
            session.presentingViewController = nil
            if(error == nil) {
                if session.isOpen() {
                    self.getKakaoTalkUserData()
                } else {
                }
            } else {
                print(error)
                //self.addAlert(title: "", msg: "\(error!)")
            }
        }, authParams: nil, authTypes: [NSNumber(value: KOAuthType.talk.rawValue), NSNumber(value: KOAuthType.account.rawValue)])
//        session.open(completionHandler: {(error) -> Void in
//            session.presentingViewController = nil
//
//            if !session.isOpen() {
//                switch ((error! as NSError).code) {
//                case Int(KOErrorCancelled.rawValue):
//                    break;
//                default:
//                    UIAlertView(title: LocalizableHelper.getLocalString("COMMON_ERROR"),
//                                message: error?.localizedDescription,
//                                delegate: nil,
//                                cancelButtonTitle: LocalizableHelper.getLocalString("COMMON_CONFIRM")).show()
//                    break;
//                }
//                self.activityIndicator?.stop()
//            } else {
//                self.requestMe()
//            }
//        }, authParams: nil, authTypes: [NSNumber(value: KOAuthType.talk.rawValue), NSNumber(value: KOAuthType.account.rawValue)])

    }

    @objc func touchUpFaceBookButton() {
        
        //self.view.makeToast("We're working a fixing this bug\nPlease sign in by email".localized)
        let loginManager = LoginManager()

        loginManager.logOut()

        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self) { (loginResult) in
            switch loginResult {
            case .success(grantedPermissions: _, declinedPermissions: _, token: _):
                self.getFacebookUserData()
            case .failed(let err as NSError):
                print(err.localizedDescription)
            case .cancelled:
                break
            }
        }
    }
}
