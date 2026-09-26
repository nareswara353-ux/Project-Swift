import Vapor
import Domain
import Infrastructure

struct TaskController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let middleware = try routes.application.makeAuthMiddleware()
        let tasks = routes.grouped("tasks").grouped(middleware)
        tasks.get(use: index)
        tasks.post(use: create)
        tasks.get(":taskId", use: show)
        tasks.put(":taskId", use: update)
        tasks.delete(":taskId", use: delete)
    }
    
    @Sendable
    func index(req: Request) async throws -> [TaskResponseDTO] {
        guard let user = req.authenticatedUser else { throw Abort(.unauthorized) }
        let page = req.pageRequest
        let useCase = ListTasksUseCase(taskRepository: req.taskRepository)
        let output = try await useCase.execute(
            input: .init(userId: user.userID, limit: page.limit, offset: page.offset)
        )
        return output.tasks.map { TaskResponseDTO(from: $0) }
    }
    
    @Sendable
    func create(req: Request) async throws -> TaskResponseDTO {
        guard let user = req.authenticatedUser else { throw Abort(.unauthorized) }
        let dto = try req.content.decode(CreateTaskRequestDTO.self)
        let useCase = CreateTaskUseCase(taskRepository: req.taskRepository)
        let output = try await useCase.execute(input: dto.toInput(userId: user.userID))
        return TaskResponseDTO(from: output.task)
    }
    
    @Sendable
    func show(req: Request) async throws -> TaskResponseDTO {
        guard let user = req.authenticatedUser else { throw Abort(.unauthorized) }
        guard let taskId = req.parameters.get("taskId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid task ID")
        }
        let useCase = GetTaskUseCase(taskRepository: req.taskRepository)
        let task = try await useCase.execute(input: .init(taskId: taskId, userId: user.userID))
        return TaskResponseDTO(from: task)
    }
    
    @Sendable
    func update(req: Request) async throws -> TaskResponseDTO {
        guard let user = req.authenticatedUser else { throw Abort(.unauthorized) }
        guard let taskId = req.parameters.get("taskId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid task ID")
        }
        let dto = try req.content.decode(UpdateTaskRequestDTO.self)
        let useCase = UpdateTaskUseCase(taskRepository: req.taskRepository)
        let output = try await useCase.execute(input: dto.toInput(taskId: taskId, userId: user.userID))
        return TaskResponseDTO(from: output.task)
    }
    
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let user = req.authenticatedUser else { throw Abort(.unauthorized) }
        guard let taskId = req.parameters.get("taskId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid task ID")
        }
        let useCase = DeleteTaskUseCase(taskRepository: req.taskRepository)
        _ = try await useCase.execute(input: .init(taskId: taskId, userId: user.userID))
        return .noContent
    }
}
