//
//  RunError.swift
//  proj1
//
//  Created by Filip Klembara on 17/02/2020.
//

enum RunError: Error {
    // *******************
    // * NOT IMPLEMENTED *
    // *******************
    case notImplemented
    case wrongArgument
    case notAcceptedByAutomata
    case fileError
    case automatDecodingError
    case notDefinedState
    case notDefinedSymbol
    case otherError
}

// MARK: - Return codes
extension RunError {
    var code: Int {
        switch self {
        case .notImplemented:
            return 66
        case .wrongArgument:
            return 11
        case .notAcceptedByAutomata:
            return 6
        case .fileError:
            return 12
        case .automatDecodingError:
            return 20
        case .notDefinedState:
            return 21
        case .notDefinedSymbol:
            return 22
        case .otherError:
            return 99
        // *******************
        // * NOT IMPLEMENTED *
        // *******************
        }
    }
}

// MARK:- Description of error
extension RunError: CustomStringConvertible {
    var description: String {
        switch self {
        case .notImplemented:
            return "Not implemented"
        case .wrongArgument:
            return "Nesprávné argumenty"
        case .notAcceptedByAutomata:
            return "Vstupní řetězec není akceptovaný automatem"
        case .fileError:
            return "Chyba při práci se soubory"
        case .automatDecodingError:
            return "Chyba při dekódování automatu"
        case .notDefinedState:
            return "Automat obsahuje nedefinovaný stav"
        case .notDefinedSymbol:
            return "Automat obsahuje nedefinovaný symbol"
        case .otherError:
            return "Jiná chyba"
        // *******************
        // * NOT IMPLEMENTED *
        // *******************
        }
    }
}
