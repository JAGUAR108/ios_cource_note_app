//
//  Note.swift
//  Note
//
//  Created by Максим Бачурин on 20/06/2019.
//  Copyright © 2019 Максим Бачурин. All rights reserved.
//

import Foundation
import UIKit
import CocoaLumberjack

enum Importance: String, Codable {
    case unimportant
    case normal
    case important
}

struct Color: Codable {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    init(color: UIColor) {
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }
    
    var uiColor: UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

struct Note: Codable {
    let importance: Importance
    let uid: String
    let color: UIColor
    let title: String
    let content: String
    let dateDestruction: Date?
    
    enum CodingKeys: String, CodingKey {
        case importance
        case uid
        case color
        case title
        case content
        case dateDesruction
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(importance, forKey: .importance)
        try container.encode(uid, forKey: .uid)
        try container.encode(Color.init(color: color), forKey: .color)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(dateDestruction, forKey: .dateDesruction)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        importance = try container.decode(Importance.self, forKey: .importance)
        uid = try container.decode(String.self, forKey: .uid)
        color = try container.decode(Color.self, forKey: .color).uiColor
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        dateDestruction = try container.decode(Date?.self, forKey: .dateDesruction)
    }

    init(importance: Importance, uid: String = UUID().uuidString,
         color: UIColor = .white, title: String, content: String,
         dateDestruction : Date? = nil) {
        dynamicLogLevel = DDLogLevel.info
        self.importance = importance
        self.uid = uid
        self.color = color
        self.title = title
        self.content = content
        self.dateDestruction = dateDestruction
        DDLogInfo("Note is created")
    }
}

