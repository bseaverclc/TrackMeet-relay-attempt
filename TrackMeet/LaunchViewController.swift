//
//  LaunchViewController.swift
//  TrackMeet
//
//  Created by Brian Seaver on 7/13/20.
//  Copyright © 2020 clc.seaver. All rights reserved.
//  This is the Real One!  1.9.3

import UIKit
import SafariServices
import FirebaseDatabase
import GoogleSignIn
import Firebase
import AuthenticationServices
import CryptoKit

class AppData{
    static var meets = [Meet]()
    static var allAthletes = [Athlete]()
    //static var schools = [String:String]()
    static var userID = ""
    static var coach = ""
    static var manager = ""
    static var schoolsNew = [School]()
}


@available(iOS 13.0, *)
class LaunchViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    @IBOutlet weak var loginStackView: UIStackView!
    @IBOutlet weak var appleButton: UIButton!
    @IBOutlet weak var SignInOutlet: UIButton!
    @IBOutlet weak var QuickMeetLabel: UILabel!
    @IBOutlet weak var nameOutlet: UILabel!
    
    @IBOutlet weak var logOutOutlet: UIButton!
    @IBOutlet weak var logInOutlet: GIDSignInButton!
    let authorizationButton = ASAuthorizationAppleIDButton()
    //var meets = [Meet]()
    //var allAthletes = [Athlete]()
   // var schools = [String:String]()
    
    fileprivate var currentNonce: String?
    
    var initials = [String]()
    
    var errorMessage = ""
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        self.navigationController?.toolbar.isHidden = true
    
    }
    override func viewDidAppear(_ animated: Bool) {
        print("View Did appear")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
     
        //storeToUserDefaults()
    }
    
    
    

    
    @objc func didSignIn(){
        
        //if let blah = GID
        if let user = Auth.auth().currentUser{
            AppData.userID = user.uid
           
            nameOutlet.text = "\(user.email!)"
            logInOutlet.isHidden = true
            logOutOutlet.isHidden = false
            authorizationButton.isHidden = true
        }
       else{
            nameOutlet.text = "Not Logged in"
        logInOutlet.isHidden = false
        logOutOutlet.isHidden = true
        authorizationButton.isHidden = false
       }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logInOutlet.layer.cornerRadius = 20
        NotificationCenter.default.addObserver(self, selector: #selector(didSignIn), name: NSNotification.Name("SuccessfulSignInNotification"), object: nil)
        GIDSignIn.sharedInstance().presentingViewController = self
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
        didSignIn()
        
        //Creating login with apple button
        
          authorizationButton.addTarget(self, action: #selector(handleLogInWithAppleIDButtonPress), for: .touchUpInside)
          authorizationButton.cornerRadius = 10
        loginStackView.addArrangedSubview(authorizationButton)
        
    
        
        
        print("view is loading")
       
                    
        //QuickMeetLabel.text = QuickMeetLabel.text! + "\n1.9.2"
        self.title = "Home"
        self.navigationController?.toolbar.isHidden = true
       
        getAthletesFromFirebase()
        
        //storeSchoolsToFirebase()
        getSchoolsFromFirebase()
        getMeetsFromFirebase()
        athleteChangedInFirebase2()
        athleteDeletedInFirebase()
        beenScoredChangedInFirebase()
        updateMeetFromFirebase()
     
      
    
        
        AppData.allAthletes.sort(by: {$0.last.localizedCaseInsensitiveCompare($1.last) == .orderedAscending})

    }
    
    @objc private func handleLogInWithAppleIDButtonPress() {
        startSignInWithAppleFlow()
        
//        let appleIDProvider = ASAuthorizationAppleIDProvider()
//        let request = appleIDProvider.createRequest()
//        request.requestedScopes = [.fullName, .email]
//        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//        authorizationController.delegate = self
//        authorizationController.performRequests()
//        print("Done handling log in")
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        print("presentationAnchor function")
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
          guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
          }
          guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token")
            return
          }
          guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return
          }
          // Initialize a Firebase credential.
          let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                    idToken: idTokenString,
                                                    rawNonce: nonce)
          // Sign in with Firebase.
          Auth.auth().signIn(with: credential) { (authResult, error) in
            if (error != nil) {
              // Error. If error.code == .MissingOrInvalidNonce, make sure
              // you're sending the SHA256-hashed nonce as a hex string with
              // your request to Apple.
              print(error!.localizedDescription)
              return
            }
            // User is signed in to Firebase with Apple.
            print(Auth.auth().currentUser?.email)
            print(Auth.auth().currentUser?.uid)
            
            if let user = Auth.auth().currentUser{
                AppData.userID = user.uid
               
                self.nameOutlet.text = "\(user.email!)"
                self.logInOutlet.isHidden = true
                self.logOutOutlet.isHidden = false
                self.authorizationButton.isHidden = true
            }
           else{
            self.nameOutlet.text = "Not Logged in"
            self.logInOutlet.isHidden = false
            self.logOutOutlet.isHidden = true
            self.authorizationButton.isHidden = false
           }
          }
        }
      }

      func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
      }
    
  
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }
   
    
//    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
      let nonce = randomNonceString()
      currentNonce = nonce
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      request.nonce = sha256(nonce)

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
    
    
    
    
   
    

    @IBAction func logInAction(_ sender: GIDSignInButton) {
        
    }
    
    
    @IBAction func logOutAction(_ sender: UIButton) {
        //GIDSignIn.sharedInstance().signOut()
        print(GIDSignIn.sharedInstance()?.currentUser != nil) // true - signed in
        GIDSignIn.sharedInstance()?.signOut()
        print(GIDSignIn.sharedInstance()?.currentUser != nil) // false - signed out
        
        let firebaseAuth = Auth.auth()
      do {
        try firebaseAuth.signOut()
        AppData.userID = ""
      } catch let signOutError as NSError {
        print ("Error signing out: %@", signOutError)
      }
        
        //if let blah = GID
        if let user = Auth.auth().currentUser{
            AppData.userID = user.uid
           
            nameOutlet.text = "Welcome \(user.displayName!)"
            logInOutlet.isHidden = true
            logOutOutlet.isHidden = false
            authorizationButton.isHidden = true
        }
       else{
            nameOutlet.text = "Not Logged in"
        logInOutlet.isHidden = false
        logOutOutlet.isHidden = true
        authorizationButton.isHidden = false
       }
    }
    

  
    @IBAction func athleticNetAction(_ sender: UIButton) {
        if let url = URL(string: "https://www.athletic.net/TrackAndField/Illinois/") {
            UIApplication.shared.open(url)
        }
        
//        let url = URL(string: "https://www.athletic.net/TrackAndField/Illinois/")
//        let svc = SFSafariViewController(url: url!)
//        present(svc, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMeetsSegue"{
           // letnvc = segue.destination as! MeetsViewController
            //nvc.allAthletes = allAthletes
            //nvc.meets = meets
           // nvc.schools = schools
            print("sent stuff to meets")
        }
        else{
          //  let nvc = segue.destination as! SchoolsViewController
            //nvc.allAthletes = allAthletes
           // nvc.schools = schools
           // nvc.meets = meets
        }
    }
    
    @IBAction func unwind3(_ seg: UIStoryboardSegue){
          // let pvc = seg.source as! SchoolsViewController
           //allAthletes = pvc.allAthletes
       // schools = pvc.schools
        //meets = pvc.meets
           print("unwinding from Schools VC")
       }
    
    @IBAction func unwindFromMeets(_ seg: UIStoryboardSegue){
             // let pvc = seg.source as! MeetsViewController
             // allAthletes = pvc.allAthletes
              //schools = pvc.schools
             // meets = pvc.meets
             // print("unwinding from Meets VC")
          }
    
//    func storeSchoolsToFirebase(){
//        let ref = Database.database().reference().child("schools")
//        ref.updateChildValues(Data.schools)
//
//    }
    
    
    
    func getSchoolsFromFirebase(){
//        var ref: DatabaseReference!
//
//        ref = Database.database().reference()
//        ref.child("schools").observe(.childAdded, with: { (snapshot) in
//            Data.schools = snapshot.value as! [String:String]
//        })
        
        // works if a school is there already
//        ref.child("schools").observeSingleEvent(of: .value, with: { (snapshot) in
//            Data.schools = snapshot.value as! [String:String]
//            print("got schools from firebase \(Data.schools)")
//        })
        
        let ref2 = Database.database().reference()
        ref2.child("schoolsNew").observe(.childAdded, with: { (snapshot) in

            let dict = snapshot.value as! [String:Any]
            let s = School(key: snapshot.key, dict: dict)
            if AppData.schoolsNew.contains(where: {$0.uid == s.uid}){
                print("school already in AppData.schoolsNew")
            }
            else{
            AppData.schoolsNew.append(s)
            }
            print("added a schoolsNew \(s.full)")
        })
        
        ref2.child("schoolsNew").observe(.childChanged, with: { (snapshot) in
            let uid = snapshot.key
            let dict = snapshot.value as! [String:Any]
            let school = School(key: snapshot.key, dict: dict)

          for i in 0..<AppData.schoolsNew.count{
                if(AppData.schoolsNew[i].uid == uid){
                   AppData.schoolsNew[i] = school
                    print("SchoolNew \(i)Changed \(AppData.schoolsNew[i].full)")
                }
                }

        })
        
        ref2.child("schoolsNew").observe(.childRemoved) { (snapshot) in
            print("a school has been removed from firebase")
            let key = snapshot.key
            AppData.schoolsNew.removeAll(where: {$0.uid == key})
            
        }
        
        
       
    }
    
    func getMeetsFromFirebase(){
        var ref: DatabaseReference!

        ref = Database.database().reference()
        ref.child("meets").observe(.childAdded, with: { (snapshot) in
            
            let dict = snapshot.value as! [String:Any]
            AppData.meets.append(Meet(key: snapshot.key, dict: dict))
        })
        
        
        
//        ref.child("meets").observe(.childRemoved, with: { (snapshot) in
//            let dict = snapshot.value as! [String:Any]
//            for i in 0..<Data.meets.count{
//                if let n = dict["name"] as? String{
//                    if Data.meets[i].name == n{
//                        Data.meets.remove(at: i)
//                        break
//
//                    }
//                }
//            }
//        })
       
    }
    
    func updateMeetFromFirebase(){
        var ref: DatabaseReference!

        ref = Database.database().reference()
        ref.child("meets").observe(.childChanged, with: { (snapshot) in
            print("A meet has changed on firebase!")
            let dict = snapshot.value as! [String:Any]
            for i in 0..<AppData.meets.count{
                if AppData.meets[i].uid == snapshot.key{
                    AppData.meets[i] = Meet(key: snapshot.key, dict: dict)
                    print("Changed the meet in Data.meets")
                }
            }
           // Data.meets.append(Meet(key: snapshot.key, dict: dict))
        })
    }
    
    func getAthletesFromFirebase(){
        var ref: DatabaseReference!
        var handle1 : UInt! // These did not work!
        var handle2 : UInt!  // These did not work!

        ref = Database.database().reference()
        
        handle1 = ref.child("athletes").observe(.childAdded) { (snapshot) in
            //print("athlete observed")
            let uid = snapshot.key
            //print(uid)
           
            guard let dict = snapshot.value as? [String:Any]
            else{ print("Error")
                return
            }
            
            var addAth = true
            let a = Athlete(key: uid, dict: dict)
            for ath in AppData.allAthletes{
                if ath.uid == a.uid{
                    addAth = false
                }
            }
            if addAth{
            AppData.allAthletes.append(a)
            //print("Added Athlete to allAthletes \(AppData.allAthletes[Data.allAthletes.count-1].first) ")
            }
            for e in a.events{
                //print(e.name)
            }
            handle2 = ref.child("athletes").child(uid).child("events").observe(.childAdded) { (snapshot2) in
                guard let dict2 = snapshot2.value as? [String:Any]
                else{ print("Error")
                    return
                }
//                print("printing events")
//                print(dict2)
                var add = true
                for e in a.events{
                    if dict2["name"] as! String == e.name && dict2["meetName"] as! String == e.meetName{
                        add = false
                    }
                }
                if add{
                a.addEvent(key: snapshot2.key, dict: dict2)
                //print("Added Event")
                //print("\(a.first) \(a.events[a.events.count-1].name)")
                }
                
            }
            ref.removeObserver(withHandle: handle2)
            //print("removing handle2")
               }
        
        ref.removeObserver(withHandle: handle1)
        //print("removing handle1")
        
        ref.removeAllObservers()
    }
    
    func athleteChangedInFirebase2(){
        var ref: DatabaseReference!

        ref = Database.database().reference()
        
        ref.child("athletes").observe(.childChanged) { (snapshot) in
            //print("athlete observed2")
            let uid = snapshot.key
            //print(uid)
           
            guard let dict = snapshot.value as? [String:Any]
            else{ print("Error")
                return
            }
            
            
            let a = Athlete(key: uid, dict: dict)
            
           // Data.allAthletes.append(a)
           // ref.child("athletes").child(uid).child("events").
            ref.child("athletes").child(uid).child("events").observe(.childRemoved, with: { (snapshot2) in
                print("event removed")
            })
            
            
            ref.child("athletes").child(uid).child("events").observe(.childAdded, with: { (snapshot2) in
                //print("snapshot2 \(snapshot2)")
                
                    
                
                guard let dict2 = snapshot2.value as? [String:Any]
                else{ print("Error")
                    return
                }
                
                var add = true
                for e in a.events{
                    if dict2["name"] as! String == e.name && dict2["meetName"] as! String == e.meetName{
                        add = false
                    }
                }
                if add{
                a.addEvent(key: snapshot2.key, dict: dict2)
                print("in changed event added")
                
                }
                    
                
                
            })
        
               
        
        for i in 0..<AppData.allAthletes.count{
            if(AppData.allAthletes[i].uid == uid){
                AppData.allAthletes[i] = a
                print("Athlete \(i)Changed \(AppData.allAthletes[i].last)")
            }
        
                
            }
            
        }
          
                
//                print("printing events")
//                print(dict2)
                
    }
    
    func athleteDeletedInFirebase(){
        var ref: DatabaseReference!
        print("Removing athleted observed")
        ref = Database.database().reference()
        ref.child("athletes").observe(.childRemoved, with: { (snapshot) in
            print("Removing athleted observed from Array")
            for i in 0..<AppData.allAthletes.count{
                
                if AppData.allAthletes[i].uid == snapshot.key{
                    print("\(AppData.allAthletes[i].last) has been removed")
                    AppData.allAthletes.remove(at: i)
                    break
                }
            }
            
        })
    }
    
    func readCSVURL(csvURL: String, fullSchool: String, initSchool: String){
            var urlCut = csvURL
            if csvURL != ""{
                if let editRange = csvURL.range(of: "/edit"){
                let start = editRange.lowerBound
                urlCut = String(csvURL[csvURL.startIndex..<start])
                }
                let urlcompleted = urlCut + "/pub?output=csv"
                let url = URL(string: String(urlcompleted))
                print(url ?? "URL Reading Didn't work")
                
                     guard let requestUrl = url else {
                        //fatalError()
                        print("fatal error")
                        return
                }
                     // Create URL Request
                     var request = URLRequest(url: requestUrl)
                     // Specify HTTP Method to use
                     request.httpMethod = "GET"
                
                     // Send HTTP Request
                     let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                       
                         // Check if Error took place
                         if let error = error {
                             print("Error took place \(error)")
    //                        let alert = UIAlertController(title: "Error!", message: "Could not load athletes", preferredStyle: .alert)
    //                        let ok = UIAlertAction(title: "ok", style: .default)
    //                        alert.addAction(ok)
    //                        self.present(alert, animated: true, completion: nil)
                            //self.showAlert(errorMessage: "Error loading Athletes from file")
                             
                         }
                         
                         // Read HTTP Response Status code
                         if let response = response as? HTTPURLResponse {
                             print("Response HTTP Status code: \(response.statusCode)")
                           
                            //return
                         }
                         
                         
                         // Convert HTTP Response Data to a simple String
                         if let data = data, let dataString = String(data: data, encoding: .utf8) {
                             print("Response data string:\n \(dataString)")
                             let rows = dataString.components(separatedBy: "\r\n")
                             for row in rows{
                                
                                let person = [String](row.components(separatedBy: ","))
                                if person[0] != "First"{
                                    let athlete = Athlete(f: person[0], l: person[1], s: initSchool, g: Int(person[2])!, sf: fullSchool)
                                print(athlete)
                                    AppData.allAthletes.append(athlete)
                                }
                                 
                             }
                         }
                         
                            
                         

                        
                     }
                     task.resume()
            
        }
        
        
    }
}

func beenScoredChangedInFirebase(){
    var ref: DatabaseReference!

    ref = Database.database().reference()
    
    ref.child("meets").observe(.childChanged) { (snapshot) in
        print("meet changed")
        print(snapshot.key)
        let uid = snapshot.key
        for meet in AppData.meets{
            print("looping through meets")
            if meet.uid == uid{
                
                guard let dict = snapshot.value as? [String:Any]
                else{ print("Error")
                    return
                }
                meet.beenScored =  dict["beenScored"] as! Array
                print("Heard beenScored change in firebase and updated")
                print(meet.beenScored)
            }
        }
    }
}

// create account with email and password firebase
//func createAccount(email: String, password: String){
//
//    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
//      if let error = error as? NSError {
//        switch AuthErrorCode(rawValue: error.code) {
//        case .operationNotAllowed:
//            self.errorMessage = "The given sign-in provider is disabled for this Firebase project."
//        case .emailAlreadyInUse:
//            self.errorMessage = "The email address is already in use by another account."
//
//        case .invalidEmail:
//            self.errorMessage = "The email address is badly formatted."
//
//        case .weakPassword:
//            self.errorMessage = "The password must be 6 characters long or more."
//        // Error:
//        default:
//            self.errorMessage = "Error: \(error.localizedDescription)"
//        }
//        let signAlert = UIAlertController(title: "Error", message: self.errorMessage, preferredStyle: .alert)
//        signAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        self.present(signAlert, animated: true, completion: nil)
//      } else {
//        print("User signs up successfully")
//        if let user = Auth.auth().currentUser{
//            Data.userID = user.uid
//
//            self.nameOutlet.text = "\(user.email!)"
//            //self.logInOutlet.isHidden = true
//            //self.logOutOutlet.isHidden = false
//
//
//      }
//
//
//    }
//}
//}

// Sign in with username and password
//func signIn2(email: String, password: String){
//    print("signIn2 being called")
//    Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
//      if let error = error as? NSError {
//        switch AuthErrorCode(rawValue: error.code) {
//        case .operationNotAllowed:
//            self.errorMessage = "username/password not enabled in firebase"
//        case .userDisabled:
//            self.errorMessage = "The user account has been disabled by an administrator."
//        case .wrongPassword:
//            self.errorMessage = "The password is invalid or the user does not have a password."
//        case .invalidEmail:
//            self.errorMessage = "The email address is malformed."
//        default:
//            print("Error: \(error.localizedDescription)")
//
//        }
//      } else {
//        print("User signs in successfully")
//
//        if let user = Auth.auth().currentUser{
//            Data.userID = user.uid
//
//            self.nameOutlet.text = "\(user.email!)"
//           // self.logInOutlet.isHidden = true
//           // self.logOutOutlet.isHidden = false
//      }
//    }
//}
//}
