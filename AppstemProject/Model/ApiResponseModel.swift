//
//  ApiResponseModel.swift
//  AppstemProject
//
//  Created by Alex Hoff on 5/30/18.
//

import Foundation

struct Session: Codable {
    let resultCount: Int
    let images: [Image]
}

struct Image: Codable {
    let id: String
    let displaySizes: [DisplaySize]
    let title: String
}

struct DisplaySize: Codable {
    let isWatermarked: Bool
    let name: String
    let uri: String
}
