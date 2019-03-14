//
//  NotesViewController.swift
//  Notepadd
//
//  Created by Rohan Ravindran  on 2018-12-13.
//  Copyright © 2018 Rohan Ravindran . All rights reserved.
//

import UIKit
import CoreData

protocol CanRecieve {
    func sendTrashedIndex(indexPathTrashed : Int)
    func changeNoteTitle(newName : String)
}

class NotesViewController: UIViewController, UITextViewDelegate {
    
    var delegate : CanRecieve?
    
    @IBOutlet weak var noteTextView: UITextView!
    
    var indexPathLocal : Int?
    var note : Category?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var bottomConstraint : NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteTextView.delegate = self
        
        self.navigationItem.hidesBackButton = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "← Back", style: .done, target: self, action: #selector(back(sender:)))
        navigationItem.leftBarButtonItem?.tintColor = .white
        
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done(sender:)))
        navigationItem.rightBarButtonItem = done
        navigationItem.rightBarButtonItem?.tintColor = .clear
        
        noteTextView.font = UIFont(name: "Verdana", size: 18)
        noteTextView.autocorrectionType = UITextAutocorrectionType.yes
        noteTextView.spellCheckingType = UITextSpellCheckingType.yes
        
        loadNote()
        
        view.addSubview(uiToolBarContainer)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: uiToolBarContainer)
        view.addConstraintsWithFormat(format: "V:[v0(44)]", views: uiToolBarContainer)
        
        bottomConstraint = NSLayoutConstraint(item: uiToolBarContainer, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1
            , constant: 0)
        view.addConstraint(bottomConstraint!)
        
        setupToolBar()
    }
    
    func setupToolBar() {
        uiToolBarContainer.addSubview(uiToolbar)
        uiToolBarContainer.addConstraintsWithFormat(format: "H:|[v0]|", views: uiToolbar)
        uiToolBarContainer.addConstraintsWithFormat(format: "V:[v0(44)]|", views: uiToolbar)
    }
    
    @IBOutlet weak var uiToolbar: UIToolbar!
    @IBOutlet weak var uiToolBarContainer: UIView!
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        navigationItem.rightBarButtonItem?.tintColor = .white
        bottomConstraint?.constant = -258
        adjustViewForKeyboard()
        
    }
    
    func adjustViewForKeyboard() {
            noteTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 330, right: 0)
            noteTextView.scrollIndicatorInsets = noteTextView.contentInset
            let selectedRange = noteTextView.selectedRange
            noteTextView.scrollRangeToVisible(selectedRange)
    }

    
    func textViewDidEndEditing(_ textView: UITextView) {
        navigationItem.rightBarButtonItem?.tintColor = .clear
        bottomConstraint?.constant = 0
    }
    
    @objc func back(sender: UIBarButtonItem) {
        note?.noteContents = noteTextView.text
        saveNote()
        self.navigationController?.popViewController(animated: true)
        bottomConstraint?.constant = 0
    }
    
    @IBAction func addBulletPointButtonPressed(_ sender: UIBarButtonItem) {
        let bullet = "•  "
        noteTextView.text.append("\n\(bullet)")
    }
    
    @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
        saveNote()
        if let noteShareContent = note?.noteContents {
        
        let activityVC = UIActivityViewController(activityItems: [noteShareContent], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
        
        }
        
    }
    
    @IBAction func renameNoteButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Rename Note", message: "Enter a new name for the current note", preferredStyle: .alert)
        let action = UIAlertAction(title: "Rename", style: .default) { (action) in
            if textField.text == "" || textField.text == nil {
                textField.text = "Untitled"
            }
            self.delegate?.changeNoteTitle(newName: textField.text!)
            self.loadNote()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "New Name"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func trashButtonPressed(_ sender: UIBarButtonItem) {
        delegate?.sendTrashedIndex(indexPathTrashed: (indexPathLocal)!)
        navigationController?.popViewController(animated: true)
    }
    
    
    @objc func done(sender: UIBarButtonItem) {
        saveNote()
        bottomConstraint?.constant = 0
        DispatchQueue.main.async {
            self.noteTextView.resignFirstResponder()
        }
    }
    
    
    func saveNote() {
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }
        
    }
    
    func loadNote() {
        self.navigationItem.title = note?.title
        if let label = note?.noteContents {
            noteTextView.text = label
        }
    }
}

extension UIView {
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        
        for (index, view) in views.enumerated(){
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
}
