import Fluent
import Vapor
import Domain
import Foundation

public struct FluentTaskRepository: TaskRepository {
    private let db: Database
    
    public init(db: Database) {
        self.db = db
    }
    
    public func create(_ task: Task) async throws {
        let model = TaskModel(from: task)
        try await model.create(on: db)
    }
    
    public func findById(_ id: UUID) async throws -> Task? {
        guard let model = try await TaskModel.find(id, on: db) else {
            return nil
        }
        return try model.toDomain()
    }
    
    public func findByUser(_ userId: UUID) async throws -> [Task] {
        let models = try await TaskModel.query(on: db)
            .filter(\.$userId == userId)
            .all()
        return try models.map { try $0.toDomain() }
    }
    
    public func update(_ task: Task) async throws {
        guard let model = try await TaskModel.find(task.id, on: db) else {
            throw RepositoryError.notFound("Task with id \(task.id)")
        }
        model.title = task.title
        model.description = task.description
        model.status = task.status.rawValue
        model.priority = task.priority.rawValue
        model.dueDate = task.dueDate
        model.updatedAt = task.updatedAt
        try await model.update(on: db)
    }
    
    public func delete(id: UUID) async throws {
        guard let model = try await TaskModel.find(id, on: db) else {
            throw RepositoryError.notFound("Task with id \(id)")
        }
        try await model.delete(on: db)
    }
    
    public func list(
        userId: UUID?,
        status: Task.Status?,
        priority: Task.Priority?,
        limit: Int,
        offset: Int
    ) async throws -> [Task] {
        var query = TaskModel.query(on: db)
        
        if let userId = userId {
            query = query.filter(\.$userId == userId)
        }
        if let status = status {
            query = query.filter(\.$status == status.rawValue)
        }
        if let priority = priority {
            query = query.filter(\.$priority == priority.rawValue)
        }
        
        let models = try await query
            .limit(limit)
            .offset(offset)
            .all()
        return try models.map { try $0.toDomain() }
    }
    
    public func count(
        userId: UUID?,
        status: Task.Status?,
        priority: Task.Priority?
    ) async throws -> Int {
        var query = TaskModel.query(on: db)
        
        if let userId = userId {
            query = query.filter(\.$userId == userId)
        }
        if let status = status {
            query = query.filter(\.$status == status.rawValue)
        }
        if let priority = priority {
            query = query.filter(\.$priority == priority.rawValue)
        }
        
        return try await query.count()
    }
    
    public func deleteAll(for userId: UUID) async throws {
        try await TaskModel.query(on: db)
            .filter(\.$userId == userId)
            .delete()
    }
}

// MARK: - Fluent Model
@Model
public final class TaskModel: Model {
    public static let schema = "tasks"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "title")
    public var title: String
    
    @Field(key: "description")
    public var description: String?
    
    @Field(key: "status")
    public var status: String
    
    @Field(key: "priority")
    public var priority: String
    
    @Field(key: "due_date")
    public var dueDate: Date?
    
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    public var updatedAt: Date?
    
    @Field(key: "user_id")
    public var userId: UUID
    
    public init() {}
    
    public init(from task: Task) {
        self.id = task.id
        self.title = task.title
        self.description = task.description
        self.status = task.status.rawValue
        self.priority = task.priority.rawValue
        self.dueDate = task.dueDate
        self.createdAt = task.createdAt
        self.updatedAt = task.updatedAt
        self.userId = task.userId
    }
    
    public func toDomain() throws -> Task {
        guard let id = self.id else {
            throw DecodingError.missingID
        }
        guard let createdAt = self.createdAt else {
            throw DecodingError.missingCreatedAt
        }
        guard let updatedAt = self.updatedAt else {
            throw DecodingError.missingUpdatedAt
        }
        guard let status = Task.Status(rawValue: self.status) else {
            throw DecodingError.invalidStatus(self.status)
        }
        guard let priority = Task.Priority(rawValue: self.priority) else {
            throw DecodingError.invalidPriority(self.priority)
        }
        return Task(
            id: id,
            title: self.title,
            description: self.description,
            status: status,
            priority: priority,
            dueDate: self.dueDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            userId: self.userId
        )
    }
}

private enum DecodingError: Error {
    case missingID
    case missingCreatedAt
    case missingUpdatedAt
    case invalidStatus(String)
    case invalidPriority(String)
}
