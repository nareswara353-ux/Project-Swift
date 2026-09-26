import Foundation

public struct Email: Sendable, Equatable, Codable, CustomStringConvertible {
    public let value: String
    
    public init?(_ raw: String) {
        guard Self.isValid(raw) else { return nil }
        self.value = raw.lowercased()
    }
    
    private static func isValid(_ email: String) -> Bool {
        let regex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: regex, options: .regularExpression) != nil
    }
    
    public var description: String { value }
}
