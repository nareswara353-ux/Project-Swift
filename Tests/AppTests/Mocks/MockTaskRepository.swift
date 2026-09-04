import Foundation
import Domain

actor MockTaskRepository: TaskRepository {
    private var tasks: [UUID: Task] = [:]
    private var shouldThrowOnCreate: Bool = false
    private var shouldThrowOnUpdate: Bool = false
    private var shouldThrowOnDelete: Bool = false
    
    func setShouldThrowOnCreate(_ throw: Bool) {
        shouldThrowOnCreate = `throw`
    }
    
    func setShouldThrowOnUpdate(_ throw: Bool) {
        shouldThrowOnUpdate = `throw`
    }
    
    func setShouldThrowOnDelete(_ throw: Bool) {
        shouldThrowOnDelete = `throw`
    }
    
    func create(_ task: Task) async throws {
        if shouldThrowOnCreate {
            throw RepositoryError.constraintViolation("Duplicate task")
        }
        tasks[task.id] = task
    }
    
    func findById(_ id: UUID) async throws -> Task? {
        tasks[id]
    }
    
    func findByUser(_ userId: UUID) async throws -> [Task] {
        tasks.values.filter { $0.userId == userId }
    }
    
    func update(_ task: Task) async throws {
        if shouldThrowOnUpdate {
            throw RepositoryError.notFound("Task with id \(task.id)")
        }
        guard tasks[task.id] != nil else {
            throw RepositoryError.notFound("Task with id \(task.id)")
        }
        tasks[task.id] = task
    }
    
    func delete(id: UUID) async throws {
        if shouldThrowOnDelete {
            throw RepositoryError.notFound("Task with id \(id)")
        }
        guard tasks[id] != nil else {
            throw RepositoryError.notFound("Task with id \(id)")
        }
        tasks[id] = nil
    }
    
    func list(userId: UUID?, status: Task.Status?, priority: Task.Priority?, limit: Int, offset: Int) async throws -> [Task] {
        var filtered = tasks.values
        if let userId = userId {
            filtered = filtered.filter { $0.userId == userId }
        }
        if let status = status {
            filtered = filtered.filter { $0.status == status }
        }
        if let priority = priority {
            filtered = filtered.filter { $0.priority == priority }
        }
        let sorted = filtered.sorted { $0.createdAt > $1.createdAt }
        let start = min(offset, sorted.count)
        let end = min(start + limit, sorted.count)
        return Array(sorted[start..<end])
    }
    
    func count(userId: UUID?, status: Task.Status?, priority: Task.Priority?) async throws -> Int {
        var filtered = tasks.values
        if let userId = userId {
            filtered = filtered.filter { $0.userId == userId }
        }
        if let status = status {
            filtered = filtered.filter { $0.status == status }
        }
        if let priority = priority {
            filtered = filtered.filter { $0.priority == priority }
        }
        return filtered.count
    }
    
    func deleteAll(for userId: UUID) async throws {
        tasks = tasks.filter { $0.value.userId != userId }
    }
}
