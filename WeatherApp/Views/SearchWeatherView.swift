//
//  SearchWeatherView.swift
//  WeatherApp
//
//  Created by Arturo Aguilar on 8/14/23.
//

import SwiftUI

struct SearchWeatherView: View {
    @ObservedObject var viewModel: SearchWeatherViewModel

    // Dependency injection through the initializer
    init(viewModel: SearchWeatherViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            TextField("Enter city name...", text: $viewModel.searchText)
                .padding(10)
                .border(Color.gray)
            Button("Search") {
                viewModel.searchWeather()
            }
            .padding()
        }
        .padding()
    }
}

struct SearchWeatherView_Previews: PreviewProvider {
    static var previews: some View {
        SearchWeatherView(viewModel: SearchWeatherViewModel(networkService: MockNetworkService()))
    }
}

