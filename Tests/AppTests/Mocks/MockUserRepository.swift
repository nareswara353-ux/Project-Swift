import Foundation
import Domain

actor MockUserRepository: UserRepository {
    private var users: [UUID: User] = [:]
    private var throwsOnCreate: Bool = false
    private var throwsOnUpdate: Bool = false
    private var throwsOnDelete: Bool = false
    
    func setThrowsOnCreate(_ value: Bool) { throwsOnCreate = value }
    func setThrowsOnUpdate(_ value: Bool) { throwsOnUpdate = value }
    func setThrowsOnDelete(_ value: Bool) { throwsOnDelete = value }
    
    func create(_ user: User) async throws {
        if throwsOnCreate {
            throw RepositoryError.duplicateEmail(user.email)
        }
        guard users[user.id] == nil else {
            throw RepositoryError.duplicateEmail(user.email)
        }
        users[user.id] = user
    }
    
    func findById(_ id: UUID) async throws -> User? {
        users[id]
    }
    
    func findByEmail(_ email: Email) async throws -> User? {
        users.values.first { $0.email == email }
    }
    
    func update(_ user: User) async throws {
        if throwsOnUpdate {
            throw RepositoryError.notFound("User with id \(user.id)")
        }
        guard users[user.id] != nil else {
            throw RepositoryError.notFound("User with id \(user.id)")
        }
        users[user.id] = user
    }
    
    func delete(id: UUID) async throws {
        if throwsOnDelete {
            throw RepositoryError.notFound("User with id \(id)")
        }
        guard users[id] != nil else {
            throw RepositoryError.notFound("User with id \(id)")
        }
        users[id] = nil
    }
    
    func list(limit: Int, offset: Int) async throws -> [User] {
        let all = Array(users.values)
        let start = min(offset, all.count)
        let end = min(start + limit, all.count)
        return Array(all[start..<end])
    }
    
    func count() async throws -> Int {
        users.count
    }
}
