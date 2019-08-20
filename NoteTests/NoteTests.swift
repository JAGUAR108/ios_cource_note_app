//
//  NoteTests.swift
//  NoteTests
//
//  Created by Максим Бачурин on 05/07/2019.
//  Copyright © 2019 Максим Бачурин. All rights reserved.
//

import XCTest
@testable import Note

class NoteTests: XCTestCase {

    func testNote1() {
        let note = Note(importance: .normal, title: "123", content: "456")
        XCTAssertTrue(note.importance == .normal)
        XCTAssertTrue(note.title == "123")
        XCTAssertTrue(note.content == "456")
        XCTAssertTrue(note.color.isEqual(UIColor.white))
        XCTAssertTrue(note.dateDestruction == nil)
        let note2 = Note(importance: .unimportant, title: "14", content: "235")
        XCTAssertFalse(note.uid == note2.uid)
    }
    
    func testNote2() {
        let note = Note(importance: .important, uid: "123", color: .red, title: "title", content: "content", dateDestruction: Date())
        XCTAssertTrue(note.importance == .important)
        XCTAssertTrue(note.title == "title")
        XCTAssertTrue(note.content == "content")
        XCTAssertTrue(note.color.isEqual(UIColor.red))
        XCTAssertTrue(note.uid == "123")
    }
    
    
}

class NoteExtensionTest: XCTestCase {
    
    func testJSON() {
        let note = Note(importance: .unimportant, uid: "uid", color: .white, title: "title", content: "content", dateDestruction: Date())
        let note2 = Note.parse(json: note.json)
        XCTAssertTrue(note.importance == note2!.importance)
        XCTAssertTrue(note.title == note2!.title)
        XCTAssertTrue(note.content == note2!.content)
        XCTAssertTrue(note.color.isEqual(note2!.color))
        XCTAssertTrue(note.uid == note2!.uid)
        XCTAssertTrue(note.dateDestruction!.compare(note2!.dateDestruction!) == .orderedSame)
    }
    
    func testJSON2() {
        let note = Note(importance: .normal, uid: "uid", color: .green, title: "title", content: "content", dateDestruction: Date())
        let note2 = Note.parse(json: note.json)
        XCTAssertTrue(note.importance == note2!.importance)
        XCTAssertTrue(note.title == note2!.title)
        XCTAssertTrue(note.content == note2!.content)
        XCTAssertTrue(note.color.isEqual(note2!.color))
        XCTAssertTrue(note.uid == note2!.uid)
        XCTAssertTrue(note.dateDestruction!.compare(note2!.dateDestruction!) == .orderedSame)
    }
    
}

class FileNotebookTest: XCTestCase {
    
    func testFileNotebook1() {
        let notebook = FileNotebook()
        let note = Note(importance: .normal, uid: "uid", color: .green, title: "title", content: "content", dateDestruction: Date())
        let note2 = Note(importance: .normal, title: "123", content: "456")
        let note3 = Note(importance: .unimportant, title: "14", content: "235")
        notebook.add(note)
        notebook.add(note)
        XCTAssertTrue(notebook.notes.count == 1)
        notebook.add(note2)
        notebook.add(note3)
        XCTAssertTrue(notebook.notes.count == 3)
        notebook.remove(with: "uid")
        XCTAssertTrue(notebook.notes.count == 2)
        notebook.saveToFile()
        let notebook2 = FileNotebook()
        notebook2.loadFromFile()
        for i in 0..<2 {
            XCTAssertTrue(notebook.notes[i].uid == notebook2.notes[i].uid)
        }
    }
    
    func testFileNotebook2() {
//        let notebook = FileNotebook()
//        let note = Note(importance: .normal, uid: "uid", color: .green, title: "title", content: "content", dateDestruction: Date())
//        let note2 = Note(importance: .normal, title: "123", content: "456")
//        let note3 = Note(importance: .unimportant, title: "14", content: "235")
//        notebook.add(note)
//        notebook.add(note)
//        XCTAssertTrue(notebook.notes.count == 1)
//        notebook.add(note2)
//        notebook.add(note3)
//        XCTAssertTrue(notebook.notes.count == 3)
//        notebook.remove(with: "uid")
//        XCTAssertTrue(notebook.notes.count == 2)
        //let data = try! JSONEncoder().encode(notebook)
        
//        let notebook2 = try! JSONDecoder().decode(FileNotebook.self, from: data)
//        notebook2.loadFromFile()
//        for i in 0..<2 {
//            XCTAssertTrue(notebook.notes[i].uid == notebook2.notes[i].uid)
//        }
    }
    
    
}
