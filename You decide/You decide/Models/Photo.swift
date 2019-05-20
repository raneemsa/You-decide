//
//  Photo+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Raneem on 5/17/19.
//  Copyright © 2019 Raneem. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
    
    static let name = "Photo"
    
    convenience init(title: String, imageUrl: String, forPin: Pin, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: Photo.name, in: context) {
            self.init(entity: ent, insertInto: context)
            self.title = title
            self.image = nil
            self.imageUrl = imageUrl
            self.pin = forPin
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
}
