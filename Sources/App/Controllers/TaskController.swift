import Vapor
import Domain
import Infrastructure

struct TaskController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let tasks = routes.grouped("tasks")
        let auth = tasks.grouped(AuthMiddleware(tokenGenerator: try JWTTokenGenerator(config: AppConfiguration.load())))
        auth.get(use: index)
        auth.post(use: create)
        auth.get(":taskId", use: show)
        auth.put(":taskId", use: update)
        auth.delete(":taskId", use: delete)
    }
    
    @Sendable
    func index(req: Request) async throws -> [TaskResponse] {
        guard let user = req.authenticatedUser else {
            throw Abort(.unauthorized)
        }
        let repository = req.taskRepository
        let tasks = try await repository.findByUser(user.userID)
        return tasks.map { TaskResponse(from: $0) }
    }
    
    @Sendable
    func create(req: Request) async throws -> TaskResponse {
        guard let user = req.authenticatedUser else {
            throw Abort(.unauthorized)
        }
        let input = try req.content.decode(CreateTaskRequest.self)
        let repository = req.taskRepository
        let task = Task(
            title: input.title,
            description: input.description,
            status: input.status.flatMap { Task.Status(rawValue: $0) } ?? .todo,
            priority: input.priority.flatMap { Task.Priority(rawValue: $0) } ?? .medium,
            dueDate: input.dueDate,
            userId: user.userID
        )
        try await repository.create(task)
        return TaskResponse(from: task)
    }
    
    @Sendable
    func show(req: Request) async throws -> TaskResponse {
        guard let user = req.authenticatedUser else {
            throw Abort(.unauthorized)
        }
        guard let taskId = req.parameters.get("taskId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid task ID")
        }
        let repository = req.taskRepository
        guard let task = try await repository.findById(taskId) else {
            throw Abort(.notFound, reason: "Task not found")
        }
        guard task.userId == user.userID else {
            throw Abort(.forbidden, reason: "You don't have access to this task")
        }
        return TaskResponse(from: task)
    }
    
    @Sendable
    func update(req: Request) async throws -> TaskResponse {
        guard let user = req.authenticatedUser else {
            throw Abort(.unauthorized)
        }
        guard let taskId = req.parameters.get("taskId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid task ID")
        }
        let input = try req.content.decode(UpdateTaskRequest.self)
        let repository = req.taskRepository
        guard var task = try await repository.findById(taskId) else {
            throw Abort(.notFound, reason: "Task not found")
        }
        guard task.userId == user.userID else {
            throw Abort(.forbidden, reason: "You don't have access to this task")
        }
        if let title = input.title {
            task.title = title
        }
        if let description = input.description {
            task.description = description
        }
        if let status = input.status.flatMap({ Task.Status(rawValue: $0) }) {
            task.updateStatus(status)
        }
        if let priority = input.priority.flatMap({ Task.Priority(rawValue: $0) }) {
            task.updatePriority(priority)
        }
        if let dueDate = input.dueDate {
            task.updateDueDate(dueDate)
        }
        try await repository.update(task)
        return TaskResponse(from: task)
    }
    
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let user = req.authenticatedUser else {
            throw Abort(.unauthorized)
        }
        guard let taskId = req.parameters.get("taskId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid task ID")
        }
        let repository = req.taskRepository
        guard let task = try await repository.findById(taskId) else {
            throw Abort(.notFound, reason: "Task not found")
        }
        guard task.userId == user.userID else {
            throw Abort(.forbidden, reason: "You don't have access to this task")
        }
        try await repository.delete(id: taskId)
        return .noContent
    }
}

struct CreateTaskRequest: Content {
    let title: String
    let description: String?
    let status: String?
    let priority: String?
    let dueDate: Date?
}

struct UpdateTaskRequest: Content {
    let title: String?
    let description: String?
    let status: String?
    let priority: String?
    let dueDate: Date?
}

struct TaskResponse: Content {
    let id: UUID
    let title: String
    let description: String?
    let status: String
    let priority: String
    let dueDate: Date?
    let createdAt: Date
    let updatedAt: Date
    let userId: UUID
    
    init(from task: Task) {
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
}

extension Request {
    var taskRepository: TaskRepository {
        FluentTaskRepository(db: self.db)
    }
}
