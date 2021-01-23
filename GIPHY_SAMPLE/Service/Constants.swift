//
//  Constants.swift
//  GIPHY_SAMPLE
//
//  Created by Paul Jang on 2021/01/13.
//

import Foundation

struct APIUrl {
    static let baseURL = "https://api.giphy.com/v1"
}

enum HTTPHeaderField: String {
    case authentication = "Authorization"
    case contentType = "Content-Type"
    case acceptType = "Accept"
    case acceptEncoding = "Accept-Encoding"
}
