//
//  AppDelegate.swift
//  Janus
//
//  Created by Will Koffel on 4/10/16.
//  Copyright © 2016 ClearlyTech. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  
  var viewController: ViewController?
  
  var firestoreDB: Firestore?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()

    // FireStore Setup
    firestoreDB = Firestore.firestore()
    let settings = firestoreDB!.settings
    settings.areTimestampsInSnapshotsEnabled = true
    firestoreDB!.settings = settings

    return true
  }
  
  func publishDoorButtonMessage(_ doorIndex: Int) {
    var ref: DocumentReference? = nil
    ref = firestoreDB?.collection("door_requests").addDocument(data: [
      "door": doorIndex,
      "requested_at": FieldValue.serverTimestamp(),
      "status": "pending",
      "user": "will+fixme@koffel.org"
    ]) { err in
      if let err = err {
        print("Error sending door_request: \(err)")
      } else {
        print("Published door_request \(doorIndex) with ID: \(ref!.documentID)")
      }
    }
  }
  
  func publishCaptureImageMessage() {
    var ref: DocumentReference? = nil
    ref = firestoreDB?.collection("image_requests").addDocument(data: [
      "requested_at": FieldValue.serverTimestamp(),
      "status": "pending",
      "user": "will+fixme@koffel.org"
    ]) { err in
      if let err = err {
        print("Error sending image_request: \(err)")
      } else {
        print("Published image_request with ID: \(ref!.documentID)")
      }
    }
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }


}

