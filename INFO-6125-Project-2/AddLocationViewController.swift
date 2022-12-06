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
    
    var searchLocationText: String = ""
    
    var copyArr:[WeatherConditionsModel] = []
    
    var weatherResponseGlobal : WeatherResponse? = nil
    
    private let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        displayWeatherImage(code: 0);
//        displayDayNightImage()
//        loadWeatherCondition()

        locationManager.delegate = self
        self.searchTextField.delegate = self
        
    }
    
    @IBAction func onBackPress(_ sender: Any) {
        dismiss(animated: true)
    }
    
    


}
