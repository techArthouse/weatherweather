//
//  LocationData.swift
//  WeatherApp
//
//  Created by Arturo Aguilar on 8/15/23.
//

import Foundation

// Model used when reverse looking up location with geocode.
struct LocationData: Decodable {
    let name: String
}

// model for capturing data when looking up local weather. Don't need much. 
struct LocationWeather {
    var cityName: String
    var iconName: String?
    var temperature: Double
}
