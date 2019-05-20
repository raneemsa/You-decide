//
//  Client+Extension.swift
//  Virtual Tourist
//
//  Created by Raneem on 5/17/19.
//  Copyright © 2019 Raneem. All rights reserved.
//

import Foundation

extension Client {
    
    
    struct Flickr {
        
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
        
        static let SearchBBoxHalfWidth = 0.2
        static let SearchBBoxHalfHeight = 0.2
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
    }
    
    
    struct FlickrParameter {
        static let Method = "method"
        static let APIKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let BoundingBox = "bbox"
        static let PhotosPerPage = "per_page"
        static let Accuracy = "accuracy"
        static let Page = "page"
    }
    
    
    
    struct FlickrParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "39775f20961d59de973dbf6cb9681f64"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let MediumURL = "url_n"
        static let UseSafeSearch = "1" 
        static let PhotosPerPage = 30
        static let AccuracyCityLevel = "11"
        static let AccuracyStreetLevel = "16"
    }
}
