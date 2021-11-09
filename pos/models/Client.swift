//
//  Client.swift
//  pos
//
//  Created by Macbook on 28/5/18.
//  Copyright © 2018 Grupo Paseo. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

class Client {
    var queue_id: String?
    var auto: String?
    var codigo: String?
    var nombre: String?
    var razon_social: String?
    var rif: String?
    
    func getAllClientByQueue(completion:@escaping ([Client]) -> Void){
        let section = SettingsBundleHelper.getSection()
        
        ToolsPaseo().consultPOSTAlt(path: "http://192.168.0.94:8000/api/v1/ventas/clients/?section=\(section)", params: [:]){ data in
            var clients = [Client]()
            
            for (_, subJson):(String, JSON) in data["data"] {
                let client = Client()
                client.queue_id     = "\(subJson["id"].int!)"
                client.auto         = subJson["auto"].string!
                client.codigo       = subJson["codigo"].string!
                client.nombre       = subJson["nombre"].string!
                client.razon_social = subJson["razon_social"].string!
                client.rif          = subJson["rif"].string!

                clients.append(client)
            }
            
            completion(clients)
        }
    }
    
    func updateClientStatus(status: String, completion:@escaping (Bool) -> Void){
        ToolsPaseo().consultPOSTAlt(path: "http://192.168.0.94:8000/api/v1/ventas/clients/update/?auto=\(self.queue_id!)&status=\(status)", params: [:]){ data in
            if(data["settings"]["message"] == "updated") {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}



/*
 // MARK: - CORE DATA METHODS
 */

extension Client {
    func saveClient() {
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "ClienteCore",in: managedObjectContext)
        let cliente = ClienteCore(entity: entityDescription!, insertInto: managedObjectContext)
        
        cliente.queue_id     = self.queue_id!
        cliente.auto         = self.auto
        cliente.codigo       = self.codigo
        cliente.nombre       = self.nombre
        cliente.razon_social = self.razon_social
        cliente.rif          = self.rif
        
        do {
            try managedObjectContext.save()
            print("GUARDADO: \(self.nombre!)")
            
        } catch let error as NSError {
            print("error: \(error.localizedFailureReason)" )
        }
    }
    
    func getClient() -> Client {
        let cliente = Client()
        // Get core data context
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "ClienteCore",in: managedObjectContext)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        
        // Get the client data 
        
        do {
            var results =
                try managedObjectContext.fetch(request)
            
            if results.count > 0 {
                let match = results[0] as! NSManagedObject
                cliente.queue_id     = "\(match.value(forKey: "queue_id")!)"
                cliente.auto         = "\(match.value(forKey: "auto")!)"
                cliente.codigo       = "\(match.value(forKey: "codigo")!)"
                cliente.nombre       = "\(match.value(forKey: "nombre")!)"
                cliente.razon_social = "\(match.value(forKey: "razon_social")!)"
                cliente.rif          = "\(match.value(forKey: "rif")!)"
                
            }
            
        } catch let error as NSError {
            print("\(error.localizedFailureReason)")
        }
        
        return cliente
    }
    
    func deleteClients(){
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "ClienteCore",in: managedObjectContext)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try managedObjectContext.execute(deleteRequest)
        } catch let error as NSError {
            print("\(error.localizedFailureReason)")
        }
    }
}

