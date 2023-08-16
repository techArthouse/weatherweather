//
//  NetworkService.swift
//  WeatherApp
//
//  Created by Arturo Aguilar on 8/14/23.
//

import Foundation
import Combine
import CoreLocation

protocol NetworkServiceType {
    func fetchWeatherData(for city: String) -> AnyPublisher<WeatherData, APIError>
    func fetchLocationName(from location: CLLocation) -> AnyPublisher<LocationData, Error>
    func fetchLocalWeatherData(for city: String) -> AnyPublisher<WeatherData, Error>
}

protocol NetworkServiceDelegate: AnyObject {
    func didReceiveData(_ data: WeatherData)
    func didFailWithError(_ error: Error)
}

/* Here we use combine for a more reactive approach to how we handle data.
   My intention was to stick to MVVM with swiftui and combine stack while using a mix
   of mvvm and delegates with uikit as commondly used. 
 */
class NetworkService: NetworkServiceType {

    let apiKey = "ad1e144e7d20547f2a13b74deca05137" // It's better to keep this secure, but for this project, I'm leaving it here.
    weak var delegate: NetworkServiceDelegate?
    
    // We keep a reference to the cancellable object to avoid the pipeline being deallocated.
    private var cancellables: Set<AnyCancellable> = []

    // since we store in canceallables we can expect to discard result is ok.
    @discardableResult
    func fetchWeatherData(for city: String) -> AnyPublisher<WeatherData, APIError> {
        let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? city
        let endpoint = "https://api.openweathermap.org/data/2.5/weather?q=\(encodedCity)&appid=\(apiKey)"

        guard let url = URL(string: endpoint) else {
            delegate?.didFailWithError(URLError(.badURL))
            return Fail(error: APIError(customDescription: "Bad URL")).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { response -> Data in
                guard let httpResponse = response.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }

                if let jsonString = String(data: response.data, encoding: .utf8) {
                    print("Response JSON: \(jsonString)")
                }

                if httpResponse.statusCode == 200 {
                    return response.data
                } else {
                    do {
                        let apiError = try JSONDecoder().decode(APIError.self, from: response.data)
                        // leave breadcrump as APIError to infer that if error type changes we're dealing with a combine side effect.
                        throw apiError
                    } catch {
                        throw URLError(.badServerResponse)
                    }
                }
            }
            .decode(type: WeatherData.self, decoder: JSONDecoder())
        
        /*
         Some notes on errorhandling. I encountered an issue where combine changes the error type with URLSession.shared.dataTaskPublisher(for: url),
         so it propogates as NSError instead of APIError
         */
            .catch { error -> Fail<WeatherData, APIError> in
                if let nsError = error as? NSError, nsError.domain == NSURLErrorDomain {
                    // log appearance as NSError
                    
                    return Fail(error: APIError(customDescription: "Please Try again")) // Hardcoded but trace and logging explained in notes.
                } else if let apiError = error as? APIError {
                    return Fail(error: apiError)
                } else {
                    return Fail(error: APIError(customDescription: "Unknown error"))
                }
            }
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] data in
                self?.delegate?.didReceiveData(data)
            })
            .eraseToAnyPublisher()
    }
    
    // Get local weather without passing through delegates. Even though method is similar to fetchWeatherData, this
    // is a demonstration of separation of concerns especially since fetchWeatherData is part of the (theoretical) older flow with delegates.
    func fetchLocalWeatherData(for city: String) -> AnyPublisher<WeatherData, Error> {
        let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? city
        let endpoint = "https://api.openweathermap.org/data/2.5/weather?q=\(encodedCity)&appid=\(apiKey)"

        guard let url = URL(string: endpoint) else {
            delegate?.didFailWithError(URLError(.badURL))
            return Fail(error: APIError(customDescription: "Bad URL")).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { response -> Data in
                guard let httpResponse = response.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }

                if let jsonString = String(data: response.data, encoding: .utf8) {
                    print("Response JSON: \(jsonString)")
                }

                if httpResponse.statusCode == 200 {
                    return response.data
                } else {
                    do {
                        let apiError = try JSONDecoder().decode(APIError.self, from: response.data)
                        // leave breadcrump as APIError to infer that if error type changes we're dealing with a combine side effect.
                        throw apiError
                    } catch {
                        throw URLError(.badServerResponse)
                    }
                }
            }
            .decode(type: WeatherData.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }



    
    func fetchLocationName(from location: CLLocation) -> AnyPublisher<LocationData, Error> {
        let apiURL = "https://api.openweathermap.org/geo/1.0/reverse?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&limit=1&appid=\(apiKey)"
        
        guard let url = URL(string: apiURL) else {
            delegate?.didFailWithError(URLError(.badURL))
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { response -> Data in
                guard let httpResponse = response.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    self.delegate?.didFailWithError(URLError(.badServerResponse))
                    throw URLError(.badServerResponse)
                }
                return response.data
            }
            .decode(type: [LocationData].self, decoder: JSONDecoder()) // Since the response is an array of LocationData
            .map { $0.first }  // We're only interested in the first result
            .compactMap { $0 } // Convert optional to non-optional
            .receive(on: DispatchQueue.main) // Ensure we receive on the main thread to update the UI.
            .eraseToAnyPublisher()
    }
}
