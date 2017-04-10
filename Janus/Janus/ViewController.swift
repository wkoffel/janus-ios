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
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  
  @IBOutlet weak var doorOneButton: UIButton!
  @IBOutlet weak var doorTwoButton: UIButton!
  @IBOutlet weak var garageImage: UIImageView!
  @IBOutlet weak var refreshSpinner: UIActivityIndicatorView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.newImageReady()
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
