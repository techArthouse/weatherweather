//
//  SearchWeatherViewModelTests.swift
//  WeatherAppTests
//
//  Created by Arturo Aguilar on 8/15/23.
//

import XCTest
import Combine
@testable import WeatherApp
import CoreLocation

class MockNetworkService: NetworkServiceType {
    var weatherDataToReturn: WeatherData?
    var locationDataToReturn: LocationData?
    var errorToReturn: APIError?
    
    var locationWeatherToReturn: WeatherData?


    func fetchWeatherData(for city: String) -> AnyPublisher<WeatherData, APIError> {
        if let error = errorToReturn {
            return Fail(error: error).eraseToAnyPublisher()
        }
        return Just(weatherDataToReturn!)
            .setFailureType(to: APIError.self)
            .eraseToAnyPublisher()
    }

    func fetchLocationName(from location: CLLocation) -> AnyPublisher<LocationData, Error> {
        if let error = errorToReturn {
            return Fail(error: error).mapError { $0 as Error }.eraseToAnyPublisher()
        }
        return Just(locationDataToReturn!)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchLocalWeatherData(for city: String) -> AnyPublisher<WeatherData, Error> {
        if let error = errorToReturn {
            return Fail(error: error).eraseToAnyPublisher()
        }
        guard let weatherData = locationWeatherToReturn else {
            return Fail(error: APIError(cod: "404", message: "Data not set in mock")).eraseToAnyPublisher()
        }
        return Just(weatherData).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

// A basic unit test for SearchWeatherViewModelTests. This is to demonstrate the setup of test, although the value of it
// right now is admittedly low because of the nature of this viewmodel where it calls the service then defers (other viewmodels listen for changes)
class SearchWeatherViewModelTests: XCTestCase {
    var viewModel: SearchWeatherViewModel!
    var mockNetworkService: MockNetworkService!

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        viewModel = SearchWeatherViewModel(networkService: mockNetworkService)
    }

//    func testSearchWeatherSuccess() {
//        // Given
//        let mockWeatherData = WeatherData(
//            coord: Coordinate(lon: 0.0, lat: 0.0),
//            weather: [
//                Weather(id: 500, main: "Rain", description: "light rain", icon: "10n")
//            ],
//            main: MainWeatherData(temp: 288.15, feels_like: 287.04, temp_min: 287.04, temp_max: 289.37, pressure: 1013, humidity: 87),
//            visibility: 10000,
//            wind: Wind(speed: 3.09, deg: 240, gust: 3.5),
//            rain: Rain(h1: 0.76, h3: nil),
//            clouds: Clouds(all: 40),
//            name: "London"
//        )
//        mockNetworkService.weatherDataToReturn = mockWeatherData
//
//        // When
//        viewModel.searchText = "London"
//        viewModel.searchWeather()
//
//        // Then
//
//        // Asserting the cityName
//        XCTAssertEqual(viewModel.userLocationWeather?.cityName, mockWeatherData.name)
//
//        // Asserting the iconName 
//        XCTAssertEqual(viewModel.userLocationWeather?.iconName, mockWeatherData.weather[0].icon)
//
//        // Asserting the temperature
//        XCTAssertEqual(viewModel.userLocationWeather?.temperature, mockWeatherData.main.temp)
//    }


    func testSearchWeatherFailure() {
        // Given
        let mockError = APIError(cod: "404", message: "City not found")
        mockNetworkService.errorToReturn = mockError

        // When
        viewModel.searchText = "InvalidCity"
        viewModel.searchWeather()

        // Then
        XCTAssertNotNil(viewModel.errorWrapper)
        XCTAssertEqual(viewModel.errorWrapper?.cod, "404")
        XCTAssertEqual(viewModel.errorWrapper?.message, "City not found")
        // ... any other assertions for other properties
    }

    // Add more tests...

    override func tearDown() {
        mockNetworkService = nil
        viewModel = nil
        super.tearDown()
    }
}

