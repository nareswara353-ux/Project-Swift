import Foundation
import Vapor

public struct RegisterUserUseCase: Sendable {
    public let userRepository: UserRepository
    
    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    public struct Input: Sendable {
        public let email: String
        public let password: String
        public let role: User.Role?
        
        public init(email: String, password: String, role: User.Role? = nil) {
            self.email = email
            self.password = password
            self.role = role
        }
    }
    
    public struct Output: Sendable {
        public let userId: UUID
        public let email: Email
        
        public init(userId: UUID, email: Email) {
            self.userId = userId
            self.email = email
        }
    }
    
    public enum RegistrationError: Error, Equatable, CustomStringConvertible {
        case invalidEmail
        case weakPassword
        case emailAlreadyExists
        
        public var description: String {
            switch self {
            case .invalidEmail:
                return "The email address is invalid."
            case .weakPassword:
                return "Password must be at least 8 characters long and contain at least one digit and one uppercase letter."
            case .emailAlreadyExists:
                return "An account with this email already exists."
            }
        }
    }
    
    public func execute(input: Input) async throws -> Output {
        guard let email = Email(input.email) else {
            throw RegistrationError.invalidEmail
        }
        
        guard validatePassword(input.password) else {
            throw RegistrationError.weakPassword
        }
        
        if try await userRepository.findByEmail(email) != nil {
            throw RegistrationError.emailAlreadyExists
        }
        
        let passwordHash = try Bcrypt.hash(input.password)
        
        let user = User(
            email: email,
            passwordHash: passwordHash,
            role: input.role ?? .user
        )
        
        try await userRepository.create(user)
        
        return Output(userId: user.id, email: user.email)
    }
    
    private func validatePassword(_ password: String) -> Bool {
        guard password.count >= 8 else { return false }
        let hasUppercase = password.rangeOfCharacter(from: .uppercaseLetters) != nil
        let hasDigit = password.rangeOfCharacter(from: .decimalDigits) != nil
        return hasUppercase && hasDigit
    }
}
