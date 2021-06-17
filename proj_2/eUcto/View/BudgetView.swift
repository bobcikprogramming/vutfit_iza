//
//  BudgetView.swift
//  Předmět:          Programování zařízení Apple
//  Instituce:        VUT FIT
//  Autor:            Pavel Bobčík
//  Login:            xbobci03
//  vytvořeno:        07.05.2021
//

import SwiftUI
import CoreData
import Combine

//  Okno pro zobrazení budgetu. Uživatel má možnost v daném okně smazat nebo vytvořit nový budget.
//  Po rozkliknutí jednotlivách budgetů se uživateli otevře nové okno s přehledem a možností úpravy.
struct BudgetView: View {
    @State var monthInfo: [MonthInfo] = []
    @State var showingSheet = false
    @State var index: Int = -1
    @State var origin: MonthItem
    
    @Environment(\.presentationMode) var sendBack: Binding<PresentationMode>
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: BudgetItem.entity(), sortDescriptors: []) var budgetItems: FetchedResults<BudgetItem>
    
    var backButton: some View {
        Button(action: {
            self.sendBack.wrappedValue.dismiss()
            
            }) {
                Text("Zpět")
                .accentColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                .font(.system(size: 16))
            }
    }
    
    //  Funkce sloužící k smazání budgetu pomocí .\editMode().
    //  Provede smazání z CoreData a jejich uložení.
    //  Dále aktualizuje hodnotu 'budget' pro nadřazené view (měsíc/rok/skupina).
    //  - Parameter IndexSet: index odpovídající položky tabulky
    func deleteItems(at offsets: IndexSet){
        for index in offsets {
            let budgetToDelete = self.budgetItems[index]
            self.origin.budget -= budgetToDelete.budget
            self.origin.origin?.budget -= budgetToDelete.budget
            self.origin.origin?.origin?.budget -= budgetToDelete.budget
            self.moc.delete(budgetToDelete)
        }
        try? self.moc.save()
    }
    
    var body: some View {
        GeometryReader { metrics in
            List {
                Section{
                    ForEach(self.budgetItems, id: \.self) { budget in
                        if(budget.origin?.id == self.origin.id){
                            NavigationLink(
                                destination: BudgetUnit(budgetInfo: budget, origin: self.origin),
                                label: {
                                    inOutComeText(name: budget.wrappedName, budget: String(budget.budget), sizeW: metrics.size.width)
                                })
                        }
                    }.onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("Přehled výdajů")
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
            //  Zobrazení okna pro vytvoření nového budgetu.
            //  - Binding isPresented: pravdivostní hodnota, jenž ovlivňuje viditelnost okna
            //  - State newBudgetName: název budgetu (v tomto případě prázdný)
            //  - State newBudgetMoney: množství financí (v tomto případě prázdné)
            //  - State description: popis budgetu (v tomto případě prázdný)
            //  - State headline: nadpis okna
            .sheet(isPresented: $showingSheet, content: {
                MakeNewBudget(isPresented: $showingSheet, newBudgetName: "", newBudgetMoney: "", description: "", headline: "Přidat rozpočet", budgetAdded: {
                    newBudget in
                    
                    let budgetItem = BudgetItem(context: self.moc)
                    budgetItem.name = newBudget.name
                    budgetItem.budget = Int64(newBudget.budget)
                    budgetItem.id = newBudget.id
                    budgetItem.descrip = newBudget.description
                    budgetItem.origin = origin
                    
                    self.origin.budget += budgetItem.budget
                    self.origin.origin?.budget += budgetItem.budget
                    self.origin.origin?.origin?.budget += budgetItem.budget
                    
                    try? self.moc.save()
                })
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

//  Okno sloužící k vytvoření či úpravě již existujícího budgetu.
struct MakeNewBudget: View{
    @State var emptyName: Bool = false
    @State var emptyMoney: Bool = false
    @State var value: CGFloat = 0
    @State var scroll: Bool = false
    @State var height: CGFloat = 0
    
    @Binding var isPresented: Bool
    @State var newBudgetName: String
    @State var newBudgetMoney: String
    @State var description: String
    @State var headline: String
    
    var budgetAdded: (MonthInfo) -> ()
    
    var body: some View {
        GeometryReader { metrics in
            VStack {
                myHeadlineText(s: self.headline)
                myDescriptionText(s: "*Název rozpočtu", sizeW: metrics.size.width)
                TextField("Nákupy", text: self.$newBudgetName)
                    .textFieldStyle(myTextField(width: metrics.size.width * 0.8, empty: self.emptyName))
                    .onReceive(Just(self.newBudgetName)) { _ in self.newBudgetName = limitText(20, text: self.newBudgetName) }
                
                myDescriptionText(s: "*Množství financí", sizeW: metrics.size.width)
                TextField("1500", text: self.$newBudgetMoney)
                    .textFieldStyle(myTextField(width: metrics.size.width * 0.8, empty: self.emptyMoney))
                    .keyboardType(.numberPad)
                    .onReceive(Just(self.newBudgetMoney)) { _ in self.newBudgetMoney = limitText(10, text: self.newBudgetMoney) }
                
                myDescriptionText(s: "Popis", sizeW: metrics.size.width)
                    .onTapGesture {
                        self.scroll = false
                    }
                TextEditor(text: self.$description)
                    .frame(width: metrics.size.width * 0.8, height: metrics.size.height * 0.3, alignment: .center)
                    .padding(.leading, 15)
                    .padding(.trailing, 15)
                    .colorMultiply(Color(red: 220 / 255, green: 220 / 255, blue: 220 / 255))
                    .background(Color(red: 220 / 255, green: 220 / 255, blue: 220 / 255))
                    .cornerRadius(30)
                    .font(.system(size: 20))
                    .disableAutocorrection(true)
                    //  Zobrazení/skrytí klávesnice na kliknutí.
                    //  Dále nastavení hodnoty 'value' reprezentující plochu, jenž klávesnice zaujme.
                    .onTapGesture {
                        self.scroll = true
                        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main){ (noti) in
                            
                            let value = noti.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
                            let height = value.height
                            
                            self.value = height
                            
                        }
                        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main){ (noti) in
                            
                            self.value = 0
                            self.scroll = false
                        }
                    }
                
                Spacer()
                HStack{
                    Button("Příjmy"){
                        if(!self.newBudgetName.isEmpty && !self.newBudgetMoney.isEmpty){
                            self.isPresented = false
                            self.budgetAdded(.init(name: self.newBudgetName, description: self.description, budget: Int(self.newBudgetMoney)!))
                        }else{
                            self.emptyName = self.newBudgetName.isEmpty
                            self.emptyMoney = self.newBudgetMoney.isEmpty
                        }
                        
                    }
                    .buttonStyle(myButton(red: 26, green: 175, blue: 79))
                    
                    Button("Výdaje"){
                        if(!self.newBudgetName.isEmpty && !self.newBudgetMoney.isEmpty){
                            self.isPresented = false
                            self.budgetAdded(.init(name: self.newBudgetName, description: self.description, budget: -Int(self.newBudgetMoney)!))
                        }else{
                            self.emptyName = self.newBudgetName.isEmpty
                            self.emptyMoney = self.newBudgetMoney.isEmpty
                        }
                        
                    }
                    .buttonStyle(myButton(red: 206, green: 68, blue: 38))
                }
            }
            .padding(.top, 45)
            .padding(.bottom, 15)
            .contentShape(Rectangle())
            .onTapGesture {}
            //  Skrytí klávesnice po kliknutí na obrazovku.
            .onLongPressGesture(
                pressing: { isPressed in if isPressed { self.endEditing() } },
                perform: {
                    self.value = 0
                    self.scroll = false
                })
            .onAppear{
                self.height = metrics.size.height
            }
        }
        //  Jeli klávesnice vysunuta pro 'Popis' a je-li obrazovka nižší, než uvedená hodnota, dojde k posunutí obsahu okna nahoru,
        //  aby klávesnice nepřekrila texteditor pro 'Popis'.
        .offset(y: (self.scroll && self.height < 700) ? -(self.value / 1.5): 0)
        .animation(.easeInOut)
    }
}

//  Okno sloužící k zobrazení informací o daném budgetu.
struct BudgetUnit: View {
    @State var budgetInfo: BudgetItem
    @State var showingSheet = false
    @State var emptyName: Bool = false
    @State var emptyMoney: Bool = false
    @State var budgetName: String = ""
    @State var budgetMoney: String = ""
    @State var budgetDescription: String = ""
    @State var origin: MonthItem
    @State var isOutCome: Bool = false
    
    @Environment(\.presentationMode) var sendBack: Binding<PresentationMode>
    @Environment(\.managedObjectContext) var moc
    
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
            VStack {
                myDescriptionText(s: "Název rozpočtu", sizeW: metrics.size.width)
                TextField("", text: self.$budgetName)
                    .textFieldStyle(myTextField(width: metrics.size.width * 0.8, empty: self.emptyName))
                    .disabled(true)
                
                myDescriptionText(s: "Množství financí", sizeW: metrics.size.width)
                TextField("", text: self.$budgetMoney)
                    .textFieldStyle(myTextField(width: metrics.size.width * 0.8, empty: self.emptyMoney))
                    .disabled(true)
                    
                myDescriptionText(s: "Popis", sizeW: metrics.size.width)
                TextEditor(text: self.$budgetDescription)
                    .frame(width: metrics.size.width * 0.8, height: metrics.size.height * 0.3, alignment: .center)
                    .padding(.leading, 15)
                    .padding(.trailing, 15)
                    .colorMultiply(Color(red: 220 / 255, green: 220 / 255, blue: 220 / 255))
                    .background(Color(red: 220 / 255, green: 220 / 255, blue: 220 / 255))
                    .cornerRadius(30)
                    .font(.system(size: 20))
                    .disabled(true)
                
            }
            .frame(width: metrics.size.width, height: metrics.size.height, alignment: .init(horizontal: .center, vertical: .top))
            .navigationTitle("Náhled rozpočtu")
            .navigationBarBackButtonHidden(true)
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarItems(leading: backButton, trailing: Button(action: {
                self.showingSheet.toggle()
            }, label: {
                Text("Upravit")
                .accentColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                .font(.system(size: 16))
            }))
            //  Zobrazení okna pro vytvoření nového budgetu.
            //  Je třeba provést přepočet nové hodnoty budgetu dle toho, zda-li došlo ke změně příjmu na výdej (či obráceně)
            //  a případně i hodnoty, nebo došlo pouze k úpravě hodnoty (nastavení příjmu/výdeje se nezměnil)
            //  Nová hodnota se aktualizuje ve všech nadřazených oknech.
            //  - Binding isPresented: pravdivostní hodnota, jenž ovlivňuje viditelnost okna
            //  - State newBudgetName: název budgetu
            //  - State newBudgetMoney: množství financí
            //  - State description: popis budgetu
            //  - State headline: nadpis okna
            .sheet(isPresented: self.$showingSheet, content: {
                MakeNewBudget(isPresented: self.$showingSheet, newBudgetName: self.budgetName, newBudgetMoney: self.budgetMoney, description: self.budgetDescription, headline: "Upravit rozpočet", budgetAdded: {
                    changedBudget in
                    var prevBudget = self.budgetInfo.budget
                    self.budgetInfo.name = changedBudget.name
                    self.budgetInfo.budget = Int64(changedBudget.budget)
                    self.budgetInfo.descrip = changedBudget.description
                    self.budgetInfo.origin = self.origin
                    
                    if((self.isOutCome && changedBudget.budget > 0) || (!self.isOutCome && changedBudget.budget < 0)){
                        prevBudget = -self.budgetInfo.budget + prevBudget
                    }else{
                        prevBudget -= self.budgetInfo.budget
                    }
                    
                    self.origin.budget -= prevBudget
                    self.origin.origin?.budget -= prevBudget
                    self.origin.origin?.origin?.budget -= prevBudget
                    
                    self.budgetName = changedBudget.name
                    self.budgetMoney = String((changedBudget.budget < 0) ? -changedBudget.budget : changedBudget.budget)
                    self.budgetDescription = changedBudget.description
                    try? self.moc.save()
                })
            })
            //  Jelikož ukládáme hodnotu v kladu/záporu (příjem/výdej či zisk/ztráta), ale v přehledu tuto hodnotu zobrazuje aplikace
            //  bez znaménka, tak je třeba danou hodnotu pro zobrazení převést na absolutní hodnotu.
            .onAppear{
                self.isOutCome = self.budgetInfo.budget < 0
                self.budgetMoney = String((self.budgetInfo.budget < 0) ? -self.budgetInfo.budget : self.budgetInfo.budget)
                self.budgetName = self.budgetInfo.wrappedName
                self.budgetDescription = self.budgetInfo.descrip!
            }
        }
    }
}

struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetView(origin: MonthItem.init())
    }
}
