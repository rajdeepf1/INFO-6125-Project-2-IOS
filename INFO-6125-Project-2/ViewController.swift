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
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.requestWhenInUseAuthorization()
        
        setupMap()
        addAnnotation(location: getLocation())
    }
    
    
    private func setupMap(){
        // set delegate
        mapView.delegate = self
        
        // enable showing user location on map
        mapView.showsUserLocation = true
        
        let location = getLocation()
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
        let annotation = MyAnnotation(coordinate: location.coordinate, title: "My Title", subtitle:"A lovely subtitle here", glyphText:"F")
        mapView.addAnnotation (annotation)
    }
    
    private func getLocation() -> CLLocation{
        return CLLocation(latitude: 43.0130, longitude: -81.1994)
    }
    
    
    
    
    
    @IBAction func onAddLocationButtonPressed(_ sender: Any) {
        
        print("hi")
        
        performSegue(withIdentifier: "goToAddLocation", sender: self)
        
    }
    
    
    
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "myIdentifier"
        
        var view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                
        // check to see if we have a view we can reuse
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView{
            // get updated annotation
            dequeuedView.annotation = annotation
            // use our reusable view
            view = dequeuedView
        }
        else{
         
            view.canShowCallout = true
            
            // set the position of the callout
            
            view.calloutOffset = CGPoint(x: 0, y: 10)
            
            // add a button to right side of callout
            
            let button = UIButton (type: .detailDisclosure)
            button.tag = 100
            view.rightCalloutAccessoryView = button
            
            // add an image to left side of callout
            
            let image = UIImage (systemName: "graduationcap.circle.fill")
            view.leftCalloutAccessoryView = UIImageView(image: image)
            
            // change colour of pin/marker
            
            view.markerTintColor = UIColor.purple
            
            // change colour of accessories
            
            view.tintColor = UIColor.systemRed
            
            if let myAnnotation = annotation as? MyAnnotation {
                view.glyphText = myAnnotation.glyphText
            }
            
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print ("Button clicked \(control.tag)")
        guard let coordinates = view.annotation?.coordinate
        else {
            return
        }
        
        
        
        let launchOptions = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
        ]
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinates) )
        mapItem.openInMaps (launchOptions: launchOptions)
    }
    
}

class MyAnnotation: NSObject, MKAnnotation
{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var glyphText: String?
    init (coordinate: CLLocationCoordinate2D, title: String, subtitle: String, glyphText: String? = nil)
    {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.glyphText = glyphText
        super.init()
    }
}
