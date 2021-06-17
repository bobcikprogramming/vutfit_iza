//
//  UnitItem+CoreDataProperties.swift
//  eUcto
//
//  Created by Pavel Bobčík on 07.05.2021.
//
//

import Foundation
import CoreData


extension UnitItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UnitItem> {
        return NSFetchRequest<UnitItem>(entityName: "UnitItem")
    }

    @NSManaged public var name: String?
    @NSManaged public var id: UUID?
    @NSManaged public var budget: Int64
    @NSManaged public var year: NSSet?
    
    public var wrappedName: String {
        name ?? "Nepojmenováno"
    }
    
    public var yearArray: [YearItem] {
        let set = year as? Set<YearItem> ?? []
        
        return set.reversed()
    }

}

// MARK: Generated accessors for year
extension UnitItem {

    @objc(addYearObject:)
    @NSManaged public func addToYear(_ value: YearItem)

    @objc(removeYearObject:)
    @NSManaged public func removeFromYear(_ value: YearItem)

    @objc(addYear:)
    @NSManaged public func addToYear(_ values: NSSet)

    @objc(removeYear:)
    @NSManaged public func removeFromYear(_ values: NSSet)

}

extension UnitItem : Identifiable {

}
