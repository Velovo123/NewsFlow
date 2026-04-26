//
//  ImageLoader.swift
//  NewsFlow
//
//  Created by Anatolii Semenchuk on 26.04.2026.
//

import Foundation
import UIKit

final class ImageLoader {
    
    static let shared = ImageLoader()
    private let cache = NSCache<NSString, UIImage>()
    private init() {}
    
    func loadImage(from url: URL) async -> UIImage? {
        let key = url.absoluteString as NSString
        if let cached = cache.object(forKey: key) { return cached }
        
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let image = UIImage(data: data) else { return nil }
        
        cache.setObject(image, forKey: key)
        return image
    }
}
