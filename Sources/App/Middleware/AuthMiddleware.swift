import Vapor
import Domain

public struct AuthenticatedUser: Sendable {
    public let userID: UUID
    public let email: String
    public let role: String
    
    public init(userID: UUID, email: String, role: String) {
        self.userID = userID
        self.email = email
        self.role = role
    }
}

extension Request {
    public var authenticatedUser: AuthenticatedUser? {
        get { storage[AuthenticatedUserKey.self] }
        set { storage[AuthenticatedUserKey.self] = newValue }
    }
}

private struct AuthenticatedUserKey: StorageKey {
    typealias Value = AuthenticatedUser
}

public final class AuthMiddleware: Middleware {
    private let tokenGenerator: TokenGenerator
    
    public init(tokenGenerator: TokenGenerator) {
        self.tokenGenerator = tokenGenerator
    }
    
    public func respond(to request: Request, chainingTo next: Responder) async throws -> Response {
        // Extract token from Authorization header
        guard let authHeader = request.headers.bearerAuthorization else {
            throw Abort(.unauthorized, reason: "Missing authorization header")
        }
        
        let token = authHeader.token
        
        // Validate token
        guard let userID = try await tokenGenerator.validateToken(token) else {
            throw Abort(.unauthorized, reason: "Invalid or expired token")
        }
        
        // Fetch user from repository to get full data (optional, bisa skip untuk performa)
        // Kita simpan minimal userID dan role, tapi untuk role kita perlu ambil dari DB
        // Alternatif: decode role dari token juga, tapi kita belum masukkan role di payload? Kita sudah masukkan.
        // Kita bisa decode dari payload langsung, tapi tokenGenerator.validateToken hanya mengembalikan UUID.
        // Kita akan perlu decode ulang. Untuk efisiensi, kita tambahkan method di TokenGenerator untuk mendapatkan payload lengkap.
        // Atau kita simpan role di token dan kita decode di sini dengan signer.
        // Karena kita punya JWTTokenGenerator yang bisa verify, kita bisa akses payload-nya.
        // Namun TokenGenerator hanya protokol dengan validateToken returning UUID.
        // Kita perlu memperluas protokol atau melakukan casting.
        // Untuk sementara, kita asumsikan kita punya akses ke JWTTokenGenerator secara langsung.
        // Tapi karena kita ingin tetap abstrak, kita bisa menambahkan method di TokenGenerator untuk mendapatkan user info.
        // Atau kita fetch user dari repository berdasarkan userID.
        // Saya akan fetch user dari repository, karena lebih aman dan sesuai dengan clean architecture.
        
        // Get user repository from request
        let userRepository = request.userRepository // kita perlu menambahkan extension untuk mendapatkan repository
        // Karena kita belum menambahkan extension, kita akan buat di sini dengan asumsi request memiliki `userRepository` property.
        // Untuk sekarang, kita akan menggunakan `request.application` untuk mendapatkan repository.
        // Tapi karena repository butuh db, kita bisa ambil dari request.db.
        // Saya akan implementasikan dengan cara yang lebih sederhana: kita buat repository di sini.
        // Kita akan panggil `request.db` untuk membuat FluentUserRepository.
        
        guard let db = request.db else {
            throw Abort(.internalServerError, reason: "Database not available")
        }
        let repository = FluentUserRepository(db: db)
        
        guard let user = try await repository.findById(userID) else {
            throw Abort(.unauthorized, reason: "User not found")
        }
        
        // Store authenticated user in request storage
        request.authenticatedUser = AuthenticatedUser(
            userID: user.id,
            email: user.email.value,
            role: user.role.rawValue
        )
        
        return try await next.respond(to: request)
    }
}

// Extension to get repository from request
extension Request {
    var userRepository: UserRepository {
        FluentUserRepository(db: self.db)
    }
}
