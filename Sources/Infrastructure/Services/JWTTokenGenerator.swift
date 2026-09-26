import Vapor
import JWT
import Domain
import Foundation
import Core

public struct JWTTokenGenerator: TokenGenerator {
    private let signers: JWTSigners
    private let expiration: TimeInterval
    
    public init(config: AppConfiguration, expiration: TimeInterval = 3600 * 24) throws {
        self.expiration = expiration
        self.signers = JWTSigners()
        signers.use(.hs256(key: config.jwtSecret))
    }
    
    public func generateToken(for user: User) async throws -> String {
        let payload = UserPayload(
            userID: user.id,
            email: user.email.value,
            role: user.role.rawValue,
            exp: Date().addingTimeInterval(expiration)
        )
        return try signers.sign(payload)
    }
    
    public func validateToken(_ token: String) async throws -> UUID? {
        do {
            let payload = try signers.verify(token, as: UserPayload.self)
            return payload.userID
        } catch {
            return nil
        }
    }
}

struct UserPayload: JWTPayload {
    let userID: UUID
    let email: String
    let role: String
    let exp: Date
    
    enum CodingKeys: String, CodingKey {
        case userID = "sub"
        case email
        case role
        case exp
    }
    
    func verify(using signer: JWTSigner) throws {
        guard exp > Date() else {
            throw JWTError.claimVerificationFailure(
                name: "exp",
                reason: "Token expired"
            )
        }
    }
}
