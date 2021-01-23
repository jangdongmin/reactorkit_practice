//
//  GifObject.swift
//  GIPHY_SAMPLE
//
//  Created by Paul Jang on 2021/01/12.
//

import ObjectMapper

struct GifObject: Mappable {
    init?(map: Map) {}
    
    var id: String = ""
    var images: Images?
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        images <- map["images"]
    }
}
 
struct Images: Mappable {
    init?(map: Map) {}
    
    var original: Original?
    var thumbnail: Thumbnail?
    
    mutating func mapping(map: Map) {
        original <- map["original"]
        thumbnail <- map["preview_gif"]
    }
}

struct Original: Mappable {
    init?(map: Map) {}
    
    var width: String?
    var height: String?
    var url: String?
    
    mutating func mapping(map: Map) {
        width <- map["width"]
        height <- map["height"]
        url <- map["url"]
    }
}

struct Thumbnail: Mappable {
    init?(map: Map) {}
    
    var width: String?
    var height: String?
    var url: String?
    
    mutating func mapping(map: Map) {
        width <- map["width"]
        height <- map["height"]
        url <- map["url"]
    }
} 
