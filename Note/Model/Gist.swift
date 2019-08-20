//
//  Gist.swift
//  Note
//
//  Created by Максим Бачурин on 11/08/2019.
//  Copyright © 2019 Максим Бачурин. All rights reserved.
//

import Foundation


struct Gist: Codable {
    let files: [String: GistFile]
    let id: String
}

struct GistFile: Codable {
    let filename: String
    let rawUrl: String
    
    enum CodingKeys: String, CodingKey { // Позволяет использовать названия полей в структуре отличающиеся от названий ключей в JSON
        case filename
        case rawUrl = "raw_url"
    }
}
