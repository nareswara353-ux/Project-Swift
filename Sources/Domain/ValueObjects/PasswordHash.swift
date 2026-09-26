import Foundation

public struct PasswordHash: Sendable, Equatable, Codable, CustomStringConvertible {
    public let value: String
    
    public init(_ value: String) {
        self.value = value
    }
    
    public var description: String { "***" }
}
