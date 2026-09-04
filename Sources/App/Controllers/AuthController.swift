import Vapor
import Domain
import Infrastructure

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        auth.post("register", use: register)
        auth.post("login", use: login)
    }
    
    @Sendable
    func register(req: Request) async throws -> Response {
        let input = try req.content.decode(RegisterRequest.self)
        let repository = req.userRepository
        let useCase = RegisterUserUseCase(userRepository: repository)
        let output = try await useCase.execute(input: input.toInput())
        let response = RegisterResponse(
            userId: output.userId,
            email: output.email.value
        )
        return try await response.encodeResponse(status: .created, for: req)
    }
    
    @Sendable
    func login(req: Request) async throws -> Response {
        let input = try req.content.decode(LoginRequest.self)
        let repository = req.userRepository
        let useCase = LoginUserUseCase(userRepository: repository)
        let output = try await useCase.execute(input: input.toInput())
        let tokenGenerator = try req.application.jwtTokenGenerator()
        let token = try await tokenGenerator.generateToken(for: output.user)
        let response = LoginResponse(
            userId: output.user.id,
            email: output.user.email.value,
            role: output.user.role.rawValue,
            token: token
        )
        return try await response.encodeResponse(status: .ok, for: req)
    }
}

struct RegisterRequest: Content {
    let email: String
    let password: String
    let role: String?
    
    func toInput() -> RegisterUserUseCase.Input {
        RegisterUserUseCase.Input(
            email: email,
            password: password,
            role: role.flatMap { User.Role(rawValue: $0) }
        )
    }
}

struct LoginRequest: Content {
    let email: String
    let password: String
    
    func toInput() -> LoginUserUseCase.Input {
        LoginUserUseCase.Input(email: email, password: password)
    }
}

struct RegisterResponse: Content {
    let userId: UUID
    let email: String
}

struct LoginResponse: Content {
    let userId: UUID
    let email: String
    let role: String
    let token: String
}

extension Application {
    func jwtTokenGenerator() throws -> JWTTokenGenerator {
        let config = try AppConfiguration.load()
        return try JWTTokenGenerator(config: config)
    }
}
