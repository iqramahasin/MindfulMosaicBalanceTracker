import Foundation
import UIKit
import AppsFlyerLib

class NetworkService {
    static let shared = NetworkService()
    
    private init() {}
    
    private func getDeviceModelIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier.lowercased()
    }
    
    func fetchServerResponse() async throws -> String {
        let systemLanguage = Locale.preferredLanguages.first ?? "en"
        let languageCode = String(systemLanguage.prefix(2))
        
        let deviceModel = getDeviceModelIdentifier()
        let countryCode = Locale.current.region?.identifier ?? "US"
        let osVersion = UIDevice.current.systemName + " " + UIDevice.current.systemVersion
        let appsflyerid = AppsFlyerLib.shared().getAppsFlyerUID()
        
        var requestString = "https://gtappinfo.site/ios-mindfulmosaic-balancetracker/server.php?p=Bs2675kDjkb5Ga&os=\(osVersion)&lng=\(languageCode)&devicemodel=\(deviceModel)&country=\(countryCode)&appsflyerid=\(appsflyerid)"
        
        requestString = requestString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? requestString
        
        guard let requestAddress = Foundation.URL(string: requestString) else {
            throw NetworkError.invalidAddress
        }
        
        let (data, _) = try await URLSession.shared.data(from: requestAddress)
        
        guard let responseString = String(data: data, encoding: .utf8) else {
            throw NetworkError.invalidResponse
        }
        
        return responseString
    }
}

enum NetworkError: Error {
    case invalidAddress
    case invalidResponse
}

