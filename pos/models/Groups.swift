//
//  Groups.swift
//  pos
//
//  Created by Macbook on 28/5/18.
//  Copyright © 2018 Grupo Paseo. All rights reserved.
//

import Foundation
import SwiftyJSON

class Group {
    var auto: String?
    var nombre: String?
    
    func getAllGroupsOfSection(completion:@escaping ([Group]) -> Void){
        let section = SettingsBundleHelper.getSection()
        
        ToolsPaseo().consultPOSTAlt(path: "http://10.10.2.15:8000/api/v1/ventas/groups/?section=\(section)", params: [:]){ data in
            
            var groups = [Group]()
            
            // add the data to groups array
            for (_, subJson):(String, JSON) in data["data"] {
                let group = Group()
                group.auto = subJson["auto_grupo"].string!
                group.nombre = subJson["nombre"].string!
                groups.append(group)
                
            }
            
            completion(groups)
            
        }
    }
}
