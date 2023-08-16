//
//  UserDefaultManager.swift
//  WeatherApp
//
//  Created by Arturo Aguilar on 8/15/23.
//

import Foundation

// Simple manager leveraging UserDefaults
struct UserDefaultsManager {
    static let lastSearchedCityKey = "lastSearchedCityKey"

    static func saveLastSearchedCity(city: String) {
        UserDefaults.standard.set(city, forKey: lastSearchedCityKey)
    }

    static func getLastSearchedCity() -> String? {
        return UserDefaults.standard.string(forKey: lastSearchedCityKey)
    }
}
