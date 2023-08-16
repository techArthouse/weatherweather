//
//  HomeLocationWeatherViewModel.swift
//  WeatherApp
//
//  Created by Arturo Aguilar on 8/15/23.
//

import Foundation
import SwiftUI
import Combine
import CoreLocation

class HomeLocationWeatherViewModel: ObservableObject {
    private let networkService: NetworkServiceType
    private var imageFetchingService: ImageFetchingService
    @Published var localWeather: LocationWeather?
    @Published var localWeatherIcon: Image?
    private var cancellables: Set<AnyCancellable> = []

    init(networkService: NetworkServiceType) {
        self.networkService = networkService
        imageFetchingService = ImageFetchingService()
    }

    // Fetch user's local weather and update localWeather and localWeatherIcon
    func fetchUserLocationWeather(for location: CLLocation) {
        networkService.fetchLocationName(from: location)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching location name: \(error)")
                    // Handle error as needed
                }
            }, receiveValue: { [weak self] locationName in
                // Use the received location name to fetch weather data or update UI
                self?.searchLocalWeather(for: locationName.name)
            })
            .store(in: &cancellables)
    }
    
    func searchLocalWeather(for location: String) {
        networkService.fetchLocalWeatherData(for: location)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error type2: \(type(of: error))")
                    print("Received a error: \(error)")
                }
            }, receiveValue: { [weak self] weatherData in
                guard let strongSelf = self else { return }
                self?.localWeather = LocationWeather(cityName: weatherData.name, iconName: weatherData.weather.first?.icon, temperature: weatherData.main.temp)
                
                // Now fetch icon
                if let iconName = self?.localWeather?.iconName {
                    
                    
                    // Subscribe to the imageSubject
                    strongSelf.imageFetchingService.imageSubject
                       .sink { [weak self] iconImagePair in
                           if iconImagePair.icon == iconName {
                               self?.localWeatherIcon = Image(uiImage: iconImagePair.image)
                           }
                       }
                       .store(in: &strongSelf.cancellables)
                    strongSelf.imageFetchingService.fetchImage(for: iconName)
                }
            })
            .store(in: &cancellables)
    }
}
