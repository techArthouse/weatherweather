//
//  ContentView.swift
//  WeatherApp
//
//  Created by Arturo Aguilar on 8/14/23.
//

import SwiftUI

struct ContentView: View {
    // Shared network service for the entire app
    let sharedNetworkService = NetworkService()

    var body: some View {
        VStack {
            // Injecting dependency into SearchWeatherView
            SearchWeatherView(viewModel: SearchWeatherViewModel(networkService: sharedNetworkService))
            
            // Injecting dependency into our UIKit wrapper for APIViewController
            UIKitDataViewController(networkService: sharedNetworkService)
                .frame(height: 300)
                .background(Color.blue)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
