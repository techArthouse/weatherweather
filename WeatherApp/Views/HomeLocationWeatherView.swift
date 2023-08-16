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
    var cityName: String?
    var weatherIcon: Image?
    var temperature: String?

    var body: some View {
        VStack {
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
//        .background(Color(.systemGray6))
        .cornerRadius(15)
        .padding()
//        .onAppear {
//            viewModel.fetchUserLocationWeather()
//        }
    }
}
