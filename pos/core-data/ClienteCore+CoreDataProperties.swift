//
//  ClienteCore+CoreDataProperties.swift
//  pos
//
//  Created by Macbook on 4/6/18.
//  Copyright © 2018 Grupo Paseo. All rights reserved.
//

import Foundation
import CoreData


extension ClienteCore {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ClienteCore> {
        return NSFetchRequest<ClienteCore>(entityName: "ClienteCore");
    }

    @NSManaged public var auto: String?
    @NSManaged public var queue_id: String?
    @NSManaged public var nombre: String?
    @NSManaged public var codigo: String?
    @NSManaged public var razon_social: String?
    @NSManaged public var rif: String?

}
