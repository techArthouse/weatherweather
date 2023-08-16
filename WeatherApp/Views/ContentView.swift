//
//  ContentView.swift
//  WeatherApp
//
//  Created by Arturo Aguilar on 8/14/23.
//

import SwiftUI
import Foundation
import CoreLocation


// At the top level here we want to keep track of changes in our viewmodels as well as
// leverage dependency injection to make testing easier but also share modules across
// classes.
struct ContentView: View {
    // Shared network service for the entire app
    let sharedNetworkService = NetworkService()
    @ObservedObject var searchWeatherViewModel: SearchWeatherViewModel
    @ObservedObject private var homeLocationWeatherViewModel: HomeLocationWeatherViewModel

    // this determines when to show alert
    @State private var showErrorAlert = false

    var firstLoad: Bool = true // so we only load saved city once.
    @State private var isDataAvailable: Bool = false // hides table until ready

    // You'll see dependency injection used for the network service
    // for better testability. You can see i used it in some areas with the swiftui's preview framework.
    init() {
        self.searchWeatherViewModel = SearchWeatherViewModel(networkService: sharedNetworkService)
        self.homeLocationWeatherViewModel =  HomeLocationWeatherViewModel(networkService: sharedNetworkService)
    }

    var body: some View {
        VStack {
            // Injecting dependency into SearchWeatherView
            SearchWeatherView(viewModel: searchWeatherViewModel)
                .padding(.top) // This will add some padding at the top for better appearance.

            Spacer()

            // Injecting dependency into our UIKit wrapper for APIViewController
            UIKitDataViewController(networkService: sharedNetworkService, isDataAvailable: $isDataAvailable)
                .frame(maxHeight: isDataAvailable ? .infinity: .zero)
                .background(RoundedRectangle(cornerRadius: 15).stroke(Color.gray, lineWidth: 2))
                .padding(.horizontal)
            
            HomeLocationWeatherView(viewModel: homeLocationWeatherViewModel)
        }
        .onAppear {
            // will load last valid city searched
            loadLastSearchedCity()

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
