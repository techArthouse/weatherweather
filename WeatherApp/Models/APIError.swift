//
//  APIError.swift
//  WeatherApp
//
//  Created by Arturo Aguilar on 8/15/23.
//

import Foundation

// Custom error capturing. a fleshed out framework would require a longer look at the code but the basis for this
// is capturing server side errors and propgating them in a way we can handle on the front end
// for useful feedback.
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
