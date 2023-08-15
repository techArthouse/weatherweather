//
//  NetworkService.swift
//  WeatherApp
//
//  Created by Arturo Aguilar on 8/14/23.
//

import Foundation
import Combine

protocol NetworkServiceDelegate: AnyObject {
    func didReceiveData(_ data: WeatherData)
    func didFailWithError(_ error: Error)
}

class NetworkService: NetworkServiceType {
    
    let apiKey = "ad1e144e7d20547f2a13b74deca05137" // It's better to keep this secure, but for this project, I'm leaving it here.
    weak var delegate: NetworkServiceDelegate?
    
    // We keep a reference to the cancellable object to avoid the pipeline being deallocated.
    private var cancellables: Set<AnyCancellable> = []

    func fetchWeatherData(for city: String) -> AnyPublisher<WeatherData, Error> {
        // spaces need to be percent encoded
        let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? city
        let endpoint = "https://api.openweathermap.org/data/2.5/weather?q=\(encodedCity)&appid=\(apiKey)"

        
        guard let url = URL(string: endpoint) else {
            delegate?.didFailWithError(URLError(.badURL))
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        let publisher = URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { response -> Data in
                guard let httpResponse = response.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    self.delegate?.didFailWithError(URLError(.badServerResponse))
                    throw URLError(.badServerResponse)
                }
                return response.data
            }
            .decode(type: WeatherData.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main) // Ensure we receive on the main thread to update the UI.
            .handleEvents(receiveOutput: { [weak self] data in
                self?.delegate?.didReceiveData(data)
            })
            .eraseToAnyPublisher()

        // Store in cancellables set to prevent premature deallocation
        publisher
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)

        return publisher
    }
}
