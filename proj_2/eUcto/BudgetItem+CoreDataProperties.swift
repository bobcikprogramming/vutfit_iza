//
//  BudgetItem+CoreDataProperties.swift
//  eUcto
//
//  Created by Pavel Bobčík on 07.05.2021.
//
//

import Foundation
import CoreData


extension BudgetItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BudgetItem> {
        return NSFetchRequest<BudgetItem>(entityName: "BudgetItem")
    }

    @NSManaged public var name: String?
    @NSManaged public var budget: Int64
    @NSManaged public var id: UUID?
    @NSManaged public var descrip: String?
    @NSManaged public var origin: MonthItem?

    public var wrappedName: String {
        name ?? "Nepojmenováno"
    }
}

extension BudgetItem : Identifiable {

}
