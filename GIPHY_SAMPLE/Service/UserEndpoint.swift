//
//  UserEndpoint.swift
//  GIPHY_SAMPLE
//
//  Created by Paul Jang on 2021/01/13.
//

import Foundation
import Alamofire

protocol APIConfiguration: URLRequestConvertible {
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: Parameters? { get }
}

enum UserEndpoint: APIConfiguration {
    case searchGIF(keyword: String, page: Int)
    case searchSTICKER(keyword: String, page: Int)
    
    var method: HTTPMethod {
        switch self {
            case .searchGIF:
                return .get
            case .searchSTICKER:
                return .get
        }
    }

    var path: String {
        switch self {
        case .searchGIF:
            return "/gifs/search"
        case .searchSTICKER:
            return "/stickers/search"
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .searchGIF(let keyword, let page):
            return ["api_key" : "6yJFlU9NmkA9p8PgiTrracE6EpG2SQ3k",
                    "limit" : 25,
                    "offset" : (page * 25),
                    "q" : keyword]
        case .searchSTICKER(keyword: let keyword, page: let page):
            return ["api_key" : "6yJFlU9NmkA9p8PgiTrracE6EpG2SQ3k",
                    "limit" : 25,
                    "offset" : (page * 25),
                    "q" : keyword]
        }        
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try APIUrl.baseURL.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        
        urlRequest.httpMethod = method.rawValue
         
        if let parameters = parameters {
            do {
                urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
            } catch {
                throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
            }
        }
        
        return urlRequest
    }
}
