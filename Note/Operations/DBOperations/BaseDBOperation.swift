import Foundation
import CoreData

class BaseDBOperation: AsyncOperation {
    let notebook: FileNotebook
    var context: NSManagedObjectContext
    
    init(notebook: FileNotebook,
         context: NSManagedObjectContext) {
        self.notebook = notebook
        self.context = context
        super.init()
    }
}
