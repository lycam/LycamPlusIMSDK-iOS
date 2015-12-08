//
//  AppDelegate.swift
//  LycamPlusIMSDK-iOS
//
//  Created by xman on 12/07/2015.
//  Copyright (c) 2015 xman. All rights reserved.
//

import UIKit
import LycamPlusIMSDK
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        LycamPlusIM .initWithAppkey("5663d0844407a3cd028aa5e4");
//         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessageReceived:) name:kLCPConnectionStatusChangedNotification object:nil];
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"onMessageReceived:", name: kLCPDidReceiveMessageNotification, object: nil)
        
//        NSNotificationCenter.defaultCenter().postNotificationName("BLDownloadImageNotification", object: self, userInfo: ["imageView":coverImage, "coverUrl" : albumCover])
//        
        LycamPlusIM.subscribe("111", qos: 1) { ( Bool success, error: NSError!) -> Void in
            
            print("ddd");
            LycamPlusIM.publish("111", msg: "this is a test", option: nil, resultBlock: { ( succ:Bool, error:NSError!) -> Void in
                print("");
            })
            
        }
        
        return true
    }
    
    func onMessageReceived(notification:NSNotification){
        //var data:NSDictionary? = notification.userInfo["data"];
        print(notification.userInfo);
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

