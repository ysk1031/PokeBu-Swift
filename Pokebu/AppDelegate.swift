//
//  AppDelegate.swift
//  Pokebu
//
//  Created by Yusuke Aono on 8/13/15.
//  Copyright © 2015 Yusuke Aono. All rights reserved.
//

import UIKit
import PocketAPI
import HatenaBookmarkSDK
import Keys
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // PocketのAPIキー設定
        initPocketSdk()
        
        // ParseのAPIキー設定
        initParseSdk()
        
        // Push設定
        registerPushNotification(application, launchOptions: launchOptions)
        
        
        // Pocketログイン状態の確認
        if PocketAPI.sharedAPI().loggedIn {
        } else {
            // 実装を後で変更する。本来は別のviewに飛ばし、ログイン処理をそちらで行う
            // この状態のままだと、ログイン処理より前にAlamofireでのデータ取得処理がはじまり、アクセストークンがなくてエラー
            
            // Pocketログイン
            PocketAPI.sharedAPI().loginWithHandler { (api, error) in
                if error != nil {
                
                } else {
                
                }
            }
        }
        
        //  キャッシュクリア
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        NSURLCache.sharedURLCache().diskCapacity = 0
        NSURLCache.sharedURLCache().memoryCapacity = 0
        
        return true
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
        initHatenaBookmarkSdk()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // Deprecated in iOS 9.0.
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if PocketAPI.sharedAPI().handleOpenURL(url) {
            return true
        } else {
            return false
        }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackgroundWithBlock(nil)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS simulator.")
        } else {
            print(error.localizedDescription)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayloadInBackground(userInfo, block: nil)
        }
    }
    
    // Application logic
    
    func initPocketSdk() {
        let pocketSdkConsumerKey = PokebuKeys().pocketSdkConsumerKey()
        PocketAPI.sharedAPI().consumerKey = pocketSdkConsumerKey
    }
    
    func initHatenaBookmarkSdk() {
        let hatenaConsumerKey = PokebuKeys().hatenaConsumerKey()
        let hatenaConsumerSecret = PokebuKeys().hatenaConsumerSecret()
        HTBHatenaBookmarkManager.sharedManager().setConsumerKey(hatenaConsumerKey, consumerSecret: hatenaConsumerSecret)
    }
    
    func initParseSdk() {
        Parse.setApplicationId(PokebuKeys().parseApplicationId(), clientKey: PokebuKeys().parseClientKey())
    }
    
    func registerPushNotification(application: UIApplication, launchOptions: [NSObject: AnyObject]?) {
        if application.applicationState != UIApplicationState.Background {
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var pushPayload = false
            if let options = launchOptions {
                pushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
            }
            if preBackgroundPush || oldPushHandlerOnly || pushPayload {
                PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
            }
        }
        
        // 通知許可画面を出す
        if application.respondsToSelector("registerUserNotificationSettings:") {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(
                forTypes: [.Alert, .Badge, .Sound],
                categories: nil
            )
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
    }
    
}

