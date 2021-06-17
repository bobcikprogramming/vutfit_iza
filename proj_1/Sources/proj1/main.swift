//
//  main.swift
//  proj1
//
//  Created by Filip Klembara on 17/02/2020.
//

import Foundation
import FiniteAutomata
import Simulator

// MARK: - Main
func main() -> Result<Void, RunError> {
    // Kontrola počtu argumentů.
    let arguments = CommandLine.arguments
    if(arguments.count != 3){
        return  .failure(.wrongArgument)
    }
    
    // Načtení dat ze souboru.
    let jsonData: Data
    do{
        jsonData = try Data(contentsOf: URL(fileURLWithPath: arguments[2]), options: .mappedIfSafe)
    }catch{
        return .failure(.fileError)
    }
    
    // Dekódování načtených dat, inicializace simulatoru a jeho zavolání.
    // Výpis cesty, případně chyb.
    do{
        let jsonDecoder = JSONDecoder()
        let dataFromJson = try jsonDecoder.decode(FiniteAutomata.self, from: jsonData)
        
        for transitionsArr in dataFromJson.getTransitions() {
            if(!dataFromJson.getState().contains(transitionsArr.getTo())){
                return .failure(.notDefinedState)
            }
            if(!dataFromJson.getSymbols().contains(transitionsArr.getWith())){
                return .failure(.notDefinedSymbol)
            }
        }
        let simulator = Simulator.init(finiteAutomata: dataFromJson)
        let result = simulator.simulate(on: arguments[1])
        if(result.isEmpty){
            return .failure(.notAcceptedByAutomata)
        }else{
            for output in result{
                print(output)
            }
        }
    }catch{
        return .failure(.automatDecodingError)
    }
    
    return .success(())
}

// MARK: - program body
let result = main()

switch result {
case .success:
    break
case .failure(let error):
    var stderr = STDERRStream()
    print("Error:", error.description, to: &stderr)
    exit(Int32(error.code))
}

