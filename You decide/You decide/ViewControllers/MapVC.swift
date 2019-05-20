//
//  MapVC.swift
//  Virtual Tourist
//
//  Created by Raneem on 5/18/19.
//  Copyright © 2019 Raneem. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController, MKMapViewDelegate {
    

    
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var bottomView: UIView!
    
    var pinAnnotation: MKPointAnnotation? = nil
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        navigationItem.leftBarButtonItem = editButtonItem
        bottomView.isHidden = true
        if let pins = loadAllPins() {
            showPins(pins)
        }
    }
    
    
    
    @IBAction func addPin(_ sender: UILongPressGestureRecognizer) {
        
        let location = sender.location(in: mapView)
        let locCoord = mapView.convert(location, toCoordinateFrom: mapView)
        
        if sender.state == .began {
            
            pinAnnotation = MKPointAnnotation()
            pinAnnotation!.coordinate = locCoord
            
            print("Coordinate: \(locCoord.latitude),\(locCoord.longitude)")
        
            mapView.addAnnotation(pinAnnotation!)
            
        } else if sender.state == .changed {
            pinAnnotation!.coordinate = locCoord
        } else if sender.state == .ended {
            
            _ = Pin(
                latitude: String(pinAnnotation!.coordinate.latitude),
                longitude: String(pinAnnotation!.coordinate.longitude),
                context: CoreDataStack.shared().context
            )
            save()
            
        }
    }
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        bottomView.isHidden = !editing
    }
    
    
    private func loadAllPins() -> [Pin]? {
        var pins: [Pin]?
        do {
            try pins = CoreDataStack.shared().fetchAllPins(entityName: Pin.name)
        } catch {
            print("\(#function) error:\(error)")
            showInfo(withTitle: "Error", withMessage: "Error while fetching Pin locations: \(error)")
        }
        return pins
    }
    
    
    private func loadPin(latitude: String, longitude: String) -> Pin? {
        let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", latitude, longitude)
        var pin: Pin?
        do {
            try pin = CoreDataStack.shared().fetchPin(predicate, entityName: Pin.name)
        } catch {
            showInfo(withTitle: "Error", withMessage: "Error while fetching location: \(error)")
        }
        return pin
    }
    
    
    func showPins(_ pins: [Pin]) {
        for pin in pins where pin.latitude != nil && pin.longitude != nil {
            let annotation = MKPointAnnotation()
            let lat = Double(pin.latitude!)!
            let lon = Double(pin.longitude!)!
            annotation.coordinate = CLLocationCoordinate2DMake(lat, lon)
            mapView.addAnnotation(annotation)
        }
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is AlbumVC {
            guard let pin = sender as? Pin else {
                return
            }
            let vc = segue.destination as! AlbumVC
            vc.pin = pin
        }
    }
    
    

}

//extension

extension MapVC {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
            pinView!.animatesDrop = true
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            self.showInfo(withMessage: "No link defined.")
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let annotation = view.annotation else {
            return
        }

        mapView.deselectAnnotation(annotation, animated: true)
        print("\(#function) lat \(annotation.coordinate.latitude) lon \(annotation.coordinate.longitude)")
        let lat = String(annotation.coordinate.latitude)
        let lon = String(annotation.coordinate.longitude)
        if let pin = loadPin(latitude: lat, longitude: lon){
            if isEditing {
                mapView.removeAnnotation(annotation)
                CoreDataStack.shared().context.delete(pin)
                save()
                return
            }
        performSegue(withIdentifier: "showAlbum", sender: pin)
        }
    }

}
