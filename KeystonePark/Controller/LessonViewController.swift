//
//  LessonViewController.swift
//  KeystonePark
//
//  Created by Apple on 26.07.2022.
//

import UIKit
import CoreData

class LessonViewController: UITableViewController {
    
    //MARK: - Public Properties
    
    var managedObjectContext: NSManagedObjectContext? {
        didSet {
            guard let moc = managedObjectContext else { return }
            lessonService = LessonService(moc: moc)
        }
    }
    
    //MARK: - Private Properties
    
    private var lessonService: LessonService?
    
    private var studentsList = [Student]()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadStudents()
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
        
        let action = UIAlertAction(title: actionType.uppercased(), style: .default) { [weak self] _ in
            guard let studentName = alertController.textFields?[0].text,
                  let lesson = alertController.textFields?[1].text else { return }
            
            if actionType.caseInsensitiveCompare("add") == .orderedSame {
                guard let lessonType = LessonType(rawValue: lesson.lowercased()) else { return }
                self?.lessonService?.addStudent(name: studentName,
                                                for: lessonType,
                                                completion: { success, students in
                    if success {
                        self?.studentsList = students
                    }
                })
            }
            DispatchQueue.main.async {
                self?.loadStudents()
            }
        }
        
        
        
        let cancelAlert = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(action)
        alertController.addAction(cancelAlert)
        return alertController
    }
    
    private func loadStudents() {
        if let students = lessonService?.getAllStudents() {
            studentsList = students
            tableView.reloadData()
        }
    }
    
    //MARK: - TableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentsList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = studentsList[indexPath.row].name
        content.secondaryText = studentsList[indexPath.row].lesson?.type
        cell.contentConfiguration = content
        return cell
    }
}
