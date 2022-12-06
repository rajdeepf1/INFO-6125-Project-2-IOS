//
//  DetailScreenViewController.swift
//  INFO-6125-Project-2
//
//  Created by Rajdeep Singh on 2022-12-05.
//

import UIKit

class DetailScreenViewController: UIViewController{
    
    
    var latitude: String = ""
    var longitude: String = ""
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var currentWeatherConditionsLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var highLowTempLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var forecastArray:[ForecastDayDetailScreen] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(latitude)
        print(longitude)
        
        // Do any additional setup after loading the view.
        
        loadWeather(latitude: latitude, longitude: longitude, days: 1)
        
        
    }
    
    @IBAction func onBackPress(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    // load weather api
    func loadWeather(latitude:String,longitude:String,days:Int) {
        
        let search: String? = "\(latitude),\(longitude)"
        
        guard let search = search else {
            return
        }
        // Step 1: Get URL
        guard let url = getURL (query: search,days: days) else {
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
                
                
                DispatchQueue.main.async {
                    
                    //print(weatherResponse)
                    
                    self.locationLabel.text = weatherResponse.location.name
                    self.currentWeatherConditionsLabel.text = weatherResponse.current.condition.text
                    self.tempLabel.text = "\(weatherResponse.current.temp_c) C°"
                    self.highLowTempLabel.text = "High Temp: \(weatherResponse.forecast.forecastday[0].day.maxtemp_c) C° & Low Temp: \(weatherResponse.forecast.forecastday[0].day.mintemp_c) C°"
                    
                    let config = UIImage.SymbolConfiguration (paletteColors: [
                        .systemYellow,
                        .systemGray4, .systemYellow
                    ])
                    self.weatherImage.preferredSymbolConfiguration=config
                    var systemImg: String = self.displayWeatherImage(code: weatherResponse.current.condition.code)
                    self.weatherImage.image = UIImage(systemName:systemImg)
                    
                }
                
                self.loadWeatherSevenDaysForecast(latitude: latitude, longitude: longitude, days: 10)
                
            }
            
        }
        
        //step 4 : start the task
        
        dataTask.resume();
        
    }
    
    // load weather api
    func loadWeatherSevenDaysForecast(latitude:String,longitude:String,days:Int) {
        
        let search: String? = "\(latitude),\(longitude)"
        
        guard let search = search else {
            return
        }
        // Step 1: Get URL
        guard let url = getURL (query: search,days: days) else {
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
                
                self.forecastArray = weatherResponse.forecast.forecastday
                DispatchQueue.main.async {
                    self.tableView.dataSource = self
                }


            }
            
        }
        
        //step 4 : start the task
        
        dataTask.resume();
        
    }
    
    private func getURL (query: String,days: Int) -> URL? {
        let baseUrl = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "forecast.json"
        let apiKey = "e7d47e9bff3e46bebb9220627220512"
        guard let url = "\(baseUrl)\(currentEndpoint)?key=\(apiKey)&q=\(query)&days=\(days)&aqi=no&alerts=no"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
            return nil
        }
        print(url)
        return URL(string: url)
    }
    
    private func parseJson(data: Data) -> WeatherResponseDetailScreen?{
        let decoder = JSONDecoder()
        var weather: WeatherResponseDetailScreen?
        do {
            weather = try decoder.decode (WeatherResponseDetailScreen.self, from: data)
        } catch {
            print ("Error decoding")
        }
        return weather
    }
    
    private func displayWeatherImage(code: Int)-> String {
        
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
    
    
}

extension DetailScreenViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecastArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "toDoCell",for: indexPath)
        
        let item = forecastArray[indexPath.row]

        var content = cell.defaultContentConfiguration()
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "EEEE"

        if let date = dateFormatterGet.date(from: item.date) {
            content.text = dateFormatterPrint.string(from: date)

        } else {
           print("There was an error decoding the string")
        }
        
        content.secondaryText = "\(item.day.avgtemp_c) C°"
        
        var systemImg: String = self.displayWeatherImage(code: item.day.condition.code)
        
        content.image = UIImage(systemName: systemImg)
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    
}

struct WeatherResponseDetailScreen: Decodable {
    let location: Location
    let current: Weather
    let forecast:ForecastDetailScreen
}

struct WeatherDetailScreen:Decodable {
    let temp_c: Float
    let temp_f: Float
    let feelslike_c: Float
    
    let condition: WeatherCondition
}

struct WeatherConditionDetailScreen : Decodable{
    let text: String
    let code: Int
}

struct LocationDetailScreen : Decodable{
    let name: String
}

struct ForecastDetailScreen : Decodable{
    let forecastday : [ForecastDayDetailScreen]
}

struct ForecastDayDetailScreen : Decodable{
    let date: String
    let day : DayObject
}

struct DayObject: Decodable {
    let maxtemp_c: Float
    let mintemp_c: Float
    let avgtemp_c :Float
    let condition : WeatherConditionDetailScreen
}



