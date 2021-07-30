//
//  Record+CoreDataProperties.swift
//  Record
//
//  Created by Nikita Pekin on 2021-07-30.
//
//

import Foundation
import CoreData


extension Record : Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Record> {
        return NSFetchRequest<Record>(entityName: "Record")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var startTime: Date
    @NSManaged public var endTime: Date
    @NSManaged public var activity: String

}
