//
//  WeatherManager.swift
//  LucidWeatherApp
//
//  Created by Mario Ban on 25.03.2025..
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate: AnyObject {
    func didUpdateWeather(_ weather: WeatherResponse)
    func didFailWithError(_ error: Error)
}

class WeatherManager: NSObject {
    
    private let locationManager = CLLocationManager()
    private let apiService: ApiServiceRepository
    weak var delegate: WeatherManagerDelegate?
    
    private var hasUpdatedLocation = false
    
    init(apiService: ApiServiceRepository = ApiService.shared) {
        self.apiService = apiService
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        hasUpdatedLocation = false
    }
}

extension WeatherManager: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            case .denied, .restricted:
                delegate?.didFailWithError(ApiError.invalidURL)
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                break
            @unknown default:
                break
            }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last, !hasUpdatedLocation else { return }
        
        hasUpdatedLocation = true
        locationManager.stopUpdatingLocation()
        
        let latStr = String(currentLocation.coordinate.latitude)
        let lonStr = String(currentLocation.coordinate.longitude)
        
        apiService.fetchForecastData(longitude: lonStr, latitude: latStr, units: "metric") { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let weatherResponse):
                    self?.delegate?.didUpdateWeather(weatherResponse)
                case .failure(let error):
                    self?.delegate?.didFailWithError(error)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.didFailWithError(error)
    }
}
