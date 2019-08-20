//
//  LoadNotesDBOperation.swift
//  Note
//
//  Created by Максим Бачурин on 30/07/2019.
//  Copyright © 2019 Максим Бачурин. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class LoadNotesDBOperation: BaseDBOperation {
    var result: FileNotebook?
    
    override func main() {
        let request = NSFetchRequest<DBNote>(entityName: "DBNote")
        context.performAndWait {
            do {
                let dbnotes = try context.fetch(request)
                result = FileNotebook()
                for dbnote in dbnotes {
                    result?.add(Note(importance: .normal,
                                     uid: dbnote.uid!,
                                     color: UIColor(hex: dbnote.colorHex!)!,
                                     title: dbnote.title!,
                                     content: dbnote.content!,
                                     dateDestruction: dbnote.dateDestruction))
                }
            } catch {
                print("ERROR: \(error)")
            }
        }
        finish()
    }
    
}
