//
//  WeatherResponse.swift
//  LucidWeatherApp
//
//  Created by Mario Ban on 25.03.2025..
//

struct WeatherResponse: Decodable {
    let coord: Coord
    let weather: [Weather]
    let main: Main
    let wind: Wind
    let timezone: Int
    let name: String
}

struct Coord: Decodable {
    let lon: Double
    let lat: Double
}

struct Weather: Decodable {
    let main: String
    let description: String
}


struct Main: Decodable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    let seaLevel: Int?
    let grndLevel: Int?
    
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case humidity
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
    }
}

struct Wind: Decodable {
    let speed: Double
}
