//
//  ImageRequest.swift
//  AppstemProject
//
//  Created by Alex Hoff on 5/29/18.
//

import Foundation
import UIKit

// Class for making image requests
class ImageRequest {
    private let url: URLRequest
    private let session: URLSessionProtocol
    
    init(url: URLRequest, session: URLSessionProtocol) {
        self.url = url
        self.session = session
    }
}

extension ImageRequest: NetworkRequest {
    // Decode data into a UIImage
    func decode(_ data: Data) -> UIImage? {
        return UIImage(data: data)
    }
    
    func load(withCompletion completion: @escaping (Model?) -> Void) {
        load(url, session, withCompletion: completion)
    }
}
