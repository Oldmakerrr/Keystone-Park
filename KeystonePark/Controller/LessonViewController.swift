//
//  LessonViewController.swift
//  KeystonePark
//
//  Created by Apple on 26.07.2022.
//

import UIKit

class LessonViewController: UITableViewController {
    
    let students = ["Ben", "John"]
    
//MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//MARK: - Selectors
    
    @IBAction func addStudentAction(_ sender: UIBarButtonItem) {
        present(alertController(actionType: "add"), animated: true)
    }
    
//MARK: - Helper funtions
    
    private func alertController(actionType: String) -> UIAlertController {
        let alertController = UIAlertController(title: "Keystone Park Lesson", message: "Student Info", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Name"
            
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Lesson Type: Ski | Snowboard"
        }
        
        let action = UIAlertAction(title: actionType.uppercased(), style: .default) { _ in
            
        }
        let cancelAlert = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(action)
        alertController.addAction(cancelAlert)
        return alertController
    }
    
//MARK: - TableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = students[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
}
