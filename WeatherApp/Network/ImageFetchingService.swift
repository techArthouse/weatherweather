//
//  ImageFetchingService.swift
//  WeatherApp
//
//  Created by Arturo Aguilar on 8/14/23.
//

import Foundation

import Combine
import UIKit

// Image fetching class that uses NSCache to save from constant requests. If the icon images library were much larger
// we might also incorporate the cachDirectory with Filemanager for a longer store of cache but that would have
// been overkill given the small library of icons. NSCache should suffice.
class ImageFetchingService {
    private var imageCache = NSCache<NSString, UIImage>()
    private var cancellables: Set<AnyCancellable> = []

    let imageSubject = PassthroughSubject<(icon: String, image: UIImage), Never>()
    let errorSubject = PassthroughSubject<(icon: String, error: Error), Never>()

    func fetchImage(for icon: String) {
        if let cachedImage = imageCache.object(forKey: icon as NSString) {
            imageSubject.send((icon: icon, image: cachedImage))
            return
        }
        
        let urlString = "https://openweathermap.org/img/wn/\(icon)@2x.png"
        if let url = URL(string: urlString) {
            URLSession.shared.dataTaskPublisher(for: url)
                .map {  UIImage(data: $0.data)?.withRenderingMode(.alwaysOriginal) }
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorSubject.send((icon: icon, error: error))
                    }
                }, receiveValue: { [weak self] image in
                    if let image = image {
                        self?.imageCache.setObject(image, forKey: icon as NSString)
                        self?.imageSubject.send((icon: icon, image: image))
                    }
                })
                .store(in: &cancellables)
        }
    }
    
    func cachedImage(for icon: String) -> UIImage? {
        return imageCache.object(forKey: icon as NSString)
    }
}
