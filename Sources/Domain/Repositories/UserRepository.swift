import Foundation

public protocol UserRepository: Sendable {
    /// Create a new user
    /// - Throws: `RepositoryError.duplicateEmail` if email already exists
    func create(_ user: User) async throws
    
    /// Find user by ID
    /// - Returns: `nil` if not found
    func findById(_ id: UUID) async throws -> User?
    
    /// Find user by email
    /// - Returns: `nil` if not found
    func findByEmail(_ email: Email) async throws -> User?
    
    /// Update existing user (password hash, role, etc.)
    /// - Throws: `RepositoryError.notFound` if user doesn't exist
    func update(_ user: User) async throws
    
    /// Delete user by ID
    /// - Throws: `RepositoryError.notFound` if user doesn't exist
    func delete(id: UUID) async throws
    
    /// List users with pagination
    func list(limit: Int, offset: Int) async throws -> [User]
    
    /// Count total users
    func count() async throws -> Int
}

public enum RepositoryError: Error, Equatable {
    case notFound(String)
    case duplicateEmail(Email)
    case constraintViolation(String)
    
    public var description: String {
        switch self {
        case .notFound(let entity):
            return "\(entity) not found"
        case .duplicateEmail(let email):
            return "User with email \(email) already exists"
        case .constraintViolation(let message):
            return "Database constraint violation: \(message)"
        }
    }
}
