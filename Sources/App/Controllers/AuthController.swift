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
        let input = try req.content.decode(RegisterRequestDTO.self)
        let useCase = RegisterUserUseCase(userRepository: req.userRepository)
        let output = try await useCase.execute(
            input: .init(
                email: input.email,
                password: input.password,
                role: input.role.flatMap { User.Role(rawValue: $0) }
            )
        )
        let response = RegisterResponseDTO(userId: output.userId, email: output.email.value)
        return try await response.encodeResponse(status: .created, for: req)
    }
    
    @Sendable
    func login(req: Request) async throws -> Response {
        let input = try req.content.decode(LoginRequestDTO.self)
        let useCase = LoginUserUseCase(userRepository: req.userRepository)
        let output = try await useCase.execute(
            input: .init(email: input.email, password: input.password)
        )
        let tokenGenerator = try req.application.makeTokenGenerator()
        let token = try await tokenGenerator.generateToken(for: output.user)
        let response = LoginResponseDTO(
            userId: output.user.id,
            email: output.user.email.value,
            role: output.user.role.rawValue,
            token: token
        )
        return try await response.encodeResponse(status: .ok, for: req)
    }
}
