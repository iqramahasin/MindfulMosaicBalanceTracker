import UIKit
import SwiftUI
import AppsFlyerLib

class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock: UIInterfaceOrientationMask = .portrait
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        AppsFlyerLib.shared().appsFlyerDevKey = "GAx7MdJxvhAHXASNJ79vZb"
        AppsFlyerLib.shared().appleAppID = "6755929136"
        AppsFlyerLib.shared().isDebug = false
        AppsFlyerLib.shared().start()
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}

