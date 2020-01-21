//
//  ViewController.swift
//  Janus
//
//  Created by Will Koffel on 4/10/16.
//  Copyright © 2016 ClearlyTech. All rights reserved.
//

import UIKit

import Firebase
import FirebaseUI

class ViewController: UIViewController, FUIAuthDelegate {

  fileprivate(set) var auth:Auth?
  fileprivate(set) var authUI: FUIAuth? //only set internally but get externally
  fileprivate(set) var authStateListenerHandle: AuthStateDidChangeListenerHandle?
  var currentUser: User?
  
  let IMAGE_URL = "https://storage.googleapis.com/janus-223601/garage-image.jpg"
//  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  
  var firestoreDB: Firestore?

  @IBOutlet weak var doorOneButton: UIButton!
  @IBOutlet weak var doorTwoButton: UIButton!
  @IBOutlet weak var garageImage: UIImageView!
  @IBOutlet weak var refreshSpinner: UIActivityIndicatorView!
  @IBOutlet weak var logoutButton: UIButton!
  @IBOutlet weak var userLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // FireStore Setup
    firestoreDB = Firestore.firestore()
    let settings = firestoreDB!.settings
    settings.areTimestampsInSnapshotsEnabled = true
    firestoreDB!.settings = settings
    

    // Auth Set up
    self.auth = Auth.auth()
    self.authUI = FUIAuth.defaultAuthUI()
    self.authUI?.delegate = self
    self.authUI?.providers = [FUIGoogleAuth(),]
    
    self.authStateListenerHandle = self.auth?.addStateDidChangeListener { (auth, user) in
      guard user != nil else {
        self.loginAction(sender: self)
        return
      }
      print("We have user: \(String(describing: user))")
      self.currentUser = user
      self.userLabel.text = user?.email
    }
    
    self.newImageReady()
    
    // Listen for completions to image requests to
    // trigger updates of the UIImage
    firestoreDB?.collection("image_requests").whereField("status", isEqualTo: "pending")
      .addSnapshotListener { querySnapshot, error in
        guard let snapshot = querySnapshot else {
          print("Error fetching snapshots: \(error!)")
          return
        }
        snapshot.documentChanges.forEach { diff in
          // This is a bit of a hack, but basically if a "pending" image
          // request is removed from this query, it's likely to mean that
          // it was "completed".  We'll take that as an indicator to fetch a new
          // image.  No real harm if actually it timedout, refreshing doesn't hurt
          // us here.
          if (diff.type == .removed) {
            print("Probably completed image_request: \(diff.document.data())")
            self.newImageReady()
          }
        }
    }
  }

  @IBAction func loginAction(sender: AnyObject) {
    // Present the default login view controller provided by authUI
    let authViewController = authUI?.authViewController();
    self.present(authViewController!, animated: true, completion: nil)
  }
  
  // Implement the required protocol method for FUIAuthDelegate
  func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
    guard let authError = error else { return }
    
    let errorCode = UInt((authError as NSError).code)
    
    switch errorCode {
    case FUIAuthErrorCode.userCancelledSignIn.rawValue:
      print("User cancelled sign-in");
      break
      
    default:
      let detailedError = (authError as NSError).userInfo[NSUnderlyingErrorKey] ?? authError
      print("Login error: \((detailedError as! NSError).localizedDescription)");
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func logoutAction(_ button: UIButton) {
    do{
      try self.authUI?.signOut()
      currentUser = nil
      print("Logged Out")
    }catch{
      print("Error while signing out!")
    }
  }
  
  @IBAction func doorButtonPressed(_ button: UIButton) {
    let buttonIndex = (button === doorTwoButton ? 1 : 0)
    print("door button pressed: \(buttonIndex)")
    var ref: DocumentReference? = nil
    ref = firestoreDB?.collection("door_requests").addDocument(data: [
      "door": buttonIndex,
      "requested_at": FieldValue.serverTimestamp(),
      "status": "pending",
      "user": self.currentUser?.email as Any
    ]) { err in
      if let err = err {
        print("Error sending door_request: \(err)")
      } else {
        print("Published door_request \(buttonIndex) with ID: \(ref!.documentID)")
      }
    }
  }

  @IBAction func refreshImageButtonPressed(_ button: UIButton? = nil) {
    print("refresh image button pressed")
    refreshSpinner.startAnimating()
    var ref: DocumentReference? = nil
    ref = firestoreDB?.collection("image_requests").addDocument(data: [
      "requested_at": FieldValue.serverTimestamp(),
      "status": "pending",
      "user": self.currentUser!.email as Any
    ]) { err in
      if let err = err {
        print("Error sending image_request: \(err)")
      } else {
        print("Published image_request with ID: \(ref!.documentID)")
      }
    }
    load_image(IMAGE_URL)
  }

  func newImageReady() {
    print("loading new image")
    refreshSpinner.stopAnimating()
    load_image(IMAGE_URL)
  }
  
  func load_image(_ urlString:String)
  {
    let imgURL: URL = URL(string: urlString)!
    let request: URLRequest = URLRequest(url: imgURL, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 5.0)
    
    let session = URLSession.shared
    let task = session.dataTask(with: request, completionHandler: {
      (data, response, error) -> Void in
      
      if (error == nil && data != nil)
      {
        func display_image()
        {
          self.garageImage.image = UIImage(data: data!)
        }
        
        DispatchQueue.main.async(execute: display_image)
      }
      
    })
    
    task.resume()
  }

}

extension FUIAuthBaseViewController{
  open override func viewWillAppear(_ animated: Bool) {
    self.navigationItem.leftBarButtonItem = nil
  }
}

