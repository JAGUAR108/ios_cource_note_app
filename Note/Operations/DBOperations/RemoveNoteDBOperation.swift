//
//  RemoveNoteDBOperation.swift
//  Note
//
//  Created by Максим Бачурин on 30/07/2019.
//  Copyright © 2019 Максим Бачурин. All rights reserved.
//

import Foundation
import CoreData

class RemoveNoteDBOperation: BaseDBOperation {
    private var note: Note
    init(notebook: FileNotebook,
         note: Note,
         context: NSManagedObjectContext) {
        self.note = note
        super.init(notebook: notebook, context: context)
    }
    override func main() {
        notebook.remove(with: note.uid)
        context.performAndWait {
            let fetchRequest = NSFetchRequest<DBNote>(entityName: "DBNote")
            fetchRequest.predicate = NSPredicate(format: "uid = %@", note.uid)
            do {
                let result = try context.fetch(fetchRequest)
                if !result.isEmpty {
                    let removeDBNote = result[0]
                    context.delete(removeDBNote)
                } else {
                    print("Note not found!")
                }
                try context.save()
            } catch {
                print("ERROR: \(error)")
            }
        }
        finish()
    }
}
