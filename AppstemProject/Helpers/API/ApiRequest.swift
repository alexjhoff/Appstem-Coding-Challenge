//
//  ApiRequest.swift
//  AppstemProject
//
//  Created by Alex Hoff on 5/30/18.
//

import Foundation

// Class for making Api requests
class ApiRequest {
    private let url: URLRequest
    private let session: URLSessionProtocol
    
    init(url: URLRequest, session: URLSessionProtocol) {
        self.url = url
        self.session = session
    }
}

extension ApiRequest: NetworkRequest {
    // Decode data from JSON into Session object
    func decode(_ data: Data) -> Session? {
        do {
            let decoder = JSONDecoder()
            // New in Swift 4.1; must be running Swift 9.3 for this functionality to work
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let session = try decoder.decode(Session.self, from: data)
            return session
        } catch {
            print("ERROR: ", error)
            return nil
        }
    }
    
    func load(withCompletion completion: @escaping (Model?) -> Void) {
        load(url, session, withCompletion: completion)
    }
}
