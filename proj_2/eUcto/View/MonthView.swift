//
//  MonthsOfUnitView.swift
//  Předmět:          Programování zařízení Apple
//  Instituce:        VUT FIT
//  Autor:            Pavel Bobčík
//  Login:            xbobci03
//  vytvořeno:        07.05.2021
//

import SwiftUI
import CoreData
import Combine

//  Okno pro zobrazení tabulky měsíců. Narozdíl od dvou předchozích oken toto okno nepodporuje mazání, úpravy či přidání,
//  jelikož je jeho obsah generován automaticky.
struct MonthView: View {
    @State var monthArray: [MonthItem]
    @State var origin: YearItem
    
    @Environment(\.presentationMode) var sendBack: Binding<PresentationMode>
    
    var backButton: some View {
        Button(action: {
            self.sendBack.wrappedValue.dismiss()
            }) {
                Text("Zpět")
                    .accentColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    .font(.system(size: 16))
            }
    }
    
    var body: some View {
        GeometryReader { metrics in
            List {
                Section{
                    ForEach(self.monthArray, id: \.self) { month in
                        if(month.origin?.id == self.origin.id){
                            NavigationLink(
                                destination: BudgetView(origin: month),
                                label: {
                                    inOutComeText(name: month.month!, budget: String(month.budget), sizeW: metrics.size.width)
                            })
                        }
                    }
                }
            }
            .navigationTitle("Přehled měsíců")
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: backButton)
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

struct MonthView_Previews: PreviewProvider {
    static var previews: some View {
        MonthView(monthArray: [MonthItem].init(), origin: YearItem.init())
    }
}
