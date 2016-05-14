//
//  AppDelegate.swift
//  Janus
//
//  Created by Will Koffel on 4/10/16.
//  Copyright © 2016 ClearlyTech. All rights reserved.
//

import UIKit
import PubNub

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PNObjectEventListener {

  var window: UIWindow?
  var pubnubClient: PubNub?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.
    let pubnubConfiguration = PNConfiguration(
      publishKey: "",
      subscribeKey: ""
    )
    pubnubClient = PubNub.clientWithConfiguration(pubnubConfiguration)
    pubnubClient?.addListener(self)
    
    self.pubnubClient?.subscribeToChannels(["image_ready"], withPresence: false)
    return true
  }

  // Handle new message from one of channels on which client has been subscribed.
  func client(client: PubNub, didReceiveMessage message: PNMessageResult) {
    
    // Handle new message stored in message.data.message
    if message.data.actualChannel != nil {
      
      // Message has been received on channel group stored in
      // message.data.subscribedChannel
    }
    else {
      
      // Message has been received on channel stored in
      // message.data.subscribedChannel
    }
    
    ViewController().newImageReady()

    print("Received message: \(message.data.message) on channel " +
      "\((message.data.actualChannel ?? message.data.subscribedChannel)!) at " +
      "\(message.data.timetoken)")
  }
  
  func publishDoorButtonMessage(doorIndex: Int) {
    self.pubnubClient?.publish(["door": String(doorIndex)], toChannel: "door_button",
      compressed: false, withCompletion: { (status) -> Void in
       
       if !status.error {
         print("published door_button \(doorIndex)")
       }
       else {
         print("error publishing door_button")
         print(status.errorData)
         // Handle message publish error. Check 'category' property
         // to find out possible reason because of which request did fail.
         // Review 'errorData' property (which has PNErrorData data type) of status
         // object to get additional information about issue.
         //
         // Request can be resent using: status.retry()
      }
    })
  }
  
  func publishCaptureImageMessage() {
    self.pubnubClient?.publish(["capture" : 1], toChannel: "capture_image",
                               compressed: false, withCompletion: { (status) -> Void in
                                
                                if !status.error {
                                  print("published capture_image")
                                }
                                else {
                                  print("error publishing capture_image")
                                  print(status.errorData)
                                  // Handle message publish error. Check 'category' property
                                  // to find out possible reason because of which request did fail.
                                  // Review 'errorData' property (which has PNErrorData data type) of status
                                  // object to get additional information about issue.
                                  //
                                  // Request can be resent using: status.retry()
                                }
    })
  }
  
  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }


}

