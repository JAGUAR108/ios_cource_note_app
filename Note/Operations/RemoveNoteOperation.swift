//
//  RemoveNoteOperation.swift
//  Note
//
//  Created by Максим Бачурин on 01/08/2019.
//  Copyright © 2019 Максим Бачурин. All rights reserved.
//

import Foundation
import CoreData

class RemoveNoteOperation: AsyncOperation {
    private let removeFromDB: RemoveNoteDBOperation
    private var saveToBackend: SaveNotesBackendOperation
    
    private(set) var result: Bool? = false
    
    init(notebook: FileNotebook,
         note: Note,
         backendQueue: OperationQueue,
         dbQueue: OperationQueue,
         token: String,
         context: NSManagedObjectContext) {
        removeFromDB = RemoveNoteDBOperation(notebook: notebook,
                                             note: note,
                                             context: context)
        saveToBackend = SaveNotesBackendOperation(token: token)

        super.init()

        let adapter = BlockOperation { [unowned saveToBackend] in
            saveToBackend.notebook = notebook
        }
        
        adapter.addDependency(removeFromDB)
        saveToBackend.addDependency(adapter)
        addDependency(removeFromDB)
        addDependency(saveToBackend)
        backendQueue.addOperation(saveToBackend)
        dbQueue.addOperation(removeFromDB)
        dbQueue.addOperation(adapter)
    }
    
    override func main() {
        switch saveToBackend.result! {
        case .success:
            result = true
            print("success save to backend")
        case .failure(let error):
            result = false
            print("error save to backend: \(error)")
        }
        finish()
    }
}
