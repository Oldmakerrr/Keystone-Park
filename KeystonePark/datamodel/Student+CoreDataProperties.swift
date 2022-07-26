//
//  Student+CoreDataProperties.swift
//  KeystonePark
//
//  Created by Apple on 26.07.2022.
//
//

import Foundation
import CoreData


extension Student {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Student> {
        return NSFetchRequest<Student>(entityName: "Student")
    }

    @NSManaged public var name: String?
    @NSManaged public var lesson: Lesson?

}

extension Student : Identifiable {

}
