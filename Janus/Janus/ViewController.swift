//
//  ViewController.swift
//  Janus
//
//  Created by Will Koffel on 4/10/16.
//  Copyright © 2016 ClearlyTech. All rights reserved.
//

import UIKit
import FirebaseUI

class ViewController: UIViewController, FUIAuthDelegate {

  fileprivate(set) var auth:Auth?
  fileprivate(set) var authUI: FUIAuth? //only set internally but get externally
  fileprivate(set) var authStateListenerHandle: AuthStateDidChangeListenerHandle?
  
  let IMAGE_URL = "https://storage.googleapis.com/janus-223601/garage-image.jpg"
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  
  @IBOutlet weak var doorOneButton: UIButton!
  @IBOutlet weak var doorTwoButton: UIButton!
  @IBOutlet weak var garageImage: UIImageView!
  @IBOutlet weak var refreshSpinner: UIActivityIndicatorView!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Set up
    self.auth = Auth.auth()
    self.authUI = FUIAuth.defaultAuthUI()
    self.authUI?.delegate = self
    self.authUI?.providers = [FUIGoogleAuth(),]
    
    
    self.authStateListenerHandle = self.auth?.addStateDidChangeListener { (auth, user) in
      guard user != nil else {
        self.loginAction(sender: self)
        return
      }
    }
    
    self.newImageReady()
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

  @IBAction func doorButtonPressed(_ button: UIButton) {
    let buttonIndex = (button === doorTwoButton ? 1 : 0)
    print("door button pressed: \(buttonIndex)")
    appDelegate.publishDoorButtonMessage(buttonIndex)
  }

  @IBAction func refreshImageButtonPressed(_ button: UIButton? = nil) {
    print("refresh image button pressed")
    refreshSpinner.startAnimating()
    appDelegate.publishCaptureImageMessage()
    load_image(IMAGE_URL)
  }

  func newImageReady() {
    print("new image ready, loading")
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
