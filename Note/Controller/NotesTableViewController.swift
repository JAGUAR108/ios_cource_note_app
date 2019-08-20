//
//  NotesTableViewController.swift
//  Note
//
//  Created by Максим Бачурин on 18/07/2019.
//  Copyright © 2019 Максим Бачурин. All rights reserved.
//

import UIKit
import CoreData

class NotesTableViewController: UITableViewController {
    var backendQueue = OperationQueue()
    var DBQueue = OperationQueue()
    var operationQueue = OperationQueue()
    
    var token: String = ""
    var notebook = FileNotebook()
    let reuseIdentifier = "Note cell"
    var backgroudContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        operationQueue.maxConcurrentOperationCount = 1
        if token.isEmpty {
            requestToken()
        }
        tableView.register(UINib(nibName: "NoteTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.beginRefreshing()
        tableView.refreshControl?.addTarget(self,
                                            action:#selector(handleRefreshControl),
                                            for: .valueChanged)
    }
    
    @objc func handleRefreshControl() {
        loadOperation(token: token)
    }
    
    func loadOperation(token: String) {
        guard let backgroudContext = backgroudContext else { return }
        print("loadOperation")
        let loadNotesOperation = LoadNotesOperation(notebook: notebook, backendQueue: backendQueue, dbQueue: DBQueue, token: token, context: backgroudContext)
        let updateUI = BlockOperation { [weak self] in
            self?.notebook = loadNotesOperation.result!
            self?.tableView.refreshControl?.endRefreshing()
            self?.tableView.reloadData()
        }
        updateUI.addDependency(loadNotesOperation)
        operationQueue.addOperation(loadNotesOperation)
        OperationQueue.main.addOperation(updateUI)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        tableView.setEditing(false, animated: true)
        performSegue(withIdentifier: "EditSegue",
                     sender: Note(importance: .normal,
                                  title: "",
                                  content: "",
                                  dateDestruction: nil))
    }
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notebook.notes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NoteTableViewCell
        cell.configure(note: notebook.notes[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "EditSegue", sender: notebook.notes[indexPath.row])
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //notebook.remove(with: notebook.notes[indexPath.row].uid)
        let removeNoteOperation = RemoveNoteOperation(notebook: notebook, note: notebook.notes[indexPath.row], backendQueue: backendQueue, dbQueue: DBQueue, token: token, context: backgroudContext)
        let updateUI = BlockOperation {
            //self.tableView.reloadData()
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            //print("lalala")
        }
        updateUI.addDependency(removeNoteOperation)
        operationQueue.addOperation(removeNoteOperation)
        OperationQueue.main.addOperation(updateUI)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? EditViewController else {
            return
        }
        destination.note = sender as? Note
    }
    
    private func requestToken() {
        let requestTokenViewController = AuthViewController()
        requestTokenViewController.delegate = self
        present(requestTokenViewController, animated: false, completion: nil)
    }
}

extension NotesTableViewController: AuthViewControllerDelegate {
    func handleTokenChanged(token: String) {
        self.token = token
        loadOperation(token: self.token)
        print(self.token)
    }
}
