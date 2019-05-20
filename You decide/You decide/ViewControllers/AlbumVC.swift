//
//  AlbumVC.swift
//  Virtual Tourist
//
//  Created by Raneem on 5/18/19.
//  Copyright © 2019 Raneem. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class AlbumVC: UIViewController, MKMapViewDelegate {
    
  
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout?
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var labelStatus: UILabel!
    
    var totalPages: Int? = nil
    var selectedIndexes = [IndexPath]()
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
 
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var presentingAlert = false
    var pin: Pin?
   
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photosFlowLayout(view.frame.size)
        mapView.delegate = self
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        
        LabelStatus("")
        
        guard let pin = pin else {
            return
        }
        showOnTheMap(pin)
        setupFetchedResultControllerWith(pin)
        
        if let photos = pin.photos, photos.count == 0 {
            fetchPhotosFromFlikrAPI(pin)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        photosFlowLayout(size)
    }
    
    
    @IBAction func deleteAction(_ sender: Any) {
        for photos in fetchedResultsController.fetchedObjects! {
            CoreDataStack.shared().context.delete(photos)
        }
        save()
        fetchPhotosFromFlikrAPI(pin!)
    }
    
    
    private func setupFetchedResultControllerWith(_ pin: Pin) {
        
        let fr = NSFetchRequest<Photo>(entityName: Photo.name)
        fr.sortDescriptors = []
        fr.predicate = NSPredicate(format: "pin == %@", argumentArray: [pin])
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: CoreDataStack.shared().context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            print("Error performing initial fetch: \(error)")
        }
    }
    
    
    private func fetchPhotosFromFlikrAPI(_ pin: Pin) {
        
        let lat = Double(pin.latitude!)!
        let lon = Double(pin.longitude!)!
        
        activityIndicator.startAnimating()
        self.LabelStatus("Fetching photos ...")
        
        Client.shared().searchIn(latitude: lat, longitude: lon, totalPages: totalPages) { (photosParsed, error) in
            self.performUpdates {
                self.activityIndicator.stopAnimating()
                self.labelStatus.text = ""
            }
            if let photosParsed = photosParsed {
                self.totalPages = photosParsed.photos.pages
                let totalPhotos = photosParsed.photos.photo.count
                print("\(#function) Downloading \(totalPhotos) photos.")
                self.storePhotos(photosParsed.photos.photo, forPin: pin)
                if totalPhotos == 0 {
                    self.LabelStatus("No photos found")
                }
            } else if let error = error {
                print("\(#function) error:\(error)")
                self.showInfo(withTitle: "Error", withMessage: error.localizedDescription)
                self.LabelStatus("Something went wrong, please try again")
            }
        }
    }
    
    
    private func LabelStatus(_ text: String) {
        self.performUpdates {
            self.labelStatus.text = text
        }
    }
    
    
    private func showOnTheMap(_ pin: Pin) {
        
        let lat = Double(pin.latitude!)!
        let lon = Double(pin.longitude!)!
        let locCoord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locCoord
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
        mapView.setCenter(locCoord, animated: true)
    }
    
    
    private func storePhotos(_ photos: [PhotoParser], forPin: Pin) {
        func showErrorMessage(msg: String) {
            showInfo(withTitle: "Error", withMessage: msg)
        }
        
        for photo in photos {
            performUpdates {
                if let url = photo.url {
                    _ = Photo(title: photo.title, imageUrl: url, forPin: forPin, context: CoreDataStack.shared().context)
                    self.save()
                }
            }
        }
    }
    
    
    private func loadPhotos(using pin: Pin) -> [Photo]? {
        let predicate = NSPredicate(format: "pin == %@", argumentArray: [pin])
        var photos: [Photo]?
        do {
            try photos = CoreDataStack.shared().fetchPhotos(predicate, entityName: Photo.name)
        } catch {
            print("\(#function) error:\(error)")
            showInfo(withTitle: "Error", withMessage: "Error while lading Photos from disk: \(error)")
        }
        return photos
    }
    
    
    private func photosFlowLayout(_ withSize: CGSize) {
        
        let landscape = withSize.width > withSize.height
        
        let space: CGFloat = landscape ? 5 : 3
        let items: CGFloat = landscape ? 2 : 3
        
        let dimension = (withSize.width - ((items + 1) * space)) / items
        
        flowLayout?.minimumInteritemSpacing = space
        flowLayout?.minimumLineSpacing = space
        flowLayout?.itemSize = CGSize(width: dimension, height: dimension)
        flowLayout?.sectionInset = UIEdgeInsets(top: space, left: space, bottom: space, right: space)
    }
    
    func newColllectionButtonClicked() {
        if selectedIndexes.count > 0 {
            newCollectionButton.setTitle("Remove Selected", for: .normal)
        } else {
            newCollectionButton.setTitle("New Collection", for: .normal)
        }
    }
}




//extension

extension AlbumVC {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
}
