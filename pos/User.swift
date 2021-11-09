//
//  User.swift
//  pos
//
//  Created by Macbook on 28/5/18.
//  Copyright © 2018 Grupo Paseo. All rights reserved.
//

import Foundation
import SwiftyJSON

class User {
    var auto: String?
    var codigo: String?
    var nombre: String?
    
    func getUser(codigo: String, clave: String, completion:@escaping (User) -> Void){
        let params = [
            "codigo": codigo,
            "clave": clave
        ]
        
        ToolsPaseo().consultPOST(path: "/Login", params: params){ data in
            let user = User()
            if (data[0]["error"] == false){
                // Populate the user object
                
                user.nombre = data[0]["nombre"].string!
                user.codigo = data[0]["codigo"].string!
                user.auto   = data[0]["auto"].string!
            }
            
            completion(user)
            
        }
        
        
    }
    
    func getUserNew(codigo:String, clave:String, completion:@escaping (User) -> Void){
        var obj: JSON = [
            "usuario": [
                "code": codigo,
                "clave": clave
            ]
        ]
        
        let json = JSON(obj.object)
        ToolsPaseo().consultPOSTJSON(path: "http://192.168.0.94:8000/api/v1/ventas/login/", json: "\(json)") {data in
            
            let user = User()
            if (data["settings"]["success"] == true){
                // Populate the user object                                
                
                user.nombre = data["data"][0]["nombre"].string!
                user.codigo = data["data"][0]["codigo"].string!
                user.auto   = data["data"][0]["auto"].string!
            }
            completion(user)
            
        }
    }
}
