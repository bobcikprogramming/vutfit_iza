//
//  FiniteAutomata.swift
//  FiniteAutomata
//
//  Created by Filip Klembara on 17/02/2020.
//

/// Finite automata
public struct FiniteAutomata {
    let states: [String]
    let symbols: [String]
    let transitions: [Transition]
    let initialState: String
    let finalStates: [String]
    
    public func getState() -> [String]{
        return states
    }
    
    public func getSymbols() -> [String]{
        return symbols
    }
    
    public func getTransitions() -> [Transition]{
        return transitions
    }
    
    public func getInitialState() -> String{
        return initialState
    }
    
    public func getFinalStates() -> [String]{
        return finalStates
    }
}

public struct Transition: Decodable{
    let with: String
    let to: String
    let from: String

    public func getWith() -> String{
        return with
    }
    
    public func getTo() -> String{
        return to
    }
    
    public func getFrom() -> String{
        return from
    }
}

extension FiniteAutomata: Decodable {
    // *******************
    // * NOT IMPLEMENTED *
    // *******************
}
