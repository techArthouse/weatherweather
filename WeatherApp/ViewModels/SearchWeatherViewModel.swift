//
//  SearchWeatherViewModel.swift
//  WeatherApp
//
//  Created by Arturo Aguilar on 8/14/23.
//

import Foundation

class SearchWeatherViewModel: ObservableObject {
    private let networkService: NetworkServiceType

    init(networkService: NetworkServiceType) {
        self.networkService = networkService
    }

    func searchWeather(for city: String) {
        networkService.fetchWeatherData(for: city)
    }
}
