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
