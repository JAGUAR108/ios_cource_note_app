//
//  FileNotebook.swift
//  Note
//
//  Created by Максим Бачурин on 23/06/2019.
//  Copyright © 2019 Максим Бачурин. All rights reserved.
//

import Foundation
import CocoaLumberjack

enum FileNotebookError: Error {
    case invalidPath
    case notAllNotes
}

class FileNotebook: Codable {
    public private(set) var notes = [Note]()
    
    public func add(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.uid == note.uid }) {
            notes[index] = note
        } else {
            notes.append(note)
        }
    }
    
    public func remove(with uid: String) {
        notes.removeAll { (note) -> Bool in
            note.uid == uid
        }
        DDLogInfo("Note is removed")
    }
    
//    public func replace(notes: [Note]?) {
//        guard let newNotes = notes else {return}
//        self.notes = newNotes
//    }
    
    public func saveToFile() {
        var notesJSON: [[String : Any]] = [] // массив заметок в формате JSON
        for note in notes {
            notesJSON.append(note.json)
        }
        let dict: [String: Any] = ["allNotes" : notesJSON] //Словарь с одним значением, чтобы запихать его в data
        do {
            let data = try JSONSerialization.data(withJSONObject: dict, options: []) //пихаем словарь
            let pathCaches = FileManager.default.urls(for: .cachesDirectory,
                                                      in: .userDomainMask).first //берём путь
            guard var path = pathCaches else {throw FileNotebookError.invalidPath} //чистим путь
            path.appendPathComponent("notes.MB")//добавляем название файла
            try data.write(to: path)// кидаем дату в этот файл
            DDLogInfo("Notebook saved to file")
        } catch let error {
            //print(error)
            DDLogInfo(error.localizedDescription)
        }
    }
    
    public func loadFromFile() {
        do {
            let pathCaches = FileManager.default.urls(for: .cachesDirectory,
                                                      in: .userDomainMask).first //также берём путь
            guard var path = pathCaches else {throw FileNotebookError.invalidPath} //чистим
            path.appendPathComponent("notes.MB") //имя файла
            let data = try Data(contentsOf: path) //дату берём
            let dict = try JSONSerialization.jsonObject(with: data,
                                                        options: []) as? [String: Any] // берём словарь
            guard let notesJSON = dict?["allNotes"] as? [[String : Any]] //массив заметок в формате JSON
                else {throw FileNotebookError.notAllNotes}
            notes = [] // чистим заметки, потому что будем загружать новые
            for noteJSON in notesJSON { //Парсим заметки в массив
                let parsedNote = Note.parse(json: noteJSON)
                guard let note = parsedNote else {continue}
                add(note)
            }
            try FileManager.default.removeItem(at: path) // удаляем файл
            DDLogInfo("Notebook loaded from file")
        } catch let error {
            //print(error)
            DDLogInfo(error.localizedDescription)
        }

    }
}
