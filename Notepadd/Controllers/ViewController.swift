//
//  ViewController.swift
//  Notepadd
//
//  Created by Rohan Ravindran  on 2018-12-13.
//  Copyright © 2018 Rohan Ravindran . All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController, UISearchBarDelegate, CanRecieve {

    
    var categories = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var currentIndex : Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func sendTrashedIndex(indexPathTrashed: Int) {
        context.delete(self.categories[indexPathTrashed])
        saveCategories()
        loadCategories()
    }
    
    func changeNoteTitle(newName: String) {
        
        categories[currentIndex!].title = newName
        saveCategories()
        loadCategories()
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    //MARK: Search Bar delegate functions
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        request.predicate = predicate
        
        do {
            categories = try context.fetch(request)
        } catch {
            print("error fetching data from context, \(error)")
        }
        tableView.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBarSearchButtonClicked(searchBar)
        
        if searchBar.text?.count == 0 {
            loadCategories()
            
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        loadCategories()
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Note", message: "Enter a name for your new note", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Note", style: .default) { (action) in
            let category = Category(context: self.context)
            
            if textField.text == "" || textField.text == nil {
                textField.text = "Untitled"
            }
            category.title = textField.text!
            category.noteContents = ""
            self.categories.append(category)
            self.tableView.reloadData()
            self.saveCategories()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Name"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            context.delete(self.categories[indexPath.row])
            loadCategories()
            tableView.reloadData()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "goToPad", for: indexPath)
        let item = categories[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected row: \(indexPath)")
        currentIndex = indexPath.row
        performSegue(withIdentifier: "goToNotes", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! NotesViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            
            destinationVC.note = categories[indexPath.row]
            destinationVC.indexPathLocal = indexPath.row
            
            destinationVC.delegate = self
        }
    }
    
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categories = try context.fetch(request)
        } catch {
            print("error fetching data from context, \(error)")
        }
        tableView.reloadData()
    }
    
    func saveCategories() {
            do {
                try context.save()
            } catch {
                print("Error saving context, \(error)")
            }
            
            tableView.reloadData()
    }
    
}

