//
//  LoadNotesOperation.swift
//  Note
//
//  Created by Максим Бачурин on 01/08/2019.
//  Copyright © 2019 Максим Бачурин. All rights reserved.
//

import Foundation
import CoreData

class LoadNotesOperation: AsyncOperation {
    private let loadFromBackend: LoadNotesBackendOperation
    private var loadFromDB: LoadNotesDBOperation
    var result: FileNotebook?
    
    init(notebook: FileNotebook,
         backendQueue: OperationQueue,
         dbQueue: OperationQueue,
         token: String,
         context: NSManagedObjectContext) {
        loadFromBackend = LoadNotesBackendOperation(token: token)
        loadFromDB = LoadNotesDBOperation(notebook: notebook, context: context)
        super.init()
        
        addDependency(loadFromBackend)
        addDependency(loadFromDB)
        backendQueue.addOperation(loadFromBackend)
        dbQueue.addOperation(loadFromDB)
    }
    
    override func main() {
        switch loadFromBackend.result! {
        case .failure(let networkError):
            print("Network Error: \(networkError)")
            result = loadFromDB.result
        case .success(let notebook):
            print("Load success")
            //loadFromDB.notebook.replace(notes: notes)
            result = notebook
        }
        
        finish()
    }
}
