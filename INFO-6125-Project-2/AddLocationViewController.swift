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
    
    let defaults = UserDefaults.standard

    
    
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
        
        self.weatherConditionImage.image = UIImage(systemName:displayWeatherImageString(code: code))
        
        
    }
    
    private func displayWeatherImageString(code: Int)-> String {
        
        print(code)
        
        var imageStr : String = ""
        
        switch code {
        case 0:
            imageStr = "exclamationmark.triangle"
            break
        case 1000:
            imageStr = "sun.max"
            break
        case 1003:
            imageStr = "cloud.sun.circle.fill"
            break
        case 1006:
            imageStr = "cloud.sun"
            break
        case 1009:
            imageStr = "cloud"
            break
        case 1030:
            imageStr = "smoke.fill"
            break
        case 1063:
            imageStr = "cloud.sun.rain.circle"
            break
        case 1066:
            imageStr = "cloud.snow"
            break
        case 1069:
            imageStr = "cloud.sleet"
            break
        case 1072:
            imageStr = "cloud.drizzle.circle.fill"
            break
        case 1087:
            imageStr = "cloud.bolt.rain"
            break
        case 1114:
            imageStr = "cloud.snow"
            break
        case 1117:
            imageStr = "cloud.rain.circle"
            break
        case 1135:
            imageStr = "cloud.fog"
            break
        case 1147:
            imageStr = "cloud.fog"
            break
        case 1150:
            imageStr =  "cloud.sun.rain.fill"
            break
        case 1153:
            imageStr =  "cloud.sun.rain.fill"
            break
        case 1168:
            imageStr =  "cloud.snow.circle"
            break
        case 1183:
            imageStr =  "cloud.rain"
            break
        case 1213:
            imageStr =  "snowflake.circle"
            break
        case 1189 | 1192 | 1195 :
            imageStr =  "cloud.rain.circle.fill"
            break
        default:
            print("No Data Found")
            imageStr =  "exclamationmark.triangle"
            break
        }
        
        return imageStr
        
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
    
    func getDataFromLocalStorage() -> String {
        guard let getData = defaults.string(forKey: "API_KEY_DATA") else { return "" }
                
        return getData
    }
       
    // api_key = e7d47e9bff3e46bebb9220627220512
    private func getURL (query: String) -> URL? {
        let baseUrl = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "current.json"
        let apiKey = getDataFromLocalStorage()
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


