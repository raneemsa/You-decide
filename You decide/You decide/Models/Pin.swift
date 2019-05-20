//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Raneem on 5/17/19.
//  Copyright © 2019 Raneem. All rights reserved.
//

import Foundation
import CoreData


@objc(Pin)
public class Pin: NSManagedObject {
    
    static let name = "Pin"
    
    convenience init(latitude: String, longitude: String, context: NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: Pin.name, in: context) {
            
            self.init(entity: ent, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
        }
        else {
            
            fatalError("Unable to find Entity name!")
        }
    }
    
}
