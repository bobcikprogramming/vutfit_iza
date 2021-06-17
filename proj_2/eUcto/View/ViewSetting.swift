//
//  ViewSetting.swift
//  Název:            eUcto
//  Předmět:          Programování zařízení Apple
//  Instituce:        VUT FIT
//  Autor:            Pavel Bobčík
//  Login:            xbobci03
//  vytvořeno:        07.05.2021
//

import Foundation
import SwiftUI

//  Pomocná funkce reprezentující grafické zobrazení položek tabulky.
//  - Parameter name: název skupiny/roku/měsíce/budgetu
//  - Parameter budget: budget skupiny/roku/měsíce/budgetu
//  - Parameter sizeW: šířka obrazovky
//  - Return: vygenerované view položky
func inOutComeText(name: String, budget: String, sizeW: CGFloat) -> some View{
    return HStack {
        Text(name)
            .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealWidth: sizeW * 0.72, maxWidth: sizeW * 0.72, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 40, maxHeight: 60, alignment: .leading)
        Text(budget)
            .font(.system(size: 13))
            .foregroundColor((Int(budget) == 0) ? Color.black : (Int(budget)! > 0) ? Color.green : Color.red)
            .frame(minWidth: 0, idealWidth: sizeW * 0.28, maxWidth: sizeW * 0.28, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 40, maxHeight: 60, alignment: .trailing)
    }.contentShape(Rectangle())
}

//  Pomocná funkce reprezentující popis nad TextFieldem při vytváření/úpravě.
//  - Parameter s: obsah popisu
//  - Parameter sizeW: hodnota jakou zabere Text
//  - Return: vygenerované view popisu
func myDescriptionText(s: String, sizeW: CGFloat) -> some View{
    return Text(s)
        .italic()
        .font(.system(size: 15))
        .frame(width: sizeW * 0.8, height: 20, alignment: .leading)
}

//  Pomocná funkce reprezentující nadpis pro vytváření/úpravu.
//  - Parameter s: obsah popisu
//  - Return: vygenerované view nadpisu
func myHeadlineText(s : String) -> some View{
    return Text(s)
        .bold()
        .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealWidth: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 20, idealHeight: 20, maxHeight: 20, alignment: .leading)
        .font(.system(size: 35))
        .padding(.bottom, 15)
        .padding(.leading, 15)
}

//  Pomocná funkce vracející barevnou hodnotu pozadí na základě pravdivostní hodnoty.
//  - Parameter empty: pravdivostní hodnota
//  - Return: hodnota background
func textFieldBackground(empty: Bool) -> Color {
    return empty ? Color(red: 226 / 255, green: 153 / 255, blue: 153 / 255) : Color(red: 220 / 255, green: 220 / 255, blue: 220 / 255)
}

//  Schování klávesnice.
extension View {
    func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

//  Vlastní ButtonStyle pro použité tlačítka v aplikaci.
struct myButton: ButtonStyle {
    let red: Double
    let green: Double
    let blue: Double
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 100, height: 45, alignment: .center)
            .font(.system(size: 20))
            .foregroundColor(Color.white)
            .padding(.leading, 15)
            .padding(.trailing, 15)
            .background(Color(red: red / 255, green: green / 255, blue: blue / 255))
            .cornerRadius(15)
    }
}

//  Vlastní TextFieldStyle pro použité TextFieldy v aplikaci.
struct myTextField: TextFieldStyle {
    let width: CGFloat
    let empty: Bool
    
    func _body(configuration: TextField<_Label>) -> some View {
            configuration
                .frame(width: self.width, height: 50, alignment: .center)
                .padding(.leading, 15)
                .padding(.trailing, 15)
                .background(textFieldBackground(empty: self.empty))
                .cornerRadius(30)
                .font(.system(size: 20))
                .disableAutocorrection(true)
    }
}

