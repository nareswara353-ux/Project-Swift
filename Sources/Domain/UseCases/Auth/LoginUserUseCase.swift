import Foundation
import Vapor

public struct LoginUserUseCase: Sendable {
    public let userRepository: UserRepository
    
    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    public struct Input: Sendable {
        public let email: String
        public let password: String
        
        public init(email: String, password: String) {
            self.email = email
            self.password = password
        }
    }
    
    public struct Output: Sendable {
        public let user: User
        public let token: String
        
        public init(user: User, token: String) {
            self.user = user
            self.token = token
        }
    }
    
    public enum LoginError: Error, Equatable, CustomStringConvertible {
        case invalidCredentials
        case userNotFound
        
        public var description: String {
            switch self {
            case .invalidCredentials:
                return "Invalid email or password."
            case .userNotFound:
                return "User not found."
            }
        }
    }
    
    public func execute(input: Input) async throws -> Output {
        guard let email = Email(input.email) else {
            throw LoginError.invalidCredentials
        }
        
        guard let user = try await userRepository.findByEmail(email) else {
            throw LoginError.userNotFound
        }
        
        guard try Bcrypt.verify(input.password, created: user.passwordHash) else {
            throw LoginError.invalidCredentials
        }
        
        return Output(user: user, token: "")
    }
}
