//
//  ViewController.swift
//  INFO-6125-Project-2
//
//  Created by Rajdeep Singh on 2022-11-29.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView:MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupMap()
        addAnnotation(location: getCurrentLocation())
    }
    
    
    private func setupMap(){
            let location = getCurrentLocation()
            let radiusInMeters: CLLocationDistance = 1000
            let region = MKCoordinateRegion(center: location.coordinate,
                                            latitudinalMeters: radiusInMeters,
                                            longitudinalMeters: radiusInMeters)
            mapView.setRegion (region, animated: true)
            
            // camera boundaries
            let cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: region)
            mapView.setCameraBoundary(cameraBoundary, animated: true)
            // control zooming
            let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 100000)
            mapView.setCameraZoomRange(zoomRange, animated: true)
            
        }
    
    private func addAnnotation(location: CLLocation) {
          let annotation = MyAnnotation(coordinate: location.coordinate, title: "You are here!", subtitle:"your current location.")
          mapView.addAnnotation (annotation)
      }
    
    private func getCurrentLocation() -> CLLocation{
            return CLLocation(latitude: 43.010449, longitude: -81.1975784)
        }
    
    
    
    
    
    @IBAction func onAddLocationButtonPressed(_ sender: Any) {
        
        print("hi")
        
        performSegue(withIdentifier: "goToAddLocation", sender: self)
        
    }
    
    
    
}

class MyAnnotation: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    init (coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
    self.coordinate = coordinate
    self.title = title
    self.subtitle = subtitle
        super.init()
    }
    
}




