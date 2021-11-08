//
//  User.swift
//  pos
//
//  Created by Macbook on 28/5/18.
//  Copyright © 2018 Grupo Paseo. All rights reserved.
//

import Foundation

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
}
