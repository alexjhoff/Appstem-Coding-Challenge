//
//  URLSessionProtocol.swift
//  AppstemProject
//
//  Created by Alex Hoff on 5/29/18.
//

import Foundation

// This file creates our own URLSession Protocol which acts like a normal URLSession when used in
// production but which we can mock during testing
protocol URLSessionProtocol {
    func dataTask(with url: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol
}

extension URLSession : URLSessionProtocol {
    func dataTask(with url: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        
        let task = dataTask(with: url, completionHandler: completionHandler) as URLSessionDataTask
        return task as URLSessionDataTaskProtocol
    }
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {
    
}
