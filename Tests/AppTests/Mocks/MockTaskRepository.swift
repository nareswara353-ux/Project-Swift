import Foundation
import Domain

actor MockTaskRepository: TaskRepository {
    private var tasks: [UUID: Task] = [:]
    private var throwsOnCreate: Bool = false
    private var throwsOnUpdate: Bool = false
    private var throwsOnDelete: Bool = false
    
    func setThrowsOnCreate(_ value: Bool) { throwsOnCreate = value }
    func setThrowsOnUpdate(_ value: Bool) { throwsOnUpdate = value }
    func setThrowsOnDelete(_ value: Bool) { throwsOnDelete = value }
    
    func create(_ task: Task) async throws {
        if throwsOnCreate {
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
        if throwsOnUpdate {
            throw RepositoryError.notFound("Task with id \(task.id)")
        }
        guard tasks[task.id] != nil else {
            throw RepositoryError.notFound("Task with id \(task.id)")
        }
        tasks[task.id] = task
    }
    
    func delete(id: UUID) async throws {
        if throwsOnDelete {
            throw RepositoryError.notFound("Task with id \(id)")
        }
        guard tasks[id] != nil else {
            throw RepositoryError.notFound("Task with id \(id)")
        }
        tasks[id] = nil
    }
    
    func list(userId: UUID?, status: Task.Status?, priority: Task.Priority?, limit: Int, offset: Int) async throws -> [Task] {
        var filtered = tasks.values
        if let userId = userId { filtered = filtered.filter { $0.userId == userId } }
        if let status = status { filtered = filtered.filter { $0.status == status } }
        if let priority = priority { filtered = filtered.filter { $0.priority == priority } }
        let sorted = filtered.sorted { $0.createdAt > $1.createdAt }
        let start = min(offset, sorted.count)
        let end = min(start + limit, sorted.count)
        return Array(sorted[start..<end])
    }
    
    func count(userId: UUID?, status: Task.Status?, priority: Task.Priority?) async throws -> Int {
        var filtered = tasks.values
        if let userId = userId { filtered = filtered.filter { $0.userId == userId } }
        if let status = status { filtered = filtered.filter { $0.status == status } }
        if let priority = priority { filtered = filtered.filter { $0.priority == priority } }
        return filtered.count
    }
    
    func deleteAll(for userId: UUID) async throws {
        tasks = tasks.filter { $0.value.userId != userId }
    }
}
