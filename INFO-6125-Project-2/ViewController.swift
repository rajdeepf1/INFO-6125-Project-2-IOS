//
//  ViewController.swift
//  INFO-6125-Project-2
//
//  Created by Rajdeep Singh on 2022-11-29.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView:MKMapView!
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation?
    var weatherResponseGlobal : WeatherResponse? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        mapView.delegate = self
        locationManager = CLLocationManager()
        
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Check for Location Services
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { currentLocation = locations.last }
        
        if currentLocation == nil {
            // Zoom to user location
            if let userLocation = locations.last {
                let viewRegion = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
                // camera boundaries
                let cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: viewRegion)
                mapView.setCameraBoundary(cameraBoundary, animated: true)
                // control zooming
                let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 100000)
                mapView.setCameraZoomRange(zoomRange, animated: true)
                mapView.setRegion(viewRegion, animated: true)
                
                loadWeather(location: userLocation)
                
                
            }
        }
    }
    
    
    private func addAnnotation(location: CLLocation,weatherResponse:WeatherResponse) {
        let annotation = MyAnnotation(coordinate: location.coordinate, title: "Your current location", subtitle:"A lovely subtitle here", glyphText:"\(weatherResponse.current.temp_c)")
        mapView.addAnnotation (annotation)
    }
    
    
    
    @IBAction func onAddLocationButtonPressed(_ sender: Any) {
        
        print("hi")
        
        performSegue(withIdentifier: "goToAddLocation", sender: self)
        
    }
    
    // load weather api
    func loadWeather(location: CLLocation) {
        
        let search: String? = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        
        guard let search = search else {
            return
        }
        // Step 1: Get URL
        guard let url = getURL (query: search) else {
            print ("Could not get URL")
            return
        }
        // Step 2: Create URLSession
        let session = URLSession.shared
        // Step 3: Create task for session
        let dataTask = session.dataTask(with: url) { data, response, error in
            // network call finished
            
            guard error == nil else {
                print ("Received error")
                return
            }
            guard let data = data else
            {
                print ("No data found" )
                return
            }
            
            if let weatherResponse = self.parseJson(data: data){
                
                
                self.weatherResponseGlobal = weatherResponse
                DispatchQueue.main.async {
                   
                    
                    self.addAnnotation(location:location,weatherResponse:weatherResponse)
                    
                    
                }
                
            }
            
        }
        
        //step 4 : start the task
        
        dataTask.resume();
        
    }
    
    private func getURL (query: String) -> URL? {
        let baseUrl = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "current.json"
        let apiKey = "c67149dd82f9438e86f31545222111"
        guard let url = "\(baseUrl)\(currentEndpoint)?key=\(apiKey)&q=\(query)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
            return nil
        }
        print(url)
        return URL(string: url)
    }
    
    private func parseJson(data: Data) -> WeatherResponse?{
        let decoder = JSONDecoder()
        var weather: WeatherResponse?
        do {
            weather = try decoder.decode (WeatherResponse.self, from: data)
        } catch {
            print ("Error decoding")
        }
        return weather
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
            
            
            // change colour of accessories
            
            view.tintColor = UIColor.systemRed
            
            if let myAnnotation = annotation as? MyAnnotation {
                view.glyphText = myAnnotation.glyphText
                // change colour of pin/marker
                
                let numberFormatter = NumberFormatter()
                let number = numberFormatter.number(from: myAnnotation.glyphText ?? "0.0")
                let numberFloatValue = number?.floatValue ?? 0.0
                                            
                
                if (numberFloatValue >= 35.0) {
                    view.markerTintColor = UIColor.systemRed // dark red

                }else if (numberFloatValue >= 25.0 && numberFloatValue <= 30.0) {
                    view.markerTintColor = UIColor.red

                }else if (numberFloatValue >= 17.0 && numberFloatValue <= 24.0) {
                    view.markerTintColor = UIColor.orange

                }else if (numberFloatValue >= 12.0 && numberFloatValue <= 16.0) {
                    view.markerTintColor = UIColor.blue

                }else if (numberFloatValue >= 0.0 && numberFloatValue <= 11.0) {
                    view.markerTintColor = UIColor.systemBlue
                }
                else if (numberFloatValue < 0.0 ){
                    view.markerTintColor = UIColor.purple

                }
                
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

struct WeatherResponse: Decodable {
    let location: Location
    let current: Weather
}

struct Location : Decodable{
    let name: String
}

struct WeatherCondition : Decodable{
    let text: String
    let code: Int
}

struct Weather:Decodable {
    let temp_c: Float
    let temp_f: Float
    let condition: WeatherCondition
}

struct WeatherConditionsModel: Codable {
    let code : Int
    let day : String
    let night : String
}
