//
//  LessonViewController.swift
//  KeystonePark
//
//  Created by Apple on 26.07.2022.
//

import UIKit
import CoreData

enum ActionType: String {
    case add, update
}

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
    
    private var studentToUpdate: Student?
    
//MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadStudents()
    }
    
//MARK: - Selectors
    
    @IBAction func addStudentAction(_ sender: UIBarButtonItem) {
        present(alertController(actionType: .add), animated: true)
    }
    
//MARK: - Helper funtions
    
    private func alertController(actionType: ActionType) -> UIAlertController {
        let alertController = UIAlertController(title: "Keystone Park Lesson",
                                                message: "Student Info",
                                                preferredStyle: .alert)
        
        alertController.addTextField { [weak self] textField in
            textField.placeholder = "Name"
            textField.text = self?.studentToUpdate?.name ?? ""
        }
        alertController.addTextField { [weak self] textField in
            textField.placeholder = "Lesson Type: Ski | Snowboard"
            textField.text = self?.studentToUpdate?.lesson?.type ?? ""
        }
        
        let action = UIAlertAction(title: actionType.rawValue.capitalized, style: .default) { [weak self] _ in
            
            guard let studentName = alertController.textFields?[0].text,
                  !studentName.isEmpty,
                  let lesson = alertController.textFields?[1].text else { return }
            
            switch actionType {
            case .add:
                guard let lessonType = LessonType(rawValue: lesson.lowercased()) else { return }
                self?.lessonService?.addStudent(name: studentName,
                                                for: lessonType,
                                                completion: { success, students in
                    if success {
                        self?.studentsList = students
                    }
                })
            case .update:
                guard let studentToUpdate = self?.studentToUpdate else { return }
                self?.lessonService?.update(currentStudent: studentToUpdate,
                                            withName: studentName,
                                            forLesson: lesson)
                self?.studentToUpdate = nil
            }
            DispatchQueue.main.async {
                self?.loadStudents()
            }
        }
        
        let cancelAlert = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.studentToUpdate = nil
        }
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
    
//MARK: - TableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        studentToUpdate = studentsList[indexPath.row]
        present(alertController(actionType: .update), animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let student = studentsList[indexPath.row]
            lessonService?.delete(student: student)
            studentsList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        tableView.reloadData()
    }
}
