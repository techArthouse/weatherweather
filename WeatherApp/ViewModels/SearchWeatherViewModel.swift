//
//  SearchWeatherViewModel.swift
//  WeatherApp
//
//  Created by Arturo Aguilar on 8/14/23.
//

import Foundation
import CoreLocation
import Combine
import SwiftUI

// Note the published vars that are used to listen for updates in other classes.
class SearchWeatherViewModel: ObservableObject {
    private let networkService: NetworkServiceType
    private var imageFetchingService: ImageFetchingService
    @Published var searchText: String = ""
    private var cancellables: Set<AnyCancellable> = []
    @Published var errorWrapper: ErrorWrapper? // See class for details.

    init(networkService: NetworkServiceType) {
        self.networkService = networkService
        self.imageFetchingService = ImageFetchingService()
    }

    func searchWeather() {
        guard !searchText.isEmpty else { return }
        networkService.fetchWeatherData(for: searchText)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error type2: \(type(of: error))")
                    if let apiError = error as? APIError {
                        // Handle specific API error
                        self.errorWrapper = ErrorWrapper(error: apiError)
                    } else {
                        // Handle other errors
                        print("Received a non-API error: \(error)")
                    }
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    // Method used to reverse locate the user after permission to location is granted.
    func searchWeather(at location: CLLocation) {
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
                self?.searchText = locationName.name
                self?.searchWeather()
            })
            .store(in: &cancellables)
    }
    
    func handle(error: APIError) {
        self.errorWrapper = ErrorWrapper(error: error)
        // Reset after a short delay to allow the View to handle it
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.errorWrapper = nil
        }
    }
}

// A wrapper was necessary as Error is not Equitable so listening in or error variables using swiftui framework doesn't
// work unless the variable is equatable. In this manner errors can be handled with swiftui binding.
struct ErrorWrapper: Equatable {
    let error: APIError

    static func ==(lhs: ErrorWrapper, rhs: ErrorWrapper) -> Bool {
        return lhs.error.localizedDescription == rhs.error.localizedDescription
    }
    
    var cod: String? {
        return error.cod
    }
    
    var message: String? {
        if let message = error.customDescription {
            return message
        }
        return error.message
    }
}
