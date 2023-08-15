//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Arturo Aguilar on 8/14/23.
//

import Foundation
import Combine

protocol WeatherViewModelDelegate: AnyObject {
    func didReceiveWeatherData(_ data: WeatherData)
    func didReceiveError(_ error: Error)
}


class WeatherViewModel {
    weak var delegate: WeatherViewModelDelegate?
    private var cancellables: Set<AnyCancellable> = []

    func fetchWeatherData(for city: String) {
        NetworkService().fetchWeatherData(for: city)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.delegate?.didReceiveError(error)
                }
            }, receiveValue: { [weak self] data in
                self?.delegate?.didReceiveWeatherData(data)
            })
            .store(in: &cancellables)
    }
}

