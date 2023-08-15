//
//  MockNetworkService.swift
//  WeatherApp
//
//  Created by Arturo Aguilar on 8/14/23.
//

import Foundation
import Combine

protocol NetworkServiceType {
    func fetchWeatherData(for city: String) -> AnyPublisher<WeatherData, Error>
}

class MockNetworkService: NetworkServiceType {
    weak var delegate: NetworkServiceDelegate?
    
    func fetchWeatherData(for city: String) -> AnyPublisher<WeatherData, Error> {
        let dummyWeather = WeatherData(
            coord: Coordinate(lon: 0.0, lat: 0.0),
            weather: [
                Weather(id: 500, main: "Rain", description: "light rain", icon: "10n")
            ],
            main: MainWeatherData(temp: 288.15, feels_like: 287.04, temp_min: 287.04, temp_max: 289.37, pressure: 1013, humidity: 87),
            visibility: 10000,
            wind: Wind(speed: 3.09, deg: 240, gust: 3.5),
            rain: Rain(h1: 0.76, h3: nil),
            clouds: Clouds(all: 40),
            name: "London"
        )
        
        // Simulate network delay
        return Future<WeatherData, Error> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                self.delegate?.didReceiveData(dummyWeather)
                promise(.success(dummyWeather))
            }
        }
        .eraseToAnyPublisher()
    }
}

