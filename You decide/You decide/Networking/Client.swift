//
//  Client.swift
//  Virtual Tourist
//
//  Created by Raneem on 5/17/19.
//  Copyright © 2019 Raneem. All rights reserved.
//

import UIKit

class Client {
    
    
    
    var session = URLSession.shared
    private var tasks: [String: URLSessionDataTask] = [:]
    
 
    
    class func shared() -> Client {
        struct Singleton {
            static var shared = Client()
        }
        return Singleton.shared
    }
    
    
    func searchIn(latitude: Double, longitude: Double, totalPages: Int?, completion: @escaping (_ result: PhotosParser?, _ error: Error?) -> Void) {
        
        var page: Int {
            if let totalPages = totalPages {
                let page = min(totalPages, 4000/FlickrParameterValues.PhotosPerPage)
                return Int(arc4random_uniform(UInt32(page)) + 1)
            }
            return 1
        }
        let bbox = bboxMinAndMax(latitude: latitude, longitude: longitude)
        
        let parameters = [
            FlickrParameter.Method           : FlickrParameterValues.SearchMethod
            , FlickrParameter.APIKey         : FlickrParameterValues.APIKey
            , FlickrParameter.Format         : FlickrParameterValues.ResponseFormat
            , FlickrParameter.Extras         : FlickrParameterValues.MediumURL
            , FlickrParameter.NoJSONCallback : FlickrParameterValues.DisableJSONCallback
            , FlickrParameter.SafeSearch     : FlickrParameterValues.UseSafeSearch
            , FlickrParameter.BoundingBox    : bbox
            , FlickrParameter.PhotosPerPage  : "\(FlickrParameterValues.PhotosPerPage)"
            , FlickrParameter.Page           : "\(page)"
        ]
        
        _ = getMethod(parameters: parameters) { (data, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let data = data else {
                let userInfo = [NSLocalizedDescriptionKey : "Could not retrieve data."]
                completion(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
                return
            }
            
            do {
                let photosParser = try JSONDecoder().decode(PhotosParser.self, from: data)
                completion(photosParser, nil)
            } catch {
                print("\(#function) error: \(error)")
                completion(nil, error)
            }
        }
    }
    
    
    
    func downloadImage(imageUrl: String, result: @escaping (_ result: Data?, _ error: NSError?) -> Void) {
        guard let url = URL(string: imageUrl) else {
            return
        }
        let task = getMethod(nil, url, parameters: [:]) { (data, error) in
            result(data, error)
            self.tasks.removeValue(forKey: imageUrl)
        }
        
        if tasks[imageUrl] == nil {
           tasks[imageUrl] = task
        }
    }
    
    
    func cancelLoading(_ imageUrl: String) {
        tasks[imageUrl]?.cancel()
        tasks.removeValue(forKey: imageUrl)
    }
    
    
    
    
}



extension Client {
    
    
    func getMethod(
        _ method               : String? = nil,
        _ customUrl            : URL? = nil,
        parameters             : [String: String],
        completionHandlerForGET: @escaping (_ result: Data?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        
        let request: NSMutableURLRequest!
        if let customUrl = customUrl {
            request = NSMutableURLRequest(url: customUrl)
        } else {
            request = NSMutableURLRequest(url: buildingURL(parameters, withPathExtension: method))
        }
        
        showActivityIndicator(true)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                self.showActivityIndicator(false)
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            
            if let error = error {
                
                
                if (error as NSError).code == URLError.cancelled.rawValue {
                    completionHandlerForGET(nil, nil)
                } else {
                    sendError("There was an error with your request: \(error.localizedDescription)")
                }
                return
            }
            
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            self.showActivityIndicator(false)
            completionHandlerForGET(data, nil)
            
        }
        
        task.resume()
        
        return task
    }
    
    
    
    private func buildingURL(_ parameters: [String: String], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = Flickr.APIScheme
        components.host = Flickr.APIHost
        components.path = Flickr.APIPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: value)
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    
    private func bboxMinAndMax(latitude: Double, longitude: Double) -> String {
        
        let minimumLon = max(longitude - Flickr.SearchBBoxHalfWidth, Flickr.SearchLonRange.0)
        let minimumLat = max(latitude  - Flickr.SearchBBoxHalfHeight, Flickr.SearchLatRange.0)
        let maximumLon = min(longitude + Flickr.SearchBBoxHalfWidth, Flickr.SearchLonRange.1)
        let maximumLat = min(latitude  + Flickr.SearchBBoxHalfHeight, Flickr.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    

    private func showActivityIndicator(_ show: Bool) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = show
        }
    }
}
