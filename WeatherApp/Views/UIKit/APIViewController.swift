//
//  APIViewController.swift
//  WeatherApp
//
//  Created by Arturo Aguilar on 8/14/23.
//

import UIKit
import Combine

protocol APIViewControllerDelegate: AnyObject {
    func didReceiveWeatherData(data: WeatherData)
}

struct DisplayItem {
    var key: String
    var value: String
}

class APIViewController: UITableViewController, NetworkServiceDelegate {
    private var cancellables: Set<AnyCancellable> = []
    weak var delegate: APIViewControllerDelegate?
    var latestWeatherData: WeatherData?
    
    private var displayItems: [DisplayItem] = []
    
    let networkService: NetworkServiceType

    init(networkService: NetworkServiceType) {
        self.networkService = networkService
        super.init(nibName: nil, bundle: nil)
        if let concreteService = networkService as? NetworkService {
            concreteService.delegate = self
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        #if DEBUG
        populateWithMockData()
        #endif
    }

    // Here I just intended to show how existing UIKit framework can still work with swiftui wether its in conjunction or
    // temporary during a refactor or migration.
    @available(*, deprecated, message: "This method is deprecated. Use the delegates to update data.")
    func fetchWeather(for city: String) {
        // legacy way of handling network calls and requests involving delegates.
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
        tableView.reloadData()
    }
    
    func updateDisplayItems(with weather: WeatherData) {
        displayItems = [
            DisplayItem(key: "City", value: weather.name),
            DisplayItem(key: "Weather", value: weather.weather.first?.description ?? "N/A"),
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
    }

    // MARK: - UITableView DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let item = displayItems[indexPath.row]
        cell.textLabel?.text = item.key
        
        // Check for an existing valueLabel or create a new one
        let valueLabelTag = 1001
        var valueLabel: UILabel!
        
        if let existingLabel = cell.viewWithTag(valueLabelTag) as? UILabel {
            valueLabel = existingLabel
        } else {
            valueLabel = UILabel(frame: CGRect(x: cell.bounds.width - 150, y: 0, width: 130, height: cell.bounds.height))
            valueLabel.tag = valueLabelTag
            valueLabel.textAlignment = .right
            valueLabel.autoresizingMask = [.flexibleLeftMargin, .flexibleHeight] // to adjust with cell resizing
            cell.addSubview(valueLabel)
        }
        
        valueLabel.text = item.value

        return cell
    }

    // MARK: - NetworkServiceDelegate Methods
    func didReceiveData(_ data: WeatherData) {
        // Handle or process the received data if needed
        print("Received data via delegate: \(data)")
        updateDisplayItems(with: data)
        latestWeatherData = data
        tableView.reloadData()
    }

    func didFailWithError(_ error: Error) {
        // Handle the error
        print("Error occurred: \(error)")
        showErrorAlert(error: error)
    }
    
    // Helper method to show an error
    func showErrorAlert(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}


extension Double {
    func kelvinToFahrenheit() -> Double {
        return (self * 9/5 - 459.67).rounded()
    }
}
