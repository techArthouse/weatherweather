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
    @Published var isLoading: Bool = false
    @Published var isLocationAccessDenied: Bool = false
    @Published var locationManager: LocationManager
    private var userLocationSubscriber: AnyCancellable?
    private var userPermissionsnSubscriber: AnyCancellable?

    init(networkService: NetworkServiceType) {
        self.networkService = networkService
        self.locationManager = LocationManager()
        self.imageFetchingService = ImageFetchingService()
        
        userPermissionsnSubscriber = locationManager.$userLocation
        .compactMap { $0?.location }
        .sink { [weak self] newLocation in
            self?.fetchUserLocationWeather(for: newLocation)
        }
        
        userLocationSubscriber = locationManager.$isLocationAccessDenied
        .sink { [weak self] accessDenied in
            self?.isLocationAccessDenied = accessDenied
        }
    }
    
    deinit {
        print("HomeLocationWeatherViewModel is being deallocated!")
    }


    // Fetch user's local weather and update localWeather and localWeatherIcon
    func fetchUserLocationWeather(for location: CLLocation) {
        print("fetchUserLocationWeather is called for location: \(location)")
        isLoading = true
        networkService.fetchLocationName(from: location)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    print("Finished fetching location name.")
                    self?.isLoading = false
                case .failure(let error):
                    print("Error fetching location name: \(error.localizedDescription)")
                    // Handle error as needed
                }
            }, receiveValue: { [weak self] locationName in
                print("Received location name: \(locationName.name)")
                // Use the received location name to fetch weather data or update UI
                self?.searchLocalWeather(for: locationName.name)
            })
            .store(in: &cancellables)
        
    }
    
    func searchLocalWeather(for location: String) {
        isLoading = true
        networkService.fetchLocalWeatherData(for: location)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    print("Finished fetching local weather data.")
                    self?.isLoading = false
                case .failure(let error):
                    print("Error fetching local weather data: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] weatherData in
                print("Received weather data for: \(weatherData.name)")
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

