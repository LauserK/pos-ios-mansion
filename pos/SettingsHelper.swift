//
//  SettingsHelper.swift
//  pos
//
//  Created by Macbook on 6/6/18.
//  Copyright © 2018 Grupo Paseo. All rights reserved.
//

import Foundation

class SettingsBundleHelper {
    struct SettingsBundleKeys {
        static let api_url = "API_URL"
        static let api_url_2 = "API_URL_2"
        static let section = "section"
        static let AppVersionKey = "version_preference"
    }
    
    class func setVersion() {
        let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        UserDefaults.standard.set(version, forKey: SettingsBundleKeys.AppVersionKey)
    }
    
    class func getAPIUrl() -> String {
        UserDefaults.standard.register(defaults: [String : Any]())
        return UserDefaults.standard.string(forKey: "API_URL") ?? "http://10.10.0.250/RecepcionMercancia/Service.asmx"
    }
    
    class func getAPIAltURL() -> String {
        UserDefaults.standard.register(defaults: [String : Any]())
        return UserDefaults.standard.string(forKey: "API_URL_2") ?? "http://10.10.2.15:8000/api/v1/"
    }
    
    class func getSection() -> String {
        UserDefaults.standard.register(defaults: [String : Any]())
        return UserDefaults.standard.string(forKey: "section") ?? "03"
    }
}
