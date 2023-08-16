//
//  LocationData.swift
//  WeatherApp
//
//  Created by Arturo Aguilar on 8/15/23.
//

import Foundation

struct LocationData: Decodable {
    let name: String
}

struct LocationWeather {
    var cityName: String
    var iconName: String?
    var temperature: Double
}
