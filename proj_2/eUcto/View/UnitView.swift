//
//  UnitView.swift
//  Název:            eUcto
//  Předmět:          Programování zařízení Apple
//  Instituce:        VUT FIT
//  Autor:            Pavel Bobčík
//  Login:            xbobci03
//  vytvořeno:        30.04.2021
//

import SwiftUI
import CoreData
import Combine

//
//  Počáteční okno aplikace, jenž se otevře pri zapnutí.
//  Okna obsahuje tabulku zobrazující jednotlivé skupiny uživatele, jenž se načtou z interní paměti Core Data.
//  Item reaguje na kliknutí (dojde k otevření nového okna pro přehled roků, v případě módu editování dojde k otevření okna
//  pro úprava názvu skupiny). Dále na potáhnutí k smazání. A nakonec přidání nové skupiny pomocí tlačítka 'Nový'.
//
struct UnitView: View {
    @State var showingSheet = false
    @State var showingUpdateSheet = false
    @State var editMode: EditMode = .inactive
    @State var nameOfUnit: String = ""
    @State var id: UUID = UUID()
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: UnitItem.entity(), sortDescriptors: []) var unitItems: FetchedResults<UnitItem>
    
    //  Funkce sloužící k smazání skupiny pomocí .\editMode().
    //  Provede smazání z CoreData a jejich uložení.
    //  - Parameter IndexSet: index odpovídající položky z tabulky
    func deleteItems(at offsets: IndexSet){
        for index in offsets {
            let unitToDelete = self.unitItems[index]
            self.moc.delete(unitToDelete)
        }
        try? self.moc.save()
    }

    var body: some View {
        GeometryReader { metrics in
            NavigationView{
                List {
                    Section{
                        ForEach(self.unitItems, id: \.self) { unit in
                            NavigationLink(
                                destination: YearView(origin: unit),
                                label: {
                                    //  Rozhodnutí, jak bude aplikace reagovat na kliknutí na danou sekci.
                                    //  V případě, že je editmode neaktivní (tzv .inactive) dojde k otevření přehledu let.
                                    //  V opačeném případě dojde k otevření úpravy názvu sekce.
                                    if(self.editMode == .inactive){
                                        inOutComeText(name: unit.wrappedName, budget: String(unit.budget), sizeW: metrics.size.width)
                                    }else{
                                        inOutComeText(name: unit.wrappedName, budget: String(unit.budget), sizeW: metrics.size.width)
                                            .onTapGesture {
                                                self.nameOfUnit = unit.wrappedName
                                                self.id = unit.id!
                                                showingUpdateSheet.toggle()
                                            }
                                            //  Zobrazení okna pro editaci názvu skupiny.
                                            //  - Binding isPresented: pravdivostní hodnota, jenž ovlivňuje viditelnost okna
                                            //  - Binding nameOfNewUnit: aktuální název skupiny
                                            //  - State headline: nadpis okna
                                            .sheet(isPresented: self.$showingUpdateSheet, content: {
                                                MakeNewUnit(isPresented: self.$showingUpdateSheet, nameOfNewUnit: self.$nameOfUnit, headline: "Upravit skupinu", unitAdded: {
                                                    newUnit in
                                                    for toChange in unitItems {
                                                        if(toChange.id == self.id) {
                                                            toChange.name = self.nameOfUnit
                                                        }
                                                    }
                                                    try? self.moc.save()
                                                    self.nameOfUnit = ""
                                                    self.id = UUID()
                                                })
                                            })
                                    }
                                })
                        }.onDelete(perform: deleteItems)
                    }
                }
                .navigationTitle("Přehled skupin")
                .toolbar {
                    HStack{
                        EditButton()
                            .padding(.trailing, 5)
                        Button("Nový") {
                            showingSheet.toggle()
                        }
                    }
                }
                //  Zobrazení okna pro vytvoření skupiny.
                //  - Binding isPresented: pravdivostní hodnota, jenž ovlivňuje viditelnost okna
                //  - Binding nameOfNewUnit: aktuální název skupiny (v tomto případě prázdná hodnota)
                //  - State headline: nadpis okna
                .sheet(isPresented: self.$showingSheet, content: {
                    MakeNewUnit(isPresented: self.$showingSheet, nameOfNewUnit: self.$nameOfUnit, headline: "Nová skupina", unitAdded: {
                        newUnit in
                        
                        let unitItem = UnitItem(context: self.moc)
                        unitItem.name = newUnit.name
                        unitItem.budget = Int64(newUnit.budget)
                        unitItem.id = newUnit.id
                        
                        try? self.moc.save()
                        self.nameOfUnit = ""
                    })
                })
                .environment(\.editMode, self.$editMode)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

//  Okno sloužící pro vytvoření nové či úpravě již existující skupiny.
struct MakeNewUnit: View{
    @State var update: Bool = false
    @State var empty: Bool = false
    @Binding var isPresented: Bool
    @Binding var nameOfNewUnit: String
    @State var headline: String
    var unitAdded: (Unit) -> ()
    
    var body: some View {
        GeometryReader { metrics in
            VStack {
                myHeadlineText(s: self.headline)
                myDescriptionText(s: "*Název skupiny", sizeW: metrics.size.width)
                TextField("Rodinný rozpočet", text: self.$nameOfNewUnit)
                    .textFieldStyle(myTextField(width: metrics.size.width * 0.8, empty: self.empty))
                    //  Kontrola, že rozsah znaků nepřesáhl uvedenou hodnotu
                    .onReceive(Just(self.nameOfNewUnit)) { _ in self.nameOfNewUnit = limitText(20, text: self.nameOfNewUnit) }
                
                Spacer()
                Button("Uložit"){
                    if(!self.nameOfNewUnit.isEmpty){
                        self.isPresented = false
                        self.empty = false
                        self.unitAdded(.init(name: self.nameOfNewUnit, budget: 0))
                    }else{
                        self.empty = true
                    }
                    
                }
                .buttonStyle(myButton(red: 72, green: 80, blue: 99))
            }
            .padding(.top, 45)
            .padding(.bottom, 15)
            .contentShape(Rectangle())
            .onTapGesture {}
            .onLongPressGesture(
                pressing: { isPressed in if isPressed { self.endEditing() } },
                perform: {})
        }
    }
}
struct UnitView_Previews: PreviewProvider {
    static var previews: some View {
        UnitView()
    }
}
