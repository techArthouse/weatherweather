//
//  SearchWeatherView.swift
//  WeatherApp
//
//  Created by Arturo Aguilar on 8/14/23.
//

import SwiftUI

struct SearchWeatherView: View {
    @State private var searchText = ""
    private let networkService: NetworkServiceType
    
    // Dependency injection through the initializer
    init(networkService: NetworkServiceType = NetworkService()) {
        self.networkService = networkService
    }
    
    var body: some View {
        VStack {
            TextField("Enter city name...", text: $searchText)
                .padding(10)
                .border(Color.gray)
            Button("Search") {
                // Here you'll initiate the network request and the
                // reason we don't attach is that network service has cancellables and
                // as of new we don't need to subscribe for this class.
                let _ = networkService.fetchWeatherData(for: searchText)
            }
            .padding()
        }
        .padding()
    }
}




struct SearchWeatherView_Previews: PreviewProvider {
    static var previews: some View {
        SearchWeatherView(networkService: MockNetworkService())
    }
}

