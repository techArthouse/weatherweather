//
//  WeatherData.swift
//  WeatherApp
//
//  Created by Arturo Aguilar on 8/14/23.
//

import Foundation

// Models for mapping calls from openmapapi
struct WeatherData: Codable {
    let coord: Coordinate
    let weather: [Weather]
    let main: MainWeatherData
    let visibility: Int
    let wind: Wind
    let rain: Rain?
    let clouds: Clouds
    let name: String
}

struct Coordinate: Codable {
    let lon: Double
    let lat: Double
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct MainWeatherData: Codable {
    let temp: Double
    let feels_like: Double
    let temp_min: Double
    let temp_max: Double
    let pressure: Int
    let humidity: Int
}

struct Wind: Codable {
    let speed: Double
    let deg: Int
    let gust: Double?
}

struct Rain: Codable {
    let h1: Double?
    let h3: Double?
    
    enum CodingKeys: String, CodingKey {
        case h1 = "1h"
        case h3 = "3h"
    }
}

struct Clouds: Codable {
    let all: Int
}
