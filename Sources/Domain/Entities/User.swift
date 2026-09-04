import Foundation

public struct User: Sendable, Equatable, Identifiable {
    public let id: UUID
    public let email: Email
    public var passwordHash: String
    public var role: Role
    public let createdAt: Date
    public var updatedAt: Date
    
    public enum Role: String, Sendable, Codable, CaseIterable {
        case admin
        case user
        case guest
    }
    
    public init(
        id: UUID = UUID(),
        email: Email,
        passwordHash: String,
        role: Role = .user,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.passwordHash = passwordHash
        self.role = role
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    public mutating func updatePasswordHash(_ newHash: String) {
        self.passwordHash = newHash
        self.updatedAt = Date()
    }
    
    public mutating func updateRole(_ newRole: Role) {
        self.role = newRole
        self.updatedAt = Date()
    }
}

// MARK: - Email Value Object
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
