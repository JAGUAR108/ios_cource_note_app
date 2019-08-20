import Foundation
import CoreData

class SaveNoteDBOperation: BaseDBOperation {
    private let note: Note
    
    init(note: Note,
         notebook: FileNotebook,
         context: NSManagedObjectContext) {
        self.note = note
        super.init(notebook: notebook, context: context)
    }
    
    override func main() {
        notebook.add(note)
        context.performAndWait {
            let fetchRequest = NSFetchRequest<DBNote>(entityName: "DBNote")
            fetchRequest.predicate = NSPredicate(format: "uid = %@", note.uid)
            do {
                let result = try context.fetch(fetchRequest)
                if !result.isEmpty {
                    let updateDBNote = result[0]
                    setDBNote(dbnote: updateDBNote)
                } else {
                    let dbnote = DBNote(context: context)
                    setDBNote(dbnote: dbnote)
                }
                try context.save()
            } catch {
                print("ERROR: \(error)")
            }
        }
        finish()
    }
    
    func setDBNote(dbnote: DBNote) {
        dbnote.colorHex = note.color.toHex
        dbnote.content = note.content
        dbnote.uid = note.uid
        dbnote.title = note.title
        dbnote.importance = "normal"
        dbnote.dateDestruction = note.dateDestruction
    }
}

