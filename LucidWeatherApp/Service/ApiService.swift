//
//  ApiService.swift
//  LucidWeatherApp
//
//  Created by Mario Ban on 25.03.2025..
//

import Foundation

enum ApiError: Error {
    case invalidURL
    case invalidStatusCode(Int)
    case emptyData
}

protocol ApiServiceRepository {
    func fetchCityWeather(for city: String, units: String?, completion: @escaping (Result<WeatherResponse, Error>) -> Void)
    func fetchCoordinatesWeather(longitude: String, latitude: String, units: String?, completion: @escaping (Result<WeatherResponse, Error>) -> Void)
    func buildCityURL(city: String, units: String?) -> URL?
    func buildCoordinateURL(latitude: String, longitude: String, units: String?) -> URL?
}

class ApiService: ApiServiceRepository {
    
    static let shared = ApiService()
    
    private init() {}
    
    private let apiKey: String = {
        guard let filePath = Bundle.main.path(forResource: "api-key", ofType: "plist") else {
            fatalError("Could not find 'api-key.plist' file in the bundle.")
        }
        
        guard let plist = NSDictionary(contentsOfFile: filePath) else {
            fatalError("Could not read 'api-key.plist' as NSDictionary.")
        }
        
        guard let key = plist["API_KEY"] as? String else {
            fatalError("Could not find 'API_KEY' key in 'api-key.plist'.")
        }
        
        return key
    }()
    
    func fetchCityWeather(for city: String, units: String? = "metric", completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        guard let url = buildCityURL(city: city, units: units ?? "metric") else {
            completion(.failure(ApiError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                completion(.failure(ApiError.invalidStatusCode(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(ApiError.emptyData))
                return
            }
            
            do {
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                completion(.success(weatherResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchCoordinatesWeather(longitude: String, latitude: String, units: String? = "metric", completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        guard let url = buildCoordinateURL(latitude: latitude, longitude: longitude, units: units) else {
            completion(.failure(ApiError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                completion(.failure(ApiError.invalidStatusCode(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(ApiError.emptyData))
                return
            }
            do {
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                completion(.success(weatherResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    internal func buildCityURL(city: String, units: String?) -> URL? {
        var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")
        components?.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "units", value: units),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        return components?.url
    }
    
    internal func buildCoordinateURL(latitude: String, longitude: String, units: String?) -> URL? {
        var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")
        components?.queryItems = [
            URLQueryItem(name: "lat", value: latitude),
            URLQueryItem(name: "lon", value: longitude),
            URLQueryItem(name: "units", value: units),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        return components?.url
    }
}
