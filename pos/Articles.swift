//
//  Articles.swift
//  pos
//
//  Created by Macbook on 28/5/18.
//  Copyright © 2018 Grupo Paseo. All rights reserved.
//

import Foundation
import SwiftyJSON

class Article {
    var auto: String?
    var nombre: String?
    var codigo: String?
    var cantidad: String?
    var tasa: String?
    var total: String?
    var precio_neto: String?
    var precio: String?
    var auto_cuenta: String?
    
    func getArticlesByCode(code: String, completion:@escaping (Article) -> Void){
        ToolsPaseo().consultPOSTAlt(path: "http://10.10.2.15:8000/api/v1/ventas/articles/?code=\(code)", params: [:]){ data in
            
            let article = Article()
            
            if (data["settings"]["message"] == "article") {
                article.auto        = data["data"]["auto"].string!
                article.nombre      = data["data"]["nombre"].string!
                article.codigo      = data["data"]["codigo"].string!
                article.tasa        = data["data"]["tasa"].string!
                article.precio_neto = data["data"]["precio_neto"].string!
                
                let tax = Double(Double(data["data"]["precio_neto"].string!)! * Double(data["data"]["tasa"].string!)! / 100)
                
                let precio_with_tax = tax + Double(data["data"]["precio_neto"].string!)!
                let precio_total = Double(String(format: "%.2f", precio_with_tax))
                article.precio = "\(precio_total!)"
            }
            
            completion(article)
        }
    }
    
    func getArticlesByPLU(plu: String, completion:@escaping (Article) -> Void){
        ToolsPaseo().consultPOSTAlt(path: "http://10.10.2.15:8000/api/v1/ventas/articles/?plu=\(plu)", params: [:]){ data in
            
            let article = Article()
            
            if (data["settings"]["message"] == "article") {
                article.auto        = data["data"]["auto"].string!
                article.nombre      = data["data"]["nombre"].string!
                article.codigo      = data["data"]["codigo"].string!
                article.tasa        = data["data"]["tasa"].string!
                article.precio_neto = data["data"]["precio_neto"].string!
                
                let tax = Double(Double(data["data"]["precio_neto"].string!)! * Double(data["data"]["tasa"].string!)! / 100)
                
                let precio_with_tax = tax + Double(data["data"]["precio_neto"].string!)!
                let precio_total = Double(String(format: "%.2f", precio_with_tax))
                article.precio = "\(precio_total!)"
            }
            
            completion(article)
        }
    }
    
    func getArticlesByClient(client: Client, completion:@escaping ([Article]) -> Void) {
        var articles = [Article]()
        var obj: JSON = [
            "client": [
                "code": client.codigo!
            ]
        ]
        
        let json = JSON(obj.object)
        
        ToolsPaseo().consultPOSTJSON(path: "http://10.10.2.15:8000/api/v1/ventas/articles/account/", json: "\(json)") { data in
            
            // add the data to groups array
            for (_, subJson):(String, JSON) in data["data"] {
                let article = Article()
                article.auto        = subJson["auto_producto"].string!
                article.nombre      = subJson["nombre"].string!
                article.codigo      = subJson["codigo"].string!
                article.tasa        = subJson["tasa"].string!
                article.precio_neto = subJson["precio_neto"].string!
                article.cantidad    = subJson["cantidad"].string!
                article.auto_cuenta = subJson["auto"].string!
                
                let tax = Double(Double(subJson["precio_neto"].string!)! * Double(subJson["tasa"].string!)! / 100)
                
                let precio_with_tax = tax + Double(subJson["precio_neto"].string!)!
                let precio_total = Double(String(format: "%.2f", precio_with_tax))
                article.precio = "\(precio_total!)"
                article.total = "\(Double(subJson["cantidad"].string!)! * Double(article.precio!)!)"
                
                articles.append(article)
            }
            
            completion(articles)
        }
    }
    
    func getArticlesByGroup(auto_group: String, completion:@escaping ([Article]) -> Void){
        var articles = [Article]()
        
        ToolsPaseo().consultPOSTAlt(path: "http://10.10.2.15:8000/api/v1/ventas/articles/?group=\(auto_group)", params: [:]){ data in
            
            // add the data to groups array
            for (_, subJson):(String, JSON) in data["data"] {
                let article = Article()
                article.auto        = subJson["auto"].string!
                article.nombre      = subJson["nombre"].string!
                article.codigo      = subJson["codigo"].string!
                article.tasa        = subJson["tasa"].string!
                article.precio_neto = subJson["precio_neto"].string!
                
                let tax = Double(Double(subJson["precio_neto"].string!)! * Double(subJson["tasa"].string!)! / 100)
                
                let precio_with_tax = tax + Double(subJson["precio_neto"].string!)!
                let precio_total = Double(String(format: "%.2f", precio_with_tax))
                article.precio = "\(precio_total!)"
                
                articles.append(article)
            }
            
            completion(articles)
        }
    }
    
    func putArticleToAccount(client: Client, completion:@escaping (Article) -> Void){
        var obj: JSON = [
            "article": [
                "code": self.codigo!,
                "quantity": self.cantidad!
            ],
            "client": [
                "code": client.codigo!
            ]
        ]
        
        let json = JSON(obj.object)
        ToolsPaseo().consultPOSTJSON(path: "http://10.10.2.15:8000/api/v1/ventas/articles/add/", json: "\(json)") {data in
            
            if (data["settings"]["message"] == "saved" ) {
                self.auto_cuenta = data["data"][0]["auto"].string!
            }
            completion(self)
            
        }
    }
    
    func removeArticleToAccount(completion:@escaping (Bool) -> Void){
        var obj: JSON = [
            "article": [
                "auto_row": self.auto_cuenta!
            ]
        ]
        
        let json = JSON(obj.object)
        ToolsPaseo().consultPOSTJSON(path: "http://10.10.2.15:8000/api/v1/ventas/articles/remove/", json: "\(json)") { data in
            
            if (data["settings"]["message"] == "removed" ) {
                completion(true)
            } else {
                completion(false)
            }
            
        }
    }
    
    func removeAllArticles(client: Client, completion:@escaping (Bool) -> Void){
        var obj: JSON = [
            "client": [
                "code": client.codigo!
            ]
        ]
        let json = JSON(obj.object)
        
        ToolsPaseo().consultPOSTJSON(path: "http://10.10.2.15:8000/api/v1/ventas/articles/remove/all/", json: "\(json)") { data in
            
            if (data["settings"]["message"] == "removed" ) {
                completion(true)
            } else {
                completion(false)
            }
            
        }
    }
}
