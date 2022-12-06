//
//  AddLocationViewController.swift
//  INFO-6125-Project-2
//
//  Created by Rajdeep Singh on 2022-11-29.
//

import UIKit
import CoreLocation


class AddLocationViewController: UIViewController,CLLocationManagerDelegate,UITextFieldDelegate {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var weatherConditionImage: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var locLabel: UILabel!

    @IBOutlet weak var weatherConditions: UILabel!
    
    var searchLocationText: String = ""
    
    var copyArr:[WeatherConditionsModel] = []
    
    var weatherResponseGlobal : WeatherResponse? = nil
    
    private let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        displayWeatherImage(code: 0);
        loadWeatherCondition()

        locationManager.delegate = self
        self.searchTextField.delegate = self
        
    }
    
    @IBAction func onBackPress(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchLocationText = searchTextField.text!
        loadWeather(search: searchLocationText)
        self.view.endEditing(true)

            return true
        }
    
    private func displayWeatherImage(code: Int) {
        let config = UIImage.SymbolConfiguration (paletteColors: [
            .systemYellow,
            .systemGray4, .systemYellow
        ])
        weatherConditionImage.preferredSymbolConfiguration=config
        
        print(code)
        
        switch code {
        case 0:
            self.weatherConditionImage.image = UIImage(systemName:"exclamationmark.triangle")
            
        case 1000:
            weatherConditionImage.image = UIImage (systemName: "sun.max")
        case 1003:
            weatherConditionImage.image = UIImage (systemName: "cloud.sun.circle.fill")
        case 1006:
            weatherConditionImage.image = UIImage (systemName: "cloud.sun")
        case 1009:
            weatherConditionImage.image = UIImage (systemName: "cloud")
        case 1030:
            weatherConditionImage.image = UIImage (systemName: "smoke.fill")
        case 1063:
            weatherConditionImage.image = UIImage (systemName: "cloud.sun.rain.circle")
        case 1066:
            weatherConditionImage.image = UIImage (systemName: "cloud.snow")
        case 1069:
            weatherConditionImage.image = UIImage (systemName: "cloud.sleet")
        case 1072:
            weatherConditionImage.image = UIImage (systemName: "cloud.drizzle.circle.fill")
        case 1087:
            weatherConditionImage.image = UIImage (systemName: "cloud.bolt.rain")
        case 1114:
            weatherConditionImage.image = UIImage (systemName: "cloud.snow")
        case 1117:
            weatherConditionImage.image = UIImage (systemName: "cloud.rain.circle")
        case 1135:
            weatherConditionImage.image = UIImage (systemName: "cloud.fog")
        case 1147:
            weatherConditionImage.image = UIImage (systemName: "cloud.fog")
        case 1150:
            weatherConditionImage.image = UIImage (systemName: "cloud.sun.rain.fill")
        case 1153:
            weatherConditionImage.image = UIImage (systemName: "cloud.sun.rain.fill")
        case 1168:
            weatherConditionImage.image = UIImage (systemName: "cloud.snow.circle")
        case 1183:
            weatherConditionImage.image = UIImage (systemName: "cloud.rain")
        case 1189 | 1192 | 1195 :
            weatherConditionImage.image = UIImage (systemName: "cloud.rain.circle.fill")
            
        default:
            print("No Data Found")
            self.weatherConditionImage.image = UIImage (systemName: "exclamationmark.trianglel")
        }
        
        
    }
    

    
    @IBAction func onLocationPredded(_ sender: UIButton) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    
    @IBAction func onSearchPressed(_ sender: UIButton) {
        searchLocationText = searchTextField.text!
        loadWeather(search: searchLocationText)
    }
    
    @IBAction func onCancelPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    

    func loadWeatherCondition() {
            guard let url = URL(string: "https://www.weatherapi.com/docs/weather_conditions.json") else {
                print("Invalid URL")
                return
            }
            let request = URLRequest(url: url)

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    if let response = try? JSONDecoder().decode([WeatherConditionsModel].self, from: data) {
                        DispatchQueue.main.async {
                            self.copyArr = response
                        }
                        return
                    }
                }
            }.resume()
        }
    
    
    func locationManager (_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print("Got location")
        
        if let location = locations.last {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        print ("LatLng: (\(latitude),\(longitude))")
            searchLocationText = "\(latitude),\(longitude)"
            loadWeather(search: searchLocationText)
            
        }
        
    }

        func locationManager (_ manager: CLLocationManager, didFailWithError error: Error) {
            print(error)
        }
    
    
    func loadWeather(search: String?) {
        
        
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
                self.displayData(weatherResp: self.weatherResponseGlobal!)
                
            }
            
        }
        
        //step 4 : start the task
        
        dataTask.resume();
        
    }
    
    func displayData(weatherResp: WeatherResponse)  {

        let filtered = self.copyArr.filter{ val in
          return val.code == weatherResp.current.condition.code
        }
            DispatchQueue.main.async {
                self.locLabel.text = weatherResp.location.name
                
                self.tempLabel.text = "\(weatherResp.current.temp_c) C°"
                                
                if filtered.count > 0 {
                    self.weatherConditions.text = weatherResp.current.condition.text
                    self.displayWeatherImage(code: weatherResp.current.condition.code)
                }
                
            }
        
        }
       
    
    private func getURL (query: String) -> URL? {
        let baseUrl = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "current.json"
        let apiKey = "e7d47e9bff3e46bebb9220627220512"
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


