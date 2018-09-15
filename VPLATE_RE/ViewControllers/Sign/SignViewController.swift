//
//  ViewController.swift
//  VPLATE_RE
//
//  Created by 이광용 on 2018. 1. 26..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import FBSDKCoreKit
import FirebaseAuth

class SignViewController: ViewController {
//MARK -: Properties
    let fbLogInManager = LoginManager()
    
//MARK -: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fbLogInManager.logOut()
        do {
            try Auth.auth().signOut()
        }
        catch(let err) {
            print(err.localizedDescription)
        }
    }
    override func setUpViewController() {
        
    }
    
    //Facebook SignIn, SignUp
    @IBAction func touchUpFacebookSingIn(_ sender: UIButton) {
        fbLogInManager.logIn(readPermissions: [.publicProfile, .email], viewController: self) { (result) in
//            self.fbLogInManager.logOut()
            switch result {
            case .success(grantedPermissions: _, declinedPermissions: _, token: _) :
                self.getFaceBookUserData()
            case .failed(let err) :
                print(err.localizedDescription)
            case .cancelled :
                break
            }
        }
    }
    
    //KakaoTalk SignIn, SignUp
    @IBAction func touchUpKakaoSignIn(_ sender: UIButton) {
        let session: KOSession = KOSession.shared()
        if session.isOpen() {
            session.close()
        }
        print(session.accessToken)
        session.presentingViewController = self
        session.open { (error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            if session.isOpen() {
                KOSessionTask.meTask(completionHandler: { (profile, error) in
                    print(session.accessToken)
                    
                    if profile != nil {
                        let user : KOUser = profile as! KOUser
                        print(user.id)
                        if let nickname = user.properties!["nickname"] as? String {
                        
                        }
                        if let profile_image = user.properties!["profile_image"] as? String {
                            
                        }
                    }
                })
            }
        }
    }
    
    
    @IBAction func touchUpSignUp(_ sender: UIButton) {
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: PhoneAuthenticationViewController.reuseIdentifier)
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func touchUpSignIn(_ sender: UIButton) {
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: SignInViewController.reuseIdentifier)
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
    
}

//MARK -: Extension
//MARK : Sign IN
extension SignViewController {
    // Get Facebook user data
    func getFaceBookUserData() {
        if FBSDKAccessToken.current() == nil {
            print("Facebook Token Error")
            return }
        
        let connection = GraphRequestConnection()
        
        connection.add(UserDataRequest()) {
            (response: HTTPURLResponse?, result: GraphRequestResult<UserDataRequest>) in
            switch result {
            case .success(let graphResponse) :
                let token = FBSDKAccessToken.current().tokenString
                let uid = FBSDKAccessToken.current().userID
                let name = graphResponse.name
                print("token : \(token)\nuid : \(uid)\nname : \(name)")
                break
            case .failed :
                break
            }
        }
        connection.start()
    }
}
