//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Raneem on 5/17/19.
//  Copyright © 2019 Raneem. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var image: NSData?
    @NSManaged public var title: String?
    @NSManaged public var imageUrl: String?
    @NSManaged public var pin: Pin?

}
