//
//  LessonService.swift
//  KeystonePark
//
//  Created by Apple on 26.07.2022.
//

import Foundation
import CoreData

enum LessonType: String {
    case ski, snowboard
}

typealias StudentHandler = (Bool, [Student]) -> Void

class LessonService {
    private let moc: NSManagedObjectContext
    private var students = [Student]()
    private var lessons = [Lesson]()
    
    init(moc: NSManagedObjectContext) {
        self.moc = moc
    }
    
//MARK: - Public
    
    //Read
    
    func getAllStudents() -> [Student]? {
        //key - studen has property lesson and lesson has property tybe => key: "lesson.type" - sort by type
        let sortByLesson = NSSortDescriptor(key: "lesson.type", ascending: true)
        let sortNyName = NSSortDescriptor(key:  "name", ascending: true)
        let sortDescriptors = [sortByLesson, sortNyName]
        let request: NSFetchRequest<Student> = Student.fetchRequest()
        request.sortDescriptors = sortDescriptors
        do {
            students = try moc.fetch(request)
            return students
        } catch let error as NSError {
            print("DEBUG: Failed fetching students with error: \(error.localizedDescription)")
        }
        return nil
    }
    
    func getAvailableLessons() -> [Lesson]? {
        let sortByType = NSSortDescriptor(key: "type", ascending: true)
        let request: NSFetchRequest<Lesson> = Lesson.fetchRequest()
        request.sortDescriptors = [sortByType]
        do {
            lessons = try moc.fetch(request)
            return lessons
        } catch let error as NSError {
            print("DEBUG: Failed fetching lessons with error: \(error.localizedDescription)")
            
        }
        return nil
    }
    
    //Create
    
    func addStudent(name: String,
                    for type: LessonType,
                    completion: StudentHandler) {
        
        let student = Student(context: moc)
        student.name = name
        
        if let lesson = lessonExists(type) {
            register(student, for: lesson)
            students.append(student)
            completion(true, students)
        }
        save()
    }
    
    //Update
    
    func update(currentStudent student: Student, withName name: String, forLesson lesson: String) {
        //Check is student current lesson == new lesson type
        if student.lesson?.type?.caseInsensitiveCompare(lesson) == .orderedSame {
            let lesson = student.lesson
            let studentsList = Array(lesson?.students?.mutableCopy() as! NSMutableSet) as! [Student]
            if let index = studentsList.firstIndex(where: { $0 == student}) {
                studentsList[index].name = name
                lesson?.students = NSSet(array: studentsList)
            }
        } else {
            guard let lessonType = LessonType(rawValue: lesson.lowercased()),
                  let lesson = lessonExists(lessonType) else { return }
            lesson.removeFromStudents(student)
            
            student.name = name
            register(student, for: lesson)
        }
        
        save()
    }
    
    // Delete
    
    func delete(student: Student) {
        let lesson = student.lesson
        students = students.filter({ $0 != student })
        lesson?.removeFromStudents(student)
        moc.delete(student)
        save()
    }
    
    //If you delete a lesson that has a Delete Rule set, Nullify students with particular lessons will not be removed
    
    //If you delete a lesson that has a Delete Rule set, Cascade will also remove all students from this lesson
    
    //If you try to delete a lesson that has a Delete Rule set, Deny and that particular lesson has students, you cannot delete this lesson, but you need to call method .rollback from object NSManagedObjectContext after failing to save
    
    
    func delete(lesson: Lesson, deleteHandler: ((Bool) -> Void)?) {
        lessons = lessons.filter{ $0 != lesson}
        moc.delete(lesson)
        save(completion: deleteHandler)
    }
    
//MARK: - Private
 
    private func lessonExists(_ type: LessonType) -> Lesson? {
        let request: NSFetchRequest<Lesson> = Lesson.fetchRequest()
        request.predicate = NSPredicate(format: "type =%@", type.rawValue)
        var lesson: Lesson?
        do {
            let result = try moc.fetch(request)
            lesson = result.isEmpty ? addNew(lesson: type) : result.first
        } catch let error as NSError {
            print("DEBUG: Error getting lesson: \(error.localizedDescription)")
        }
        return lesson
    }
    
    private func addNew(lesson type: LessonType) -> Lesson {
        let lesson = Lesson(context: moc)
        lesson.type = type.rawValue
        return lesson
    }
    
    private func register(_ student: Student, for lesson: Lesson) {
        student.lesson = lesson
    }
    
    private func save(completion: ((Bool) -> Void)? = nil) {
        let success: Bool
        do {
            try moc.save()
            success = true
        } catch let error as NSError {
            print("DEBUG: Save failed with error: \(error.localizedDescription)")
            moc.rollback()
            success = false
        }
        
        if let completion = completion {
            completion(success)
        }
    }
}


