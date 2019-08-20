//
//  NoteExtensions.swift
//  Note
//
//  Created by Максим Бачурин on 22/06/2019.
//  Copyright © 2019 Максим Бачурин. All rights reserved.
//

import Foundation
import UIKit
import CocoaLumberjack

extension Note {
    static func parse(json: [String:Any]) -> Note? {
        guard let uid = json["uid"] as? String, //Очищаем от Optional
              let title = json["title"] as? String,
              let content = json["content"] as? String else {return nil}
        let arrayRGBaColor = json["color"] as? Array<CGFloat> //берём массив каналов цветов (Optional)
        let color: UIColor? = arrayRGBaColor != nil ? UIColor(red: arrayRGBaColor![0],
                                                              green: arrayRGBaColor![1],
                                                              blue: arrayRGBaColor![2],
                                                              alpha: arrayRGBaColor![3]) : nil //Задаём цвет по массиву, если он есть
        let importance: Importance? = Importance.init(rawValue:
            json["importance"] as? String ?? "") // берём важность, если есть
        let dateDestructionTimeStamp: Double? = json["dateDestruction"] as? Double // берём количество секунд с 1970
        let dateDestruction: Date? = dateDestructionTimeStamp != nil ? Date.init(timeIntervalSince1970: TimeInterval(dateDestructionTimeStamp!)) : nil // делаем дату, если она есть
        let note = Note(importance: importance ?? Importance.normal, uid: uid, color: color ?? UIColor.white, title: title, content: content, dateDestruction: dateDestruction) //инициализируем значения которые есть, иначе задаём по умолчанию
        DDLogInfo("Successful parsed")
        return note
    }
    
    var json: [String: Any] {
        var result = [String:Any]()
        result["uid"] = self.uid;
        result["title"] = self.title
        result["content"] = self.content
        if self.importance != .normal { //normal не надо класть
            result["importance"] = self.importance.rawValue
        }
        if let dateDestruction = dateDestruction { // берём дату если есть
            result["dateDestruction"] = Double(dateDestruction.timeIntervalSince1970)
        }
        if !self.color.isEqual(UIColor.white) { //если не белый, то берём каналы и в массив их:)
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            self.color.getRed(&r, green: &g, blue: &b, alpha: &a)
            result["color"] = [r,g,b,a]
        }
        DDLogInfo("JSON created!")
        return result
    }
}
