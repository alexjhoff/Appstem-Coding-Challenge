//
//  MockSession.swift
//  AppstemProject
//
//  Created by Alex Hoff on 5/29/18.
//

import Foundation

// Mock session acts as an offline session for testing our network requests by reading json
// data from a file and then adding it to a completion handler with a mock URL response
class MockSession: URLSessionProtocol {
    func dataTask(with url: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        guard let requestUrl = url.url else { fatalError("Could not access url") }
        let response = HTTPURLResponse(url: requestUrl, statusCode: 200, httpVersion: nil, headerFields: nil)
        if let path = Bundle.main.path(forResource: "MockDataFile", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                completionHandler(data, response, nil)
                return MockDataTask()
            } catch {
                print("Mock data fetch error")
            }
        }
        completionHandler(Data(), nil, nil)
        return MockDataTask()
    }
}
