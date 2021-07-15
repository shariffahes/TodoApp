//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Sharif Fahes on 13/07/2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//
import UIKit
import CoreData
import ChameleonFramework

class CategoryTableViewController: SwipeTableViewController {

    /*Using CoreData*/
    var categories = [CategoryItem]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //-----------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        guard let navBar = navigationController?.navigationBar else {
            fatalError("nav bar doesn't exist")
        }
        let statusBar = UIView(frame: (UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame)!)
             statusBar.backgroundColor = FlatSkyBlue()
             UIApplication.shared.keyWindow?.addSubview(statusBar)
        navBar.backgroundColor = UIColor.flatSkyBlue()
        navBar.tintColor = UIColor.flatWhite()
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(FlatSkyBlue(), returnFlat: true)]
    }

    // MARK: - TableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let category = categories[indexPath.row]
        let catColor = category.color as? UIColor
        cell.textLabel?.text = category.name
        cell.backgroundColor = catColor
        cell.textLabel?.textColor = ContrastColorOf(catColor!, returnFlat: true)
        return cell
        
    }

    override func updateModel(at indexPath: IndexPath) {
        context.delete(categories[indexPath.row])
        categories.remove(at: indexPath.row)
        tableView.reloadData()
        saveData()
    }
    
    //MARK: - TableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.CategoryVC.segueToToDoItems, sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.CategoryVC.segueToToDoItems {
            let vc = segue.destination as! TodoListViewController
            if let index = tableView.indexPathForSelectedRow{
                vc.selectedCategory = categories[index.row]
            }
            
        }
        
    }
    
    //MARK: - Methods
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let controller = UIAlertController(title: "Add New Category", message: nil, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Add", style: .default) { action in
            /*Using CoreData*/
            let newCategory = CategoryItem(context: self.context)
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat()
            self.categories.append(newCategory)
            self.saveData()
            //----------------------------------
        }
        
        controller.addTextField { input in
            input.placeholder = "New Category"
            textField = input
        }
        controller.addAction(alertAction)
        present(controller, animated: true)
    }
    
    func loadData(with request: NSFetchRequest<CategoryItem> = CategoryItem.fetchRequest()){
       /*Using Coredata*/
        do{
       categories = try context.fetch(request)
       tableView.reloadData()
        }catch{
            print(error)
        }
        
    }
    
    func saveData() {
        /*Using CoreData*/
        do{
            try context.save()
            tableView.reloadData()
            
        }catch{
            print(error)
        }
        //------------------------------
    }
    
}


