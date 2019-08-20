import Foundation
import CoreData

class SaveNoteOperation: AsyncOperation {
    private let note: Note
    private let notebook: FileNotebook
    private let saveToDb: SaveNoteDBOperation
    private var saveToBackend: SaveNotesBackendOperation
    
    private(set) var result: Bool? = false
    
    init(note: Note,
         notebook: FileNotebook,
         backendQueue: OperationQueue,
         dbQueue: OperationQueue,
         token: String,
         context: NSManagedObjectContext) {
        self.note = note
        self.notebook = notebook
        
        saveToDb = SaveNoteDBOperation(note: note, notebook: notebook, context: context)
        saveToBackend = SaveNotesBackendOperation(token: token)
        
        
        super.init()
        
        let adapter = BlockOperation { [unowned saveToBackend] in
            saveToBackend.notebook = notebook
        }
        
        adapter.addDependency(saveToDb)
        saveToBackend.addDependency(adapter)
        addDependency(saveToDb)
        addDependency(saveToBackend)
        backendQueue.addOperation(saveToDb)
        dbQueue.addOperation(saveToBackend)
        dbQueue.addOperation(adapter)
    }
    
    override func main() {
        switch saveToBackend.result! {
        case .success:
            result = true
        case .failure:
            result = false
        }
        
        finish()
    }
}
