//
//  ViewController.swift
//  Janus
//
//  Created by Will Koffel on 4/10/16.
//  Copyright © 2016 ClearlyTech. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  let IMAGE_URL = "https://clearlytech.s3.amazonaws.com/garage-image.jpg"
  let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
  
  @IBOutlet weak var doorOneButton: UIButton!
  @IBOutlet weak var doorTwoButton: UIButton!
  @IBOutlet weak var garageImage: UIImageView!
  @IBOutlet weak var refreshSpinner: UIActivityIndicatorView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
//    self.refreshImageButtonPressed()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func doorButtonPressed(button: UIButton) {
    let buttonIndex = (button === doorTwoButton ? 1 : 0)
    print("door button pressed: \(buttonIndex)")
    appDelegate.publishDoorButtonMessage(buttonIndex)
  }

  @IBAction func refreshImageButtonPressed(button: UIButton? = nil) {
    print("refresh image button pressed")
    refreshSpinner.startAnimating()
    appDelegate.publishCaptureImageMessage()
  }

  func newImageReady() {
    print("new image ready, loading")
    load_image(IMAGE_URL)
  }
  
  func load_image(urlString:String)
  {
    let imgURL: NSURL = NSURL(string: urlString)!
    let request: NSURLRequest = NSURLRequest(URL: imgURL)
    
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request){
      (data, response, error) -> Void in
      self.refreshSpinner.stopAnimating()
      
      if (error == nil && data != nil)
      {
        func display_image()
        {
          self.garageImage.image = UIImage(data: data!)
        }
        
        dispatch_async(dispatch_get_main_queue(), display_image)
      }
      
    }
    
    task.resume()
  }

}
