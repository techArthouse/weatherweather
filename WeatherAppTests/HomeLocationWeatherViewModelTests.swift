//
//  HomeLocationWeatherViewModelTests.swift
//  WeatherAppTests
//
//  Created by Arturo Aguilar on 8/15/23.
//

import XCTest
import Combine
@testable import WeatherApp
import CoreLocation

class HomeLocationWeatherViewModelTests: XCTestCase {
    var viewModel: HomeLocationWeatherViewModel!
    var mockNetworkService: MockNetworkService!

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        viewModel = HomeLocationWeatherViewModel(networkService: mockNetworkService)
    }

    func testFetchingUserLocationWeatherSuccess() {
        // Given
        let mockLocationName = "London"
        let mockLocationData = LocationData(name: mockLocationName)
        mockNetworkService.locationDataToReturn = mockLocationData
        
        let mockWeatherData = WeatherData(
            coord: Coordinate(lon: -0.1278, lat: 51.5074),
            weather: [
                Weather(id: 500, main: "Rain", description: "light rain", icon: "10n")
            ],
            main: MainWeatherData(temp: 288.15, feels_like: 287.04, temp_min: 287.04, temp_max: 289.37, pressure: 1013, humidity: 87),
            visibility: 10000,
            wind: Wind(speed: 3.09, deg: 240, gust: 3.5),
            rain: Rain(h1: 0.76, h3: nil),
            clouds: Clouds(all: 40),
            name: mockLocationName
        )
        mockNetworkService.locationWeatherToReturn = mockWeatherData

        let mockLocation = CLLocation(latitude: 51.5074, longitude: -0.1278)

        // When
        viewModel.fetchUserLocationWeather(for: mockLocation)

        // Then
        XCTAssertEqual(viewModel.localWeather?.cityName, mockWeatherData.name)
        XCTAssertEqual(viewModel.localWeather?.iconName, mockWeatherData.weather.first?.icon)
        XCTAssertEqual(viewModel.localWeather?.temperature, mockWeatherData.main.temp)
    }

    override func tearDown() {
        mockNetworkService = nil
        viewModel = nil
        super.tearDown()
    }
}
