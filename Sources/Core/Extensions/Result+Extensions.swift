import Foundation

public extension Result {
    func getOrThrow() throws -> Success {
        switch self {
        case .success(let v): return v
        case .failure(let e): throw e
        }
    }
    
    var value: Success? {
        try? getOrThrow()
    }
    
    var error: Failure? {
        if case .failure(let e) = self { return e }
        return nil
    }
}
