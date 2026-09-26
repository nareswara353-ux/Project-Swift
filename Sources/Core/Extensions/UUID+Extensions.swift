import Foundation

public extension UUID {
    static func parse(_ string: String) -> UUID? {
        UUID(uuidString: string)
    }
    
    var uppercaseString: String {
        uuidString.uppercased()
    }
}
