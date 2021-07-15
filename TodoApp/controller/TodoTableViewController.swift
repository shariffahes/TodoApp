//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//
import UIKit
import CoreData
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    var items = [TaskItem]()
    var selectedCategory: CategoryItem? {
        didSet{
            loadData()
        }
    }
    
    let ctx = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    /*deafult user storage:*/
    //let userStorage = UserDefaults.standard
    
    /*NSCoder Storage*/
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("ToDoItem.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = selectedCategory?.name
        
        
        /*Default User Storage*/
        //        if let arrayOfTasks = userStorage.object(forKey: "TodoTasks") as? [TaskItem] {
        //            items = arrayOfTasks
        //        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        guard let navBar = navigationController?.navigationBar else {fatalError("No nav bar")}
        let catColor = selectedCategory?.color as? UIColor
        navBar.backgroundColor = catColor
        navBar.tintColor = ContrastColorOf(catColor!, returnFlat: true)
        searchBar.barTintColor = catColor
        searchBar.searchTextField.backgroundColor = FlatWhite()
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(catColor!, returnFlat: true)]
        let statusBar = UIView(frame: (UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame)!)
             statusBar.backgroundColor = catColor
             UIApplication.shared.keyWindow?.addSubview(statusBar)
    }
    
    //MARK: - BarButton
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alertController = UIAlertController(title: "Add New Task", message: "", preferredStyle: .alert)
        
        alertController.addTextField { input in
            input.placeholder = "New Item"
            textField = input
        }
        
        let alertAction = UIAlertAction(title: "Add Item", style: .default) { action in
            
            
            //--------------------------------------------
            
            /*Using CoreData*/
            let task = TaskItem(context: self.ctx)
            task.title = textField.text
            task.dateCreated = Date()
            task.parentCategory = self.selectedCategory
            
            self.items.append(task)
            self.tableView.reloadData()
            self.save()
            //-----------------------------------------------
            
            /*Deafult User Storage*/
            //self.userStorage.set(self.items, forKey: "TodoTasks")
            
        }
        
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }
    
    
    
    //MARK: - TableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let task = items[indexPath.row]
        cell.textLabel?.text = task.title
        
        let parentColor = self.selectedCategory?.color as? UIColor
        let ratio = CGFloat(indexPath.row)/CGFloat (items.count)
 
        let taskColor = parentColor?.darken(byPercentage: ratio) ?? UIColor.flatBlue()
        cell.backgroundColor = taskColor
        let contrastColor = ContrastColorOf(taskColor, returnFlat: true)
        cell.textLabel?.textColor = contrastColor
        cell.tintColor = contrastColor
        cell.accessoryType = task.isDone ? .checkmark : .none
        
        return cell
    }
    
    //MARK: - TableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let task = items[indexPath.row]
        
        tableView.cellForRow(at: indexPath)?.accessoryType = task.isDone ? .none : .checkmark
        
        items[indexPath.row].isDone = !task.isDone
        
        /* items[indexPath.row].setValue(!task.isDone, forKey: "isDone")*/
        
        /*       ctx.delete(items[indexPath.row])
         items.remove(at: indexPath.row)*/
        
        save()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func updateModel(at indexPath: IndexPath) {
        ctx.delete(items[indexPath.row])
        items.remove(at: indexPath.row)
        tableView.reloadData()
        save()
    }
    
    
    //MARK: - Helper Methods
    
    func save(){
        
        /*NSCoder Storage*/
        /*       let encoder = PropertyListEncoder()
         do{
         let data = try encoder.encode(items)
         try data.write(to: dataFilePath!)
         }catch{
         
         print(error)
         }*/
        //----------------------------------------------------
        
        /*Using CoreData*/
        do{
            try ctx.save()
            tableView.reloadData()
        }catch{
            print(error)
        }
        //----------------------------------------------------
        
        
    }
    
    func loadData(with request: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()) {
        
        /*NSCoder Storage: */
        /*       do{
         let data = try Data(contentsOf: dataFilePath!)
         let decoder = PropertyListDecoder()
         items = try decoder.decode([TaskItem].self, from: data)
         }catch{
         print(error)
         }*/
        //-----------------------------
        
        /*Using CoreData*/
        
        do{
            
            let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
            if let currentPredicate = request.predicate{
                request.predicate = NSCompoundPredicate(type: .and, subpredicates: [currentPredicate,categoryPredicate])
            }else {
                request.predicate = categoryPredicate
            }
            
            items = try ctx.fetch(request)
            tableView.reloadData()
        }catch {
            print(error)
        }
        //--------------------------------
        
        
    }
    
}

//MARK: - SearchBarDelegate
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
        
        
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: false)]
        
        loadData(with: request)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            loadData()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
        
    }
    
    
    
}
