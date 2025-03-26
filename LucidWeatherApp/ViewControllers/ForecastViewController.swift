//
//  ForecastViewController.swift
//  LucidWeatherApp
//
//  Created by Mario Ban on 25.03.2025..
//

import UIKit
import CoreLocation

class ForecastViewController: UIViewController {
    
    let cities = ["New York", "London", "Paris", "Rome"]
    var weatherManager: WeatherManager!
    var selectedWeather: WeatherResponse?
    
    @IBAction func getMyLocation(_ sender: UIButton) {
        weatherManager.requestLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.largeContentTitle = "Forecast"
        
        weatherManager = WeatherManager()
        weatherManager.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showForecastDetails" {
            if let detailVC = segue.destination as? ForecastDetailsViewController {
                detailVC.weatherResponse = selectedWeather
            }
        }
    }
}


extension ForecastViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlainTableViewCell") as! PlainTableViewCell
        cell.textLabel?.text = cities[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedCity = cities[indexPath.row]
        fetchWeatherForCity(selectedCity)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

extension ForecastViewController {

    func fetchWeatherForCity(_ city: String) {
        ApiService.shared.fetchWeatherData(for: city, units: "metric") { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let weatherResponse):
                    print("Weather for \(city): \(weatherResponse)")
                    
                    self.selectedWeather = weatherResponse
                    self.performSegue(withIdentifier: "showForecastDetails", sender: nil)
                                    
                case .failure(let error):
                    print("Error fetching weather for \(city): \(error.localizedDescription)")
                }
            }
        }
    }
}

extension ForecastViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weather: WeatherResponse) {
        print("Weather updated: \(weather)")
    }
    
    func didFailWithError(_ error: Error) {
        print("Failed to update weather: \(error.localizedDescription)")
    }
}
