import Vapor
import Domain

struct RegisterRequestDTO: Content {
    let email: String
    let password: String
    let role: String?
}

struct LoginRequestDTO: Content {
    let email: String
    let password: String
}

struct RegisterResponseDTO: Content {
    let userId: UUID
    let email: String
}

struct LoginResponseDTO: Content {
    let userId: UUID
    let email: String
    let role: String
    let token: String
}
