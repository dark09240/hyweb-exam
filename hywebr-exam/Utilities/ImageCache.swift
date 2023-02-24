//
//  ImageCache.swift
//  hywebr-exam
//
//  Created by Dong on 2023/2/22.
//

import Foundation
import UIKit

class ImageCache {
    
    //MARK: - Singleton
    static let shared = ImageCache()
    
    //MARK: - Variables
    private let imageCache = NSCache<NSURL, UIImage>()
    
    //MARK: - Action
    func image(for url: URL, handler: @escaping (UIImage?, Error?) -> ()) {
        if let image = imageCache.object(forKey: url as NSURL) {
            handler(image, nil)
        }else {
            URLSession.shared.dataTask(with: url, completionHandler: {data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    self.imageCache.setObject(image, forKey: url as NSURL)
                    handler(image, nil)
                }else if let error {
                    handler(nil, error)
                }else {
                    handler(nil, nil)
                }
            }).resume()
        }
    }
}
