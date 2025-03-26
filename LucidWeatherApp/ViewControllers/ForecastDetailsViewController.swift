//
//  ForecastDetailsViewController.swift
//  LucidWeatherApp
//
//  Created by Mario Ban on 25.03.2025..
//

import UIKit
import CoreData

class ForecastDetailsViewController: UIViewController {
    
    @IBOutlet weak var segemntedUnits: UISegmentedControl!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var feelsLike: UILabel!
    @IBOutlet weak var tempMin: UILabel!
    @IBOutlet weak var tempMax: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var pressure: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    @IBOutlet weak var windSpeed: UILabel!
    
    var weatherResponse: WeatherResponse?
    
    @IBAction func saveToDatabase(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.largeContentTitle = "Forecast details"
        
        
        if let weatherResponse = weatherResponse {
            cityName.text = weatherResponse.name
            temperature.text = String(format: "Temperature: %.1f°C", weatherResponse.main.temp)
            feelsLike.text = String(format: "Feels like: %.1f°C", weatherResponse.main.feelsLike)
            tempMin.text = String(format: "Min temp: %.1f°C", weatherResponse.main.tempMin)
            tempMax.text = String(format: "Max temp: %.1f°C", weatherResponse.main.tempMax)
            pressure.text = String(format: "Pressure: %d hPa", weatherResponse.main.pressure)
            weatherDescription.text = "Description: \(weatherResponse.weather.first?.description ?? "N/A")"
            windSpeed.text = String(format: "Wind: %.1f m/s", weatherResponse.wind.speed)
            humidity.text = "Humidity: \(weatherResponse.main.humidity)%"
        }
    }

}
