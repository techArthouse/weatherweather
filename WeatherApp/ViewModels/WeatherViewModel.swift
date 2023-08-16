//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Arturo Aguilar on 8/14/23.
//

import Foundation
import Combine

//protocol WeatherViewModelDelegate: AnyObject {
//    func didReceiveWeatherData(_ data: WeatherData)
//    func didReceiveError(_ error: Error)
//}


class WeatherViewModel {
    weak var delegate: APIViewControllerDelegate?

    var displayItems: [DisplayItem] = []

    var networkService: NetworkServiceType
    var imageFetchingService = ImageFetchingService()

    private var cancellables: Set<AnyCancellable> = []

    init(networkService: NetworkServiceType) {
        self.networkService = networkService
        if let concreteService = networkService as? NetworkService {
            concreteService.delegate = self
        }
        setupBindings()
    }
    
    deinit {
        print("WeatherViewModel deinit")
    }

    private func setupBindings() {
        imageFetchingService.imageSubject
            .sink { [weak self] icon, image in
                if let index = self?.displayItems.firstIndex(where: { $0.icon == icon }) {
                    self?.displayItems[index].image = image
                    self?.delegate?.didUpdateDisplayItems()
                }
            }
            .store(in: &cancellables)

        imageFetchingService.errorSubject
            .sink { icon, error in
                // Handle any image fetching error.
                print("Failed to fetch image for icon \(icon): \(error.localizedDescription)")
            }
            .store(in: &cancellables)
    }

    func populateWithMockData() {
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
        
        updateDisplayItems(with: dummyWeather)
    }

    func updateDisplayItems(with weather: WeatherData) {
        displayItems = [
            DisplayItem(key: "City", value: weather.name),
            DisplayItem(key: "Weather", value: weather.weather.first?.description ?? "N/A", icon: weather.weather.first?.icon as? String),
            DisplayItem(key: "Temperature", value: "\(weather.main.temp.kelvinToFahrenheit())°F"),
            DisplayItem(key: "Feels Like", value: "\(weather.main.feels_like.kelvinToFahrenheit())°F"),
            DisplayItem(key: "Temperature Min", value: "\(weather.main.temp_min.kelvinToFahrenheit())°F"),
            DisplayItem(key: "Temperature Max", value: "\(weather.main.temp_max.kelvinToFahrenheit())°F"),
            DisplayItem(key: "Pressure", value: "\(weather.main.pressure) hPa"),
            DisplayItem(key: "Humidity", value: "\(weather.main.humidity)%"),
            DisplayItem(key: "Visibility", value: "\(weather.visibility) meters"),
            DisplayItem(key: "Wind Speed", value: "\(weather.wind.speed) m/s"),
            DisplayItem(key: "Wind Degree", value: "\(weather.wind.deg)°"),
            DisplayItem(key: "Wind Gust", value: "\(weather.wind.gust ?? 0.0) m/s"),
            DisplayItem(key: "Rain (1h)", value: "\(weather.rain?.h1 ?? 0.0) mm"),
            DisplayItem(key: "Clouds", value: "\(weather.clouds.all)%")
        ]

        delegate?.didUpdateDisplayItems()
    }

    func fetchWeather(for city: String) {
        // not certain we still need this
    }
}




extension WeatherViewModel: NetworkServiceDelegate {
    func didReceiveData(_ data: WeatherData) {
        updateDisplayItems(with: data)
        UserDefaultsManager.saveLastSearchedCity(city: data.name)
    }
    
    func didFailWithError(_ error: Error) {
        print("woah")
    }
    
    
}
