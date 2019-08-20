//
//  ViewController.swift
//  Note
//
//  Created by Максим Бачурин on 20/06/2019.
//  Copyright © 2019 Максим Бачурин. All rights reserved.
//

import UIKit
import CocoaLumberjack

class EditViewController: UIViewController {
    
    @IBOutlet var colorButtons: [UIButton]!
    @IBOutlet weak var miniColorPickerButton: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackColors: UIStackView!
    @IBOutlet weak var datePickerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var destoyDatePicker: UIDatePicker!
    @IBOutlet weak var titleTextView: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var switchDate: UISwitch!
    private var checkMarkView: CheckMarkView?
    var note: Note?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeDatePicker()
        initializeColorButtons()
        initializeCheckMarkView()
        initializeData()
        addObservers()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
        if navigationController?.viewControllers.firstIndex(of: self) == nil {
            //Back button
            saveNote()
        }
        super.viewWillDisappear(animated)
    }
    
    func saveNote() {
        for notesTableViewController in navigationController?.viewControllers ?? [] {
            if let notesTableViewController = notesTableViewController as? NotesTableViewController {
                let newNote = Note(importance: note!.importance,
                                   uid: note!.uid,
                                   color: mainView.backgroundColor!,
                                   title: titleTextView.text ?? "",
                                   content: contentTextView.text ?? "",
                                   dateDestruction: switchDate.isOn ? destoyDatePicker.date : nil)
                let saveNoteOperation = SaveNoteOperation(note: newNote,
                                                          notebook: notesTableViewController.notebook,
                                                          backendQueue: notesTableViewController.backendQueue,
                                                          dbQueue: notesTableViewController.DBQueue,
                                                          token: notesTableViewController.token,
                                                          context: notesTableViewController.backgroudContext)
                notesTableViewController.operationQueue.addOperation(saveNoteOperation)
                let updateUI = BlockOperation {
                    notesTableViewController.tableView.reloadData()
                }
                updateUI.addDependency(saveNoteOperation)
                OperationQueue.main.addOperation(updateUI)
                return
            }
        }
    }
    
    
    
    func initializeDatePicker() {
        datePickerHeightConstraint.constant = 0
        destoyDatePicker.locale = Locale(identifier: "ru_RU")
    }
    
    func initializeData() {
        guard let note = note else {
            print("Note is not found")
            return
        }
        titleTextView.text = note.title
        contentTextView.text = note.content
        if let date = note.dateDestruction {
            switchDate.setOn(true, animated: true)
            switchDate.sendActions(for: .valueChanged)
            destoyDatePicker.date = date
        }
    }
    
    func initializeCheckMarkView() {
        if note == nil {
            for button in colorButtons {
                if button.backgroundColor!.isEqual(UIColor.white) {
                    installCheckMark(to: button)
                    break
                }
            }
        } else {
            for button in colorButtons {
                if button.backgroundColor == nil {
                    mainView.backgroundColor = note!.color
                    scrollView.backgroundColor = note!.color
                    button.backgroundColor = note!.color
                    miniColorPickerButton.setImage(nil, for: .normal)
                    installCheckMark(to: button)
                } else {
                    if button.backgroundColor!.isEqual(note!.color) {
                        mainView.backgroundColor = note!.color
                        scrollView.backgroundColor = note!.color
                        installCheckMark(to: button)
                        return
                    }
                }
            }
        }
    }
    
    func initializeColorButtons() {
        for button in colorButtons {
            if button.backgroundColor == nil {
                let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self,
                                                                              action: #selector(showColorPicker(_:)))
                button.addGestureRecognizer(longPressGestureRecognizer)
            }
            button.clipsToBounds = true
            button.layer.cornerRadius = button.frame.size.width/8
            button.layer.borderColor = UIColor.black.cgColor
            button.layer.borderWidth = 1
            button.addTarget(self, action: #selector(chooseColor(_:)), for: .touchUpInside)
        }
        colorButtons[0].backgroundColor = .white
        colorButtons[1].backgroundColor = .green
        colorButtons[2].backgroundColor = .red
//        if let note = note {
//
//        }
    }
    
    //MARK: - Actions
    @IBAction func switchChanged(_ sender: UISwitch) {
        datePickerHeightConstraint.constant = 216*(sender.isOn ? 1 : 0)
        destoyDatePicker.minimumDate = Date()
    }
    
    //MARK: - Selectors
    @objc func chooseColor(_ sender: UIButton) {
        if sender.backgroundColor == nil {
            return
        }
        mainView.backgroundColor = sender.backgroundColor
        scrollView.backgroundColor = sender.backgroundColor
        
        installCheckMark(to: sender)
    }
    
    @objc func showColorPicker(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            view.endEditing(true)
            performSegue(withIdentifier: "Change color", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ColorPickerViewController, segue.identifier == "Change color" {
            destination.currentColor = miniColorPickerButton.backgroundColor ?? mainView.backgroundColor ?? .white
        }
    }
    
    @objc func didTapView(_ gesture: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func installCheckMark(to currentView: UIView) {
        checkMarkView?.removeFromSuperview()
        checkMarkView = CheckMarkView(frame: CGRect(x: 0,
                                                    y: 0,
                                                    width: currentView.bounds.width/3,
                                                    height: currentView.bounds.height/3))
        currentView.addSubview(checkMarkView!)
    }
    
    func newColor(color: UIColor) {
        print("newColor, \(color)")
        mainView.backgroundColor = color
        scrollView.backgroundColor = color
        miniColorPickerButton.setImage(nil, for: .normal)
        miniColorPickerButton.backgroundColor = color
        installCheckMark(to: miniColorPickerButton)
    }
    
    //MARK: - Keyboard
    @objc func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
        }
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height, right: 0)
        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        scrollView.contentInset = UIEdgeInsets.zero
        
    }
    
    //MARK: - Observers
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
}
