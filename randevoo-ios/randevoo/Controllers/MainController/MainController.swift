//
//  MainController.swift
//  randevoo
//
//  Created by Lex on 8/11/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import FirebaseMessaging
import GoogleSignIn
import FBSDKLoginKit
import ObjectMapper
import AlamofireImage
import CryptoSwift
import Hydra

class MainController: UIViewController, UIScrollViewDelegate, GIDSignInDelegate, LoginButtonDelegate {

    var mainTabBarController: UITabBarController!
    
    private let defaults = UserDefaults.standard
    private let db = Firestore.firestore()
    private let storage = Storage.storage().reference()
    private let timestampHelper = TimestampHelper()
    private let usersProvider = UsersProvider()
    private let deviceProvider = DevicesProvider()
    private var switchProvider = SwitchProvider()
    private let alertHelper = AlertHelper()
    private var timer: Timer!
    
    private let totalPage: Int = 4
    private var pageControl: UIPageControl!
    private var scrollView: UIScrollView!
    private var frame: CGRect = CGRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems()
        initialView()
        setupPageControlViews()
//        initialFirebaseAuth()
        dispatchAlert()
    }
    
    private func dispatchAlert() {
        guard let personal = personalAccount else { return }
//        let personalJson = Mapper().toJSONString(personal, prettyPrint: true)!
//        print("\nPersonalJson in main: \(personalJson)")
        if personal.isBanned {
            alertHelper.showAlert(title: "Notice😈", alert: "Your account has been banned!🧐\nPlease contact our support info@randevoo.app", controller: self)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
          if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
            print("The user has not signed in before or they have since signed out.")
          } else {
            print("\(error.localizedDescription)")
          }
          return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        firebaseGoogle(googleUser: user, authCredential: credential)
        // Perform any operations on signed in user here.
        let userId = user.userID!               // For client-side use only!
//        let idToken = user.authentication.idToken // Safe to send to the server
        let fullName = user.profile.name!
        let email = user.profile.email!
        print("This is my signin email \(String(email))")
        print("This is my fullname \(String(fullName))")
//        print("Checking profile Url \(user.)")
        print("Checking userID \(String(userId))")
        print("Checking user profile: ", user.profile.imageURL(withDimension: 1000)!)
//        checkExitsGoogleAccount(user: user)
    }
    
    private func firebaseGoogle(googleUser: GIDGoogleUser, authCredential: AuthCredential) {
        Auth.auth().signIn(with: authCredential) { (authResult, error) in
            if let error = error {
            let authError = error as NSError
                print("Firebase auth error", authError)
                return
            }
            print("Google is signed")
            print(authResult!)
            if let user = Auth.auth().currentUser {
                print("Current google sign in user")
                print(user)
            }
            self.validateUserStatus(firebaseAuth: Auth.auth(), googleUser: googleUser, provider: "Google")
        }
    }
    
    private func validateLoginStatus(personalAccount: PersonalAccount) {
        isSignIn = true
        print("Checking SignIn: \(isSignIn)")
        
        switchProvider.startSwitchAccount(mainTabBarController: mainTabBarController, accountId: personalAccount.id, isPersonal: true, selectFirst: true)
        
        let initiateSignIn = ["isSignIn": true] as [String: Any]
        self.defaults.set(initiateSignIn, forKey: "signIn")
        self.dismiss(animated: true, completion: nil)
    }
    
    private func validateUserStatus(firebaseAuth: Auth, googleUser: GIDGoogleUser, provider: String) {
        isProviderExisted(firebaseAuth: firebaseAuth).then { (isExisted) in
            if !isExisted {
                let _ = async { (_) -> (Bool, PersonalAccount) in
                    let generatetUsername = try await(self.usersProvider.findUsernameViaEmail(email: googleUser.profile.email))
                    let profileUrl = try await(self.fetchGoogleProfile(googleUser: googleUser))
                    let personalAccount = try await(self.createUser(name: googleUser.profile.name, username: generatetUsername, profileUrl: profileUrl))
                    let result = try await(self.createProvider(authUUID: firebaseAuth.currentUser!.uid, email: googleUser.profile.email, userId: personalAccount.id, providerName: "Google"))
                    return (result, personalAccount)
                }.then { (result, personalAccount) in
                    self.validateLoginStatus(personalAccount: personalAccount)
                    print("Account has been created successfully")
                    self.deviceProvider.validateDeviceToken(accountId: personalAccount.id)
                }
            } else {
                self.fetchPersonalAccount(providerId: firebaseAuth.currentUser!.uid).then { (personalData) in
                    personalAccount = personalData
                    if personalData.isBanned {
                        self.dispatchAlert()
                        
                        do {
                            let firebaseAuth = Auth.auth()
                            try firebaseAuth.signOut()
                        } catch let signOutError as NSError {
                            print ("Error signing out: %@", signOutError)
                        }
                    } else {
                        self.validateLoginStatus(personalAccount: personalData)
                        print("This Account is already existed")
                        self.deviceProvider.validateDeviceToken(accountId: personalData.id)
                    }
                }
            }
        }
    }
    
    private func fetchPersonalAccount(providerId: String) -> Promise<PersonalAccount> {
        return Promise<PersonalAccount>(in: .background) { (resolve, reject, _) in
            self.db.collection("providers").document(providerId).getDocument { (document, error) in
                if let document = document, document.exists {
                    self.db.collection("users").document(document.data()!["userId"] as! String).getDocument { (document, error) in
                        if let document = document, document.exists {
                            let personalAccount = Mapper<PersonalAccount>().map(JSONObject: document.data())!
                            FCache.set(personalAccount, key: "personal")
                            print("Personal Information Data has been added into Cache fetch during login")
                            resolve(personalAccount)
                        } else {
                            print("Document does not exist")
                            reject(error!)
                        }
                    }
                    // Handle in the future when has provider but has no user
                } else {
                    print("Document does not exist")
                    reject(error!)
                }
            }
        }
    }
    
    private func isProviderExisted(firebaseAuth: Auth) -> Promise<Bool> {
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            self.db.collection("providers").document(firebaseAuth.currentUser!.uid).getDocument { (document, error) in
                if let document = document, document.exists {
                    print("This Google account is exist!")
                    resolve(true)
                } else {
                    print("This Google account does not exist!")
                    resolve(false)
                }
            }
        }
    }
    
    func fetchGoogleProfile(googleUser: GIDGoogleUser) -> Promise<String> {
        return Promise<String>(in: .background) { (resolve, reject, _) in
            if let photoUrl = googleUser.profile.imageURL(withDimension: 1000) {
                print("this is this profile url", photoUrl)
                let downloader = ImageDownloader()
                let urlRequest = URLRequest(url: photoUrl)
                downloader.download(urlRequest, completion:  { response in
                    if case .success(let image) = response.result {
                        let filename = NSUUID().uuidString
                        let uploadData = image.jpegData(compressionQuality: 0.3)
                        let storage = Storage.storage().reference().child("profile_images").child(filename)
                        storage.putData(uploadData!, metadata: nil) { (metadata, err) in
                            if let err = err {
                                print("Failed to upload profile photo \(err)")
                                resolve("")
                            }
                            storage.downloadURL(completion: { (downloadURL, err) in
                                resolve(downloadURL!.absoluteString)
                                print("Successful")
                            })
                        }
                    }
                })
            } else {
                print("this user doesn't have a profile")
                resolve("")
            }
        }
    }
    
    func createUser(name: String, username: String, profileUrl: String) -> Promise<PersonalAccount> {
        let userRef = db.collection("users")
        let userId = userRef.document().documentID
        let personalAccount = PersonalAccount(id: userId, name: name, username: username, profileUrl: profileUrl, createdAt: Date().iso8601withFractionalSeconds)
        return Promise<PersonalAccount>(in: .background) { (resolve, reject, _) in
            userRef.document(userId).setData(personalAccount.toJSON()) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    reject(err)
                } else {
                    print("Document successfully written!")
                    FCache.set(personalAccount, key: "personal")
                    resolve(personalAccount)
                }
            }
        }
    }
    
    func createProvider(authUUID: String, email: String, userId: String, providerName: String) -> Promise<Bool> {
        let firestoreProvider = db.collection("providers")
        let provider = Provider(id: authUUID, userId: userId, name: providerName, email: email, createdAt: Date().iso8601withFractionalSeconds, isCurrent: true)
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            firestoreProvider.document(authUUID).setData(provider.toJSON()) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    reject(err)
                } else {
                    print("Document successfully written!")
                    resolve(true)
                }
            }
        }
    }
    
    private func initialFirebaseAuth() {
        let firebaseAuth = Auth.auth()
        if let user = firebaseAuth.currentUser {
            print("Current sign in user")
            print(user.displayName!)
            print(user.uid)
//            
//            do {
//                try firebaseAuth.signOut()
//            } catch let signOutError as NSError {
//                print ("Error signing out: %@", signOutError)
//            }
//            fetchGoogleProfile(firebaseAuth: firebaseAuth) { (check) in
//                print(check)
//            }
        } else {
            print("No current sign in exits & auth")
        }
    }
    
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("User logged out")
    }
    
    func firebaseFacebook(accessToken: String) {
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                let authError = error as NSError
                print("Facebook SignIn Error")
                print(authError)
                return
            }
            // User is signed in
            // ...
            print("Successful")
            print(authResult!)
            if let user = Auth.auth().currentUser {
                print("Current facebook sign in user")
                print(user)
            }
        }
    }
    
    @IBAction func handleGoogle(_ sender: Any?) {
        print("Click Google")
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func handleFacebook(_ sender: Any?) {
        print("Click Facebook")
        alertHelper.showAlert(title: "Notice", alert: "Facebook Sign In is under maintenance", controller: self)
        // 1
//        let loginManager = LoginManager()
//
//        if let token = AccessToken.current {
//            // Access token available -- user already logged in
//            // Perform log out
//            if !token.isExpired {
//
//                // User is logged in, do work such as go to next view controller.
//            } else {
//                // 2
//                loginManager.logOut()
//            }
//        } else {
//            // Access token not available -- user already logged out
//            // Perform sign in
//
//            // 3
//            loginManager.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
//                // 4
//                // Check for error
//                guard error == nil else {
//                    // Error occurred
//                    print(error!.localizedDescription)
//                    return
//                }
//
//                // 5
//                // Check for cancel
//                guard let result = result, !result.isCancelled else {
//                    print("User cancelled sign in")
//                    return
//                }
//            }
//        }
    }
    
    private func generateView(viewIndex: Int, frame: CGRect) -> UIView {
        switch viewIndex {
        case 0:
            return MainFirstView(frame: frame)
        case 1:
            return MainSecondView(frame: frame)
        case 2:
            return MainThirdView(frame: frame)
        case 3:
            return MainFourthView(frame: frame)
        default:
            return MainFirstView(frame: frame)
        }
    }
    
    private func initialView() {
        let view = MainView(frame: self.view.frame)
        self.scrollView = view.scrollView
        self.pageControl = view.pageControl
        self.pageControl.numberOfPages = totalPage
        self.scrollView.delegate = self
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        self.view = view
    }
    
    private func setupPageControlViews() {
        for index in 0..<totalPage {
            frame.origin.x = self.view.frame.width * CGFloat(index)
            frame.size = self.view.frame.size
            let subView = generateView(viewIndex: index, frame: frame)
            self.scrollView.addSubview(subView)
        }
        self.scrollView.contentSize = CGSize(width: self.view.frame.width * CGFloat(totalPage), height: self.frame.width - 40 + 100)
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(intervalPages(_:)), userInfo: nil, repeats: true)
    }
    
    @IBAction func intervalPages(_ sender: Any?) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        if pageNumber == 3 {
            pageControl.currentPage = 0
        } else {
            pageControl.currentPage = Int(pageNumber) + 1
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            let x = CGFloat(self.pageControl.currentPage) * self.scrollView.frame.size.width
            self.scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        }, completion: nil)
    }
    
    @IBAction func changePage(_ sender: Any?) {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        print("Checking page number", pageNumber)
        pageControl.currentPage = Int(pageNumber)
    }
    
    private func handleHashData() {
        let value = "thisismypassword"
        let hash = value.sha256()
        print("This is SHA256 \(String(hash))")
    }
    
    @IBAction func handleSkip(_ sender: Any?) {
        let mainTabBarController = MainTabBarController()
        mainTabBarController.modalPresentationStyle = .fullScreen
        self.present(mainTabBarController, animated: true, completion: nil)
    }
    
    private func setupNavItems() {
        let skipBarButton = UIBarButtonItem(title: "Skip", style: .plain, target: self, action: #selector(handleSkip(_:)))
        skipBarButton.tintColor = UIColor.randevoo.mainBlueGrey
//        navigationItem.leftBarButtonItem = skipBarButton
    }
}
