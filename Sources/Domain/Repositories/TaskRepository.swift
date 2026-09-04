import Foundation

public protocol TaskRepository: Sendable {
    /// Create a new task
    func create(_ task: Task) async throws
    
    /// Find task by ID
    /// - Returns: `nil` if not found
    func findById(_ id: UUID) async throws -> Task?
    
    /// Find all tasks for a specific user
    func findByUser(_ userId: UUID) async throws -> [Task]
    
    /// Update existing task
    /// - Throws: `RepositoryError.notFound` if task doesn't exist
    func update(_ task: Task) async throws
    
    /// Delete task by ID
    /// - Throws: `RepositoryError.notFound` if task doesn't exist
    func delete(id: UUID) async throws
    
    /// List tasks with filters and pagination
    func list(
        userId: UUID?,
        status: Task.Status?,
        priority: Task.Priority?,
        limit: Int,
        offset: Int
    ) async throws -> [Task]
    
    /// Count tasks with filters
    func count(
        userId: UUID?,
        status: Task.Status?,
        priority: Task.Priority?
    ) async throws -> Int
    
    /// Delete all tasks for a user (cascade delete)
    func deleteAll(for userId: UUID) async throws
}
