//
//  SearchWeatherView.swift
//  WeatherApp
//
//  Created by Arturo Aguilar on 8/14/23.
//

import SwiftUI

struct SearchWeatherView: View {
    @State private var searchText = ""
    @ObservedObject var viewModel: SearchWeatherViewModel

    // Dependency injection through the initializer
    init(viewModel: SearchWeatherViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            TextField("Enter city name...", text: $searchText)
                .padding(10)
                .border(Color.gray)
            Button("Search") {
                viewModel.searchWeather(for: searchText)
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

