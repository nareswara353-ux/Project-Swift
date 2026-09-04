import Vapor
import JWT
import Domain
import Foundation
import Core

public struct JWTTokenGenerator: TokenGenerator {
    private let config: AppConfiguration
    private let signer: JWTKit.Signer
    private let expiration: TimeInterval
    
    public init(config: AppConfiguration, expiration: TimeInterval = 3600 * 24) throws {
        self.config = config
        self.expiration = expiration
        // Use HS256 with the secret
        let key = config.jwtSecret
        self.signer = try Signers().use(.hs256(key: key))
    }
    
    public func generateToken(for user: User) async throws -> String {
        let payload = UserPayload(
            userID: user.id,
            email: user.email.value,
            role: user.role.rawValue,
            exp: Date().addingTimeInterval(expiration)
        )
        return try signer.sign(payload)
    }
    
    public func validateToken(_ token: String) async throws -> UUID? {
        do {
            let payload = try signer.verify(token, as: UserPayload.self)
            return payload.userID
        } catch {
            // Token invalid or expired
            return nil
        }
    }
}

// MARK: - JWT Payload
struct UserPayload: JWTPayload {
    let userID: UUID
    let email: String
    let role: String
    let exp: Date
    
    enum CodingKeys: String, CodingKey {
        case userID = "sub"
        case email = "email"
        case role = "role"
        case exp
    }
    
    func verify(using signer: JWTKit.Signer) async throws {
        guard exp > Date() else {
            throw JWTError.claimVerificationFailure(
                name: "exp",
                reason: "Token expired"
            )
        }
    }
}
