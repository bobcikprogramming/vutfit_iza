//
//  Controller.swift
//  Název:            eUcto
//  Předmět:          Programování zařízení Apple
//  Instituce:        VUT FIT
//  Autor:            Pavel Bobčík
//  Login:            xbobci03
//  vytvořeno:        07.05.2021
//

import Foundation
import CoreData

//  Funkce sloužící k nastavení maximálního počtu znaků na vstupu.
//  - Parameter upper: celočíselná hodnota reprezentující maximální hodnotu
//  - Parameter text: text na vstupu
//  - Return: vrací text s odpovídající maximální délkou
//  Funkce byla převzeta z odpovědi na StackOverflow
//  - Odkaz: https://stackoverflow.com/a/64199094
//  - Autor: Roman Shelkford (4. říjen 2020)
//  - Editoval: Pranav Kasetti (11. říjen 2020)
func limitText(_ upper: Int, text: String) -> String {
    var finalText = text
    if finalText.count > upper {
        finalText = String(finalText.prefix(upper))
    }
    return finalText
}

//  Funkce slouží k vytvoření měsíce na základě parametrů.
//  - Parameter month: název měsíce
//  - Parameter monthNum: číslo měsíce
//  - Parameter yearItem: nadřazená entita CoreData
//  - Parameter moc: NSManagedObjectContext
func createMonth(month: String, monthNum: Int16, yearItem: YearItem, moc: NSManagedObjectContext){
    let sep = MonthItem(context: moc)
    sep.month = month
    sep.monthNum = monthNum
    sep.budget = 0
    sep.id = UUID()
    sep.origin = yearItem
}

struct MonthInfo: Identifiable{
    var name: String
    var description: String
    var budget: Int
    let id = UUID()
}

struct Month: Identifiable{
    let month: String
    var budget: Int
    let id = UUID()
}

struct Year: Identifiable{
    var year: String
    let id = UUID()
    var budget: Int
}

struct Unit: Identifiable{
    var name: String
    var budget: Int
    let id = UUID()
}
