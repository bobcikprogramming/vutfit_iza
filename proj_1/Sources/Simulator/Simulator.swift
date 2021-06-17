//
//  Simulator.swift
//  Simulator
//
//  Created by Filip Klembara on 17/02/2020.
//

import FiniteAutomata
import Foundation

/// Simulator
public struct Simulator {
    /// Finite automata used in simulations
    private let finiteAutomata: FiniteAutomata
    
    /// Initialize simulator with given automata
    /// - Parameter finiteAutomata: finite automata
    public init(finiteAutomata: FiniteAutomata) {
        self.finiteAutomata = finiteAutomata
    }

    /// Simulate automata on given string
    /// - Parameter string: string with symbols separated by ','
    /// - Returns: Empty array if given string is not accepted by automata,
    ///     otherwise array of states
    public func simulate(on string: String) -> [String] {
        // Rozdělení symbolů podle čárky a uložení dat načtených z json do pomocných proměných.
        let symbolsArr = string.components(separatedBy: ",")
        let automataTransitionsArr = finiteAutomata.getTransitions()
        let automataInitialState = finiteAutomata.getInitialState()
        let automataFinalStatesArr = finiteAutomata.getFinalStates()
        
        // Vytvoření pomocného seznamu a přidání id pro jednotlivé přechody.
        var myTransitionArr = [deadEnd]()
        var id = 0
        for transition in automataTransitionsArr{
            myTransitionArr.append(deadEnd(id: id, from: transition.getFrom(), with: transition.getWith(), to: transition.getTo()))
            id += 1
        }
        
        // Nastavení vstupního stavu jako aktuálního, vytvoření pomocných polí a proměnných,
        // přidání aktuálního uzlu do pole cesty.
        var actualState = automataInitialState
        var path = [String]()
        var lastStep = [Int]()
        let numOfSymb = symbolsArr.count
        var symbIndex = 0
        var skipStates = [Int]()
        path.append(actualState)
        
        // Pokud je vstupní symbol prázdný string a počáteční cesta je zároveň koncová, vracíme ji
        if(string == "" && automataFinalStatesArr.contains(automataInitialState)){
            return path
        }
        
        while (true){
            var index = 0
            if(numOfSymb == symbIndex){
                // Pokud jsme prozkoumali poslední obdržený symbol na vstupu a množina finálních stavů
                // obsahuje náš aktuální, tak ukončujeme cyklus.
                if(automataFinalStatesArr.contains(actualState)){
                    break
                }else{
                    // Jinak odebereme posledně přidaný stav z pole cesty, nastavíme jako aktuální stav
                    // nový poslední stav z pole cest, snížíme index symbolu ze vstupu a dle id přechodu,
                    // jenž máme odstranit, odstraníme daný přechod z možností.
                    path.removeLast()
                    actualState = path.last!
                    symbIndex -= 1
                    var indexToRemove = 0
                    for toRemove in myTransitionArr{
                        if(toRemove.id == lastStep.last){
                            myTransitionArr.remove(at: indexToRemove)
                            lastStep.removeLast()
                            break
                        }
                        indexToRemove += 1
                    }
                    continue
                }
            }
            // Najdeme možný přechod vedoucí z našeho stavu.
            for findWay in myTransitionArr{
                if(findWay.from == actualState && !skipStates.contains(index)){
                    break
                }
                index += 1 // Když nenajde, je to o jedno mimo rozsah (== .count).
            }
            // Nebyl nalezen žádný možný přechod.
            if(index == myTransitionArr.count){
                if(actualState == automataInitialState){
                    // Jsem na počátečním stavu, nemůže se více vrátit zpět, ukončuji se s prázdnou cestou.
                    path = []
                    break
                }else{
                    // Vracím se o stav zpět: odebírám poslední stav z cesty, snižuji index
                    // vstupního symbolu, odebírám cestu z možností.
                    path.removeLast()
                    actualState = path.last!
                    symbIndex -= 1
                    var indexToRemove = 0
                    for toRemove in myTransitionArr{
                        if(toRemove.id == lastStep.last){
                            myTransitionArr.remove(at: indexToRemove)
                            lastStep.removeLast()
                            break
                        }
                        indexToRemove += 1
                    }
                    continue
                }
            }
            // Pokud vstupní symbol odpovídá symbolu přechodu, tak provedeme přechod, tedy aktualizujeme
            // aktuální stav, zapíšeme nový stav do pole cesty, uložíme si do pole provedených kroků id
            // provedeného přechodu, inkrementuje index načteného symbolu a nastavíme pole stavů na
            // přeskočení na prázdné pole.
            if(symbolsArr[symbIndex] == myTransitionArr[index].with){
                actualState = myTransitionArr[index].to
                path.append(actualState)
                lastStep.append(myTransitionArr[index].id)
                symbIndex += 1
                skipStates = []
            }else{
                // Jinak přidáme stav pro přeskočení do pole stavů na přeskečení.
                skipStates.append(index)
            }
        }
        
        return path
    }
}

public class deadEnd{
    let id: Int
    let from: String
    let with: String
    let to: String
    
    init (id: Int, from: String, with: String, to: String) {
        self.id = id
        self.from = from
        self.with = with
        self.to = to
    }
}
