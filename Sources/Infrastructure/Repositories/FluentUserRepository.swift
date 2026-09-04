import Fluent
import Vapor
import Domain
import Foundation

public struct FluentUserRepository: UserRepository {
    private let db: Database
    
    public init(db: Database) {
        self.db = db
    }
    
    public func create(_ user: User) async throws {
        let model = UserModel(from: user)
        try await model.create(on: db)
    }
    
    public func findById(_ id: UUID) async throws -> User? {
        guard let model = try await UserModel.find(id, on: db) else {
            return nil
        }
        return try model.toDomain()
    }
    
    public func findByEmail(_ email: Email) async throws -> User? {
        guard let model = try await UserModel.query(on: db)
            .filter(\.$email == email.value)
            .first() else {
            return nil
        }
        return try model.toDomain()
    }
    
    public func update(_ user: User) async throws {
        guard let model = try await UserModel.find(user.id, on: db) else {
            throw RepositoryError.notFound("User with id \(user.id)")
        }
        model.email = user.email.value
        model.passwordHash = user.passwordHash
        model.role = user.role.rawValue
        model.updatedAt = user.updatedAt
        try await model.update(on: db)
    }
    
    public func delete(id: UUID) async throws {
        guard let model = try await UserModel.find(id, on: db) else {
            throw RepositoryError.notFound("User with id \(id)")
        }
        try await model.delete(on: db)
    }
    
    public func list(limit: Int, offset: Int) async throws -> [User] {
        let models = try await UserModel.query(on: db)
            .limit(limit)
            .offset(offset)
            .all()
        return try models.map { try $0.toDomain() }
    }
    
    public func count() async throws -> Int {
        try await UserModel.query(on: db).count()
    }
}

// MARK: - Fluent Model
@Model
public final class UserModel: Model {
    public static let schema = "users"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "email")
    public var email: String
    
    @Field(key: "password_hash")
    public var passwordHash: String
    
    @Field(key: "role")
    public var role: String
    
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    public var updatedAt: Date?
    
    public init() {}
    
    public init(from user: User) {
        self.id = user.id
        self.email = user.email.value
        self.passwordHash = user.passwordHash
        self.role = user.role.rawValue
        self.createdAt = user.createdAt
        self.updatedAt = user.updatedAt
    }
    
    public func toDomain() throws -> User {
        guard let id = self.id else {
            throw DecodingError.missingID
        }
        guard let createdAt = self.createdAt else {
            throw DecodingError.missingCreatedAt
        }
        guard let updatedAt = self.updatedAt else {
            throw DecodingError.missingUpdatedAt
        }
        guard let email = Email(self.email) else {
            throw DecodingError.invalidEmail(self.email)
        }
        guard let role = User.Role(rawValue: self.role) else {
            throw DecodingError.invalidRole(self.role)
        }
        return User(
            id: id,
            email: email,
            passwordHash: self.passwordHash,
            role: role,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

private enum DecodingError: Error {
    case missingID
    case missingCreatedAt
    case missingUpdatedAt
    case invalidEmail(String)
    case invalidRole(String)
}
