//
//  AppDelegate.swift
//  TaskApp
//
//  Created by Kosuke Miyazaki on 2024/04/21.
//

import UIKit
import UserNotifications    // 追加
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // ユーザーに通知の許可を求める --- ここから ---
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization
        } // --- ここまで追加 ---
        center.delegate = self
        // Realmのマイグレーション処理
        let config = Realm.Configuration(
            schemaVersion: 1, // ここで新しいスキーマバージョンを設定します
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    // 新しいプロパティの追加などのマイグレーション処理をここに書きます
                    // 今回のケースでは、新しいフィールド'category'が追加されているので、
                    // 既存のレコードにデフォルト値を設定する必要がありますが、
                    // Realmは自動的に新しいプロパティを認識し、デフォルト値（通常はnilまたは空の値）を使用します。
                }
            }
        )
        Realm.Configuration.defaultConfiguration = config
        
        return true
    }
    
    // アプリがフォアグラウンドの時に通知を受け取ると呼ばれるメソッド --- ここから ---
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound])
    } // --- ここまで追加 ---
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

