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

    // track whether data is available
    @Binding var isDataAvailable: Bool

    init(networkService: NetworkServiceType, isDataAvailable: Binding<Bool>) {
        self.networkService = networkService
        self._isDataAvailable = isDataAvailable
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<UIKitDataViewController>) -> APIViewController {
        let apiViewController = APIViewController(networkService: networkService)
        
        // onDataAvailable closure to update if data is available then display view.
        apiViewController.onDataAvailable = {
            self.isDataAvailable = true
        }

        return apiViewController
    }

    func updateUIViewController(_ uiViewController: APIViewController, context: UIViewControllerRepresentableContext<UIKitDataViewController>) {
    }
}



// @State cannot be used withing static context so I had to creat a wrapper view.
struct UIKitDataViewController_Previews: PreviewProvider {
    static var previews: some View {
        UIKitDataViewControllerWrapper()
    }
}

// This is the wrapper view
struct UIKitDataViewControllerWrapper: View {
    @State private var isDataAvailable: Bool = true

    var body: some View {
        UIKitDataViewController(networkService: MockNetworkService(), isDataAvailable: $isDataAvailable)
    }
}
