import Vapor
import Infrastructure
import Core

extension Application {
    func makeTokenGenerator() throws -> JWTTokenGenerator {
        let config = try AppConfiguration.load()
        return try JWTTokenGenerator(config: config)
    }
    
    func makeAuthMiddleware() throws -> AuthMiddleware {
        AuthMiddleware(tokenGenerator: try makeTokenGenerator())
    }
}
