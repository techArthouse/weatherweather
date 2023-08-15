//
//  ContentView.swift
//  WeatherApp
//
//  Created by Arturo Aguilar on 8/14/23.
//

import SwiftUI

struct ContentView: View {
    let networkService = NetworkService()

    var body: some View {
        VStack {
            SearchWeatherView(networkService: networkService)
            UIKitDataViewController(networkService: networkService)
                .frame(height: 300)
                .background(.blue)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
