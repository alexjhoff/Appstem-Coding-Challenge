//
//  ImageLoadOperation.swift
//  AppstemProject
//
//  Created by Alex Hoff on 5/30/18.
//

import Foundation
import UIKit

// Reusable completion handler
typealias ImageLoadOperationCompletionHandlerType = ((UIImage) -> ())?

// Operation class for loading top contributors asynchronously
class ImageLoadOperation: Operation {
    // Top contributor URL string
//    var url: String
    
    // Reusable completion handler
    var completionHandler: ImageLoadOperationCompletionHandlerType
    
    // Image request to make the network call
    var request: ImageRequest
    
    // Image variable to be set once the api call has been made
    var image: UIImage?
    
    init(url: String) {
//        self.url = url
        guard let url = URL(string: url) else { fatalError("Could not create URL") }
        let urlRequest = URLRequest(url: url)
        let urlSession = URLSession.shared
        request = ImageRequest(url: urlRequest, session: urlSession)
    }
    
    override func main() {
        if isCancelled {
            return
        }
        
        /*
         From the url given instantiate ApiContributorRequest, set it to request so
         it is not deallocated while the asynchronouse api call is run and
         set the contributor variable and call the completion handler when
         the api request is complete
         */
//        guard let url = URL(string: url) else { fatalError("Could not create URL") }
//        let urlSession = URLSession.shared
//        let apiRequest = ApiContributorRequest(url: url, session: urlSession)
//        request = apiRequest
        request.load { [weak self] (image) in
            guard let strongSelf = self else { return }
            guard !strongSelf.isCancelled,
                let image = image else { return }
            
            strongSelf.image = image
            strongSelf.completionHandler?(image)
        }
    }
}
