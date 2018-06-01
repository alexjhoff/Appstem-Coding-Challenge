//
//  NetworkRequestProtocol.swift
//  AppstemProject
//
//  Created by Alex Hoff on 5/29/18.
//

import Foundation

// Network reques protocol lays out a framework for network request
protocol NetworkRequest: class {
    associatedtype Model
    func load(withCompletion completion: @escaping (Model?) -> Void)
    func decode(_ data: Data) -> Model?
}

// Extend the network request functionality for all network load requests
extension NetworkRequest {
    // Standard URLSession data task request
    func load(_ url: URLRequest, _ session: URLSessionProtocol, withCompletion completion: @escaping (Model?) -> Void) {
        let task = session.dataTask(with: url, completionHandler: { [weak self] (data: Data?, response: URLResponse?, error: Error?) -> Void in
            // Make sure there are no errors
            if let error = error {
                print("Server error:", error)
                return
            } else if let data = data,
                let response = response as? HTTPURLResponse {
                // If data and response exist and response code is 200 continue
                if response.statusCode == 200 {
                    completion(self?.decode(data))
                } else {
                    print("Data error status: ", response.statusCode, response.description)
                }
            }
        })
        task.resume()
    }
}

