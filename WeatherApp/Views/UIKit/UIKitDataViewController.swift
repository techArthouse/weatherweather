//
//  UIKitDataViewController.swift
//  WeatherApp
//
//  Created by Arturo Aguilar on 8/14/23.
//

import SwiftUI
import UIKit

/*
 class is meant to demonstrate integration of uikit and swiftui. Existing code in uikit framework can be wrapped in
 a UIViewControllerRepresentable to be used as a swiftui view.
 */
struct UIKitDataViewController: UIViewControllerRepresentable {

    typealias UIViewControllerType = APIViewController

    let networkService: NetworkServiceType

    init(networkService: NetworkServiceType) {
        self.networkService = networkService
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<UIKitDataViewController>) -> APIViewController {
        let apiViewController = APIViewController(networkService: networkService)
        return apiViewController
    }

    func updateUIViewController(_ uiViewController: APIViewController, context: UIViewControllerRepresentableContext<UIKitDataViewController>) {
        // Update data if needed
    }
}



struct UIKitDataViewController_Previews: PreviewProvider {
    static var previews: some View {
        UIKitDataViewController(networkService: MockNetworkService())
    }
}
