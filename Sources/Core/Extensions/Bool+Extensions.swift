import Foundation

public extension Bool {
    var toggled: Bool { !self }
    
    var asString: String { self ? "true" : "false" }
    
    init?(string: String) {
        switch string.lowercased() {
        case "true", "1", "yes": self = true
        case "false", "0", "no": self = false
        default: return nil
        }
    }
}
