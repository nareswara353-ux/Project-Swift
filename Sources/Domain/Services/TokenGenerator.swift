import Foundation

public protocol TokenGenerator: Sendable {
    /// Generate an authentication token for a user
    /// - Parameter user: The authenticated user
    /// - Returns: A string token (JWT)
    func generateToken(for user: User) async throws -> String
    
    /// Validate and decode a token, returning the user ID
    /// - Parameter token: The token string
    /// - Returns: User ID if token is valid, nil otherwise
    func validateToken(_ token: String) async throws -> UUID?
}
