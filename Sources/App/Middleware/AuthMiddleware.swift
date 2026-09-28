import Vapor
import Domain

public struct AuthenticatedUser: Sendable {
    public let userID: UUID
    public let email: String
    public let role: String
}

private struct AuthenticatedUserKey: StorageKey {
    typealias Value = AuthenticatedUser
}

extension Request {
    public var authenticatedUser: AuthenticatedUser? {
        get { storage[AuthenticatedUserKey.self] }
        set { storage[AuthenticatedUserKey.self] = newValue }
    }
}

public struct AuthMiddleware: AsyncMiddleware {
    private let tokenGenerator: TokenGenerator
    
    public init(tokenGenerator: TokenGenerator) {
        self.tokenGenerator = tokenGenerator
    }
    
    public func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let bearer = request.headers.bearerAuthorization else {
            throw Abort(.unauthorized, reason: "Missing bearer token")
        }
        guard let userID = try await tokenGenerator.validateToken(bearer.token) else {
            throw Abort(.unauthorized, reason: "Invalid or expired token")
        }
        guard let user = try await request.userRepository.findById(userID) else {
            throw Abort(.unauthorized, reason: "User not found")
        }
        request.authenticatedUser = AuthenticatedUser(
            userID: user.id,
            email: user.email.value,
            role: user.role.rawValue
        )
        return try await next.respond(to: request)
    }
}
