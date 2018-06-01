//
//  Extensions.swift
//  AppstemProject
//
//  Created by Alex Hoff on 5/29/18.
//

import Foundation

extension URLRequest {
    // Function to build Getty Images URL string from search phrase
    public static func buildUrlWithPhrase(_ phrase: String) -> URLRequest {
        let queryItems = [URLQueryItem(name: "fields", value: "id,title,thumb,referral_destinations"),
                          URLQueryItem(name: "sort_order", value: "best"),
                          URLQueryItem(name: "phrase", value: phrase)]
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.gettyimages.com"
        urlComponents.path = "/v3/search/images"
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else { fatalError("Could not create URL") }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue(Constants.authKey, forHTTPHeaderField: "Api-Key")
        return urlRequest
    }
}

extension String {
    // Function to remove all non-letter characters
    func checkSpellingForWord(_ word: String) -> String {
        let alphaWord = word.replacingOccurrences(of: "[^A-z]", with: "")
        print("New word", alphaWord)
        return alphaWord
    }
}
