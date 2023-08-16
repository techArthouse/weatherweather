//
//  ContentView.swift
//  WeatherApp
//
//  Created by Arturo Aguilar on 8/14/23.
//

import SwiftUI
import Foundation

struct ContentView: View {
    // Shared network service for the entire app
    let sharedNetworkService: NetworkService
    @ObservedObject var searchWeatherViewModel: SearchWeatherViewModel
    @ObservedObject var homeLocationWeatherViewModel: HomeLocationWeatherViewModel
    
    // this determines when to show alert
    @State private var showErrorAlert = false

    var firstLoad: Bool = true
    
    // Use @StateObject for locationManager to handle when location is aqcuired
    @StateObject private var locationManager = LocationManager()

    // You'll see dependency injection used for the network service
    // for better testability. You can see i used it in some areas with the swiftui's preview framework.
    // It's also used here to leverage calling search when autoloading last valid search.
    // doing so here will
    init() {
        sharedNetworkService = NetworkService()
        searchWeatherViewModel = SearchWeatherViewModel(networkService: sharedNetworkService)
        homeLocationWeatherViewModel = HomeLocationWeatherViewModel(networkService: sharedNetworkService)
    }

    var body: some View {
        VStack {
            // Injecting dependency into SearchWeatherView
            SearchWeatherView(viewModel: searchWeatherViewModel)
                .padding(.top) // This will add some padding at the top for better appearance.

            Spacer()

            // Injecting dependency into our UIKit wrapper for APIViewController
            UIKitDataViewController(networkService: sharedNetworkService)
                .frame(maxHeight: .infinity) // This will make the view take all available space.
                .background(RoundedRectangle(cornerRadius: 15).stroke(Color.gray, lineWidth: 2)) // This gives boundary.
                .padding(.horizontal) // Adds horizontal padding for a better look.
            
            HomeLocationWeatherView(viewModel: homeLocationWeatherViewModel)
//            if let locationWeather = searchWeatherViewModel.userLocationWeather {
//                HomeLocationWeatherView(cityName: locationWeather.cityName,
//                                        weatherIcon: searchWeatherViewModel.userLocationWeatherIcon,
//                                        temperature: "\(locationWeather.temperature.kelvinToFahrenheit())°F")
//            }

        }
        .onAppear {
            // will load last valid city searched
            loadLastSearchedCity()
        }
        // Observe changes in userLocation and search weather
        // This will only occur once. Check LocationManager for details
        .onChange(of: locationManager.userLocation) { newLocationWrapper in
            if let locationWrapper = newLocationWrapper {
                homeLocationWeatherViewModel.fetchUserLocationWeather(for: locationWrapper.location)
            }
        }

        // Observe changes in error property and update showErrorAlert accordingly
        .onChange(of: searchWeatherViewModel.errorWrapper) { newErrorWrapper in
            if newErrorWrapper != nil {
                showErrorAlert = true
            }
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Error \(searchWeatherViewModel.errorWrapper?.cod ?? "")"),
                  message: Text(searchWeatherViewModel.errorWrapper?.message ?? "Unknown error"),
                  dismissButton: .default(Text("OK")) {
                    showErrorAlert = false
                    searchWeatherViewModel.errorWrapper = nil
                  })
        }
    }

    func loadLastSearchedCity() {
        if let city = UserDefaultsManager.getLastSearchedCity(), firstLoad {
            searchWeatherViewModel.searchText = city
            searchWeatherViewModel.searchWeather()
        }
    }
}
 



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
