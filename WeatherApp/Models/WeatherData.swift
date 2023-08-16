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


// For testing purposes

extension Coordinate: Equatable {
    static func == (lhs: Coordinate, rhs: Coordinate) -> Bool {
        return lhs.lon == rhs.lon && lhs.lat == rhs.lat
    }
}

extension Weather: Equatable {
    static func == (lhs: Weather, rhs: Weather) -> Bool {
        return lhs.id == rhs.id &&
               lhs.main == rhs.main &&
               lhs.description == rhs.description &&
               lhs.icon == rhs.icon
    }
}

extension MainWeatherData: Equatable {
    static func == (lhs: MainWeatherData, rhs: MainWeatherData) -> Bool {
        return lhs.temp == rhs.temp &&
               lhs.feels_like == rhs.feels_like &&
               lhs.temp_min == rhs.temp_min &&
               lhs.temp_max == rhs.temp_max &&
               lhs.pressure == rhs.pressure &&
               lhs.humidity == rhs.humidity
    }
}

extension Wind: Equatable {
    static func == (lhs: Wind, rhs: Wind) -> Bool {
        return lhs.speed == rhs.speed &&
               lhs.deg == rhs.deg &&
               lhs.gust == rhs.gust
    }
}

extension Rain: Equatable {
    static func == (lhs: Rain, rhs: Rain) -> Bool {
        return lhs.h1 == rhs.h1 && lhs.h3 == rhs.h3
    }
}

extension Clouds: Equatable {
    static func == (lhs: Clouds, rhs: Clouds) -> Bool {
        return lhs.all == rhs.all
    }
}

extension WeatherData: Equatable {
    static func == (lhs: WeatherData, rhs: WeatherData) -> Bool {
        return lhs.coord == rhs.coord &&
               lhs.weather == rhs.weather &&
               lhs.main == rhs.main &&
               lhs.visibility == rhs.visibility &&
               lhs.wind == rhs.wind &&
               lhs.rain == rhs.rain &&
               lhs.clouds == rhs.clouds &&
               lhs.name == rhs.name
    }
}

