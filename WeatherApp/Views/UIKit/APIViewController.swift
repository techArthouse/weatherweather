//
//  APIViewController.swift
//  WeatherApp
//
//  Created by Arturo Aguilar on 8/14/23.
//

import UIKit
import Combine

// Delegate patter used here to showcase how an existing framework or paradigm commonly used with UIKit and
// non reactive programming can be preserved in part or entirely while leverageing a more modern framework like
// SwiftUI and Combine.
protocol APIViewControllerDelegate: AnyObject {
    func didReceiveWeatherData(data: WeatherData)
    func didUpdateDisplayItems()
}

// This class will show the results of a search in a table. Using UIKit for reasons stated above.
class APIViewController: UITableViewController {
    private var viewModel: WeatherViewModel!
    private var cancellables: Set<AnyCancellable> = []
    
    // Closure to inform the parent when data is available
    var onDataAvailable: (() -> Void)?


    // Dependency Injection through the initializer
    init(networkService: NetworkServiceType) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = WeatherViewModel(networkService: networkService)
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(WeatherDetailCell.self, forCellReuseIdentifier: "WeatherDetailCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
    }

    // MARK: - UITableView DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.displayItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherDetailCell", for: indexPath) as! WeatherDetailCell

        let item = viewModel.displayItems[indexPath.row]
        cell.titleLabel.text = item.key
        
        // separate process to fetch icons concurrently
        if let iconName = item.icon {
            if let image = viewModel.imageFetchingService.cachedImage(for: iconName) {
                cell.iconImageView.image = image
                cell.valueLabel.text = item.value
            } else {
                cell.iconImageView.image = nil
                cell.valueLabel.text = item.value
                viewModel.imageFetchingService.fetchImage(for: iconName)  // Fetch only if iconName exists
            }
        } else {
            cell.iconImageView.image = nil
            cell.valueLabel.text = item.value
        }

        return cell
    }
}

extension APIViewController: APIViewControllerDelegate {
    func didReceiveWeatherData(data: WeatherData) {
        viewModel.updateDisplayItems(with: data)
        onDataAvailable?()
    }

    func didUpdateDisplayItems() {
        onDataAvailable?()
        tableView.reloadData()
    }
}


extension Double {
    func kelvinToFahrenheit() -> Double {
        return (self * 9/5 - 459.67).rounded()
    }
}

struct DisplayItem {
    let key: String
    let value: String
    var icon: String?
    var image: UIImage?
}
