//
//  LessonDetailViewController.swift
//  KeystonePark
//
//  Created by Apple on 29.07.2022.
//

import UIKit
import CoreData

class LessonDetailViewController: UITableViewController {

//MARK: - Private Properties
    
    var managedObjectContext: NSManagedObjectContext? {
        didSet {
            if let moc = managedObjectContext {
                lessonService = LessonService(moc: moc)
            }
        }
    }
    
    private var lessons = [Lesson]()
    private var lessonService: LessonService?
    
//MARK: - Lifrcycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let availableLessons = lessonService?.getAvailableLessons() {
            lessons = availableLessons
        }
    }
    
//MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lessons.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LessonDetailCell", for: indexPath)
        let lesson = lessons[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = lesson.type
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let lesson = lessons[indexPath.row]
            lessonService?.delete(lesson: lesson)
            lessons.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        tableView.reloadData()
    }}
