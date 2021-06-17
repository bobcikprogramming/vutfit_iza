//
//  MonthItem+CoreDataProperties.swift
//  eUcto
//
//  Created by Pavel Bobčík on 07.05.2021.
//
//

import Foundation
import CoreData


extension MonthItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MonthItem> {
        return NSFetchRequest<MonthItem>(entityName: "MonthItem")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var budget: Int64
    @NSManaged public var month: String?
    @NSManaged public var monthNum: Int16
    @NSManaged public var origin: YearItem?
    @NSManaged public var budgetItem: NSSet?
    
    public var budgetArray: [BudgetItem] {
        let set = budgetItem as? Set<BudgetItem> ?? []
        
        return set.sorted {
            $0.wrappedName < $1.wrappedName
        }
    }
    
}

// MARK: Generated accessors for budgetItem
extension MonthItem {

    @objc(addBudgetItemObject:)
    @NSManaged public func addToBudgetItem(_ value: BudgetItem)

    @objc(removeBudgetItemObject:)
    @NSManaged public func removeFromBudgetItem(_ value: BudgetItem)

    @objc(addBudgetItem:)
    @NSManaged public func addToBudgetItem(_ values: NSSet)

    @objc(removeBudgetItem:)
    @NSManaged public func removeFromBudgetItem(_ values: NSSet)

}

extension MonthItem : Identifiable {

}
