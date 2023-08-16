//
//  APIError.swift
//  WeatherApp
//
//  Created by Arturo Aguilar on 8/15/23.
//

import Foundation

struct APIError: Decodable, Error {
    let cod: String?
    let message: String?
    let customDescription: String?
    
    init(cod: String? = nil, message: String? = nil, customDescription: String? = nil) {
        self.cod = cod
        self.message = message
        self.customDescription = customDescription
    }
}
