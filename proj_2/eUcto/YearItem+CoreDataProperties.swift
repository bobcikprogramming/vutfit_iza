//
//  YearItem+CoreDataProperties.swift
//  eUcto
//
//  Created by Pavel Bobčík on 07.05.2021.
//
//

import Foundation
import CoreData


extension YearItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<YearItem> {
        return NSFetchRequest<YearItem>(entityName: "YearItem")
    }

    @NSManaged public var year: String?
    @NSManaged public var budget: Int64
    @NSManaged public var id: UUID?
    @NSManaged public var origin: UnitItem?
    @NSManaged public var month: NSSet?
    
    public var monthArray: [MonthItem] {
        let set = month as? Set<MonthItem> ?? []
        
        return set.sorted {
            $0.monthNum < $1.monthNum
        }
    }
}

// MARK: Generated accessors for month
extension YearItem {

    @objc(addMonthObject:)
    @NSManaged public func addToMonth(_ value: MonthItem)

    @objc(removeMonthObject:)
    @NSManaged public func removeFromMonth(_ value: MonthItem)

    @objc(addMonth:)
    @NSManaged public func addToMonth(_ values: NSSet)

    @objc(removeMonth:)
    @NSManaged public func removeFromMonth(_ values: NSSet)

}

extension YearItem : Identifiable {

}
