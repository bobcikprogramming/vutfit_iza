//
//  YearUnitView.swift
//  Název:            eUcto
//  Předmět:          Programování zařízení Apple
//  Instituce:        VUT FIT
//  Autor:            Pavel Bobčík
//  Login:            xbobci03
//  vytvořeno:        07.05.2021
//

import SwiftUI
import CoreData
import Combine

//  Okno zobrazující přehled roků. Ovládání má stejné, jako hlavni okno (UnitView).
struct YearView: View {
    @State var showingSheet = false
    @State var showingUpdateSheet = false
    @State var origin: UnitItem
    @State var nameOfYear: String = ""
    @State var id: UUID = UUID()
    
    @Environment(\.presentationMode) var sendBack: Binding<PresentationMode>
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: YearItem.entity(), sortDescriptors: []) var yearItems: FetchedResults<YearItem>
    
    @State var editMode: EditMode = .inactive
    
    //  Funkce sloužící k smazání roku pomocí .\editMode().
    //  Provede smazání z CoreData a jejich uložení.
    //  Dále aktualizuje hodnotu 'budget' pro nadřazenou skupinu.
    //  - Parameter IndexSet: index odpovídající položky tabulky
    func deleteItems(at offsets: IndexSet){
        for index in offsets {
            let yearToDelete = self.yearItems[index]
            self.origin.budget -= yearToDelete.budget
            self.moc.delete(yearToDelete)
        }
        try? self.moc.save()
    }
    
    //  Vlastní tlačítko k návratu.
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
                    ForEach(self.yearItems, id: \.self) { year in
                        if(year.origin?.id == self.origin.id){
                            NavigationLink(
                                destination: MonthView(monthArray: year.monthArray, origin: year),
                                label: {
                                    //  Rozhodnutí, jak bude aplikace reagovat na kliknutí na danou sekci.
                                    //  V případě, že je editmode neaktivní (tzv .inactive) dojde k otevření přehledu mesíců.
                                    //  V opačeném případě dojde k otevření úpravy názvu roku.
                                    if(self.editMode == .inactive){
                                        inOutComeText(name: year.year!, budget: String(year.budget), sizeW: metrics.size.width)
                                    }else{
                                        inOutComeText(name: year.year!, budget: String(year.budget), sizeW: metrics.size.width)
                                            .onTapGesture {
                                                self.nameOfYear = year.year!
                                                self.id = year.id!
                                                showingUpdateSheet.toggle()
                                            }
                                            //  Zobrazení okna pro editaci názvu roku.
                                            //  - Binding isPresented: pravdivostní hodnota, jenž ovlivňuje viditelnost okna
                                            //  - Binding newYear: aktuální název roku
                                            //  - State headline: nadpis okna
                                            .sheet(isPresented: self.$showingUpdateSheet, content: {
                                                MakeNewYear(isPresented: self.$showingUpdateSheet, newYear: self.$nameOfYear, headline: "Upravit rok", yearAdded: {
                                                    newYear in
                                                    for toChange in self.yearItems {
                                                        if(toChange.id == self.id) {
                                                            toChange.year = self.nameOfYear
                                                        }
                                                    }
                                                    try? self.moc.save()
                                                    self.nameOfYear = ""
                                                    self.id = UUID()
                                                })
                                            })
                                    }
                                })
                        }
                    }.onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("Přehled roků")
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: backButton)
            .toolbar {
                HStack{
                    EditButton()
                        .padding(.trailing, 5)
                    Button("Nový") {
                        showingSheet.toggle()
                    }
                }
            }
            //  Zobrazení okna pro vytvoření nového roku.
            //  - Binding isPresented: pravdivostní hodnota, jenž ovlivňuje viditelnost okna
            //  - Binding newYear: název roku (v tomto případě prázdný)
            //  - State headline: nadpis okna
            .sheet(isPresented: self.$showingSheet, content: {
                MakeNewYear(isPresented: self.$showingSheet, newYear: self.$nameOfYear, headline: "Přidat rok", yearAdded: {
                    newYear in
                    let yearItem = YearItem(context: self.moc)
                    yearItem.year = newYear.year
                    yearItem.budget = Int64(newYear.budget)
                    yearItem.id = newYear.id
                    yearItem.origin = self.origin
                    
                    //  Jelikož jsou měsíce statické, lze ulehčit uživateli práci automatickým vygenerováním, pomocí funkce createMonth,
                    //  pro každý nově vytvořený rok.
                    createMonth(month: "Leden", monthNum: 1, yearItem: yearItem, moc: moc)
                    createMonth(month: "Únor", monthNum: 2, yearItem: yearItem, moc: moc)
                    createMonth(month: "Březen", monthNum: 3, yearItem: yearItem, moc: moc)
                    createMonth(month: "Duben", monthNum: 4, yearItem: yearItem, moc: moc)
                    createMonth(month: "Květen", monthNum: 5, yearItem: yearItem, moc: moc)
                    createMonth(month: "Červen", monthNum: 6, yearItem: yearItem, moc: moc)
                    createMonth(month: "Červenec", monthNum: 7, yearItem: yearItem, moc: moc)
                    createMonth(month: "Srpen", monthNum: 8, yearItem: yearItem, moc: moc)
                    createMonth(month: "Září", monthNum: 9, yearItem: yearItem, moc: moc)
                    createMonth(month: "Říjen", monthNum: 10, yearItem: yearItem, moc: moc)
                    createMonth(month: "Listopad", monthNum: 11, yearItem: yearItem, moc: moc)
                    createMonth(month: "Prosinec", monthNum: 12, yearItem: yearItem, moc: moc)
                    
                    try? self.moc.save()
                    self.nameOfYear = ""
                })
            })
            .environment(\.editMode, self.$editMode)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

//  Okno sloužící pro vytvoření nového či úpravě již existujícího roku.
struct MakeNewYear: View{
    @State var empty: Bool = false
    @Binding var isPresented: Bool
    @Binding var newYear: String
    @State var headline: String
    var yearAdded: (Year) -> ()
    
    var body: some View {
        GeometryReader { metrics in
            VStack {
                myHeadlineText(s: self.headline)
                myDescriptionText(s: "*Rok", sizeW: metrics.size.width)
                TextField("2021", text: self.$newYear)
                    .textFieldStyle(myTextField(width: metrics.size.width * 0.8, empty: self.empty))
                    .keyboardType(.numberPad)
                    .onReceive(Just(self.newYear)) { _ in self.newYear = limitText(4, text: self.newYear) }
                
                Spacer()
                Button("Uložit"){
                    if(!self.newYear.isEmpty){
                        self.isPresented = false
                        self.empty = false
                        self.yearAdded(.init(year: self.newYear, budget: 0))
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
                pressing: { isPressed in if isPressed { endEditing() } },
                perform: {})
        }
    }
}

struct YearView_Previews: PreviewProvider {
    static var previews: some View {
        YearView(origin: UnitItem.init())
    }
}
