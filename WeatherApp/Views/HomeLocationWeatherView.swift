//
//  HomeLocationWeatherView.swift
//  WeatherApp
//
//  Created by Arturo Aguilar on 8/15/23.
//

import Foundation
import SwiftUI

struct HomeLocationWeatherView: View {
    @ObservedObject var viewModel: HomeLocationWeatherViewModel

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.locationManager.isLocationAccessDenied {
                Text("Please enable location services to see weather for your location.")
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                Text("Your Location")
                    .font(.headline)
                    .padding()
                
                Text(viewModel.localWeather?.cityName ?? "N\\A")
                    .font(.title2)
                
                HStack {
                    viewModel.localWeatherIcon?
                        .resizable()
                        .frame(width: 50, height: 50)
                    if let temp = viewModel.localWeather?.temperature {
                        // Remove trailing zeros
                        Text("\(String(format: "%g", temp.kelvinToFahrenheit()))°F")
                            .font(.largeTitle)
                    }
                }
                .padding()
            }
        }
//        .background(Color(.systemGray6))
        .cornerRadius(15)
        .padding()
        .onDisappear {
            viewModel.locationManager.stopUpdatingLocation()
        }




//        .onAppear {
//            viewModel.fetchUserLocationWeather()
//        }
    }
}
