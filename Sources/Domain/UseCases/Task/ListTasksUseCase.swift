import Foundation

public struct ListTasksUseCase: Sendable {
    public let taskRepository: TaskRepository
    
    public init(taskRepository: TaskRepository) {
        self.taskRepository = taskRepository
    }
    
    public struct Input: Sendable {
        public let userId: UUID
        public let status: Task.Status?
        public let priority: Task.Priority?
        public let limit: Int
        public let offset: Int
        
        public init(userId: UUID, status: Task.Status? = nil, priority: Task.Priority? = nil, limit: Int = 20, offset: Int = 0) {
            self.userId = userId
            self.status = status
            self.priority = priority
            self.limit = limit
            self.offset = offset
        }
    }
    
    public struct Output: Sendable {
        public let tasks: [Task]
        public let total: Int
        
        public init(tasks: [Task], total: Int) {
            self.tasks = tasks
            self.total = total
        }
    }
    
    public func execute(input: Input) async throws -> Output {
        let tasks = try await taskRepository.list(
            userId: input.userId,
            status: input.status,
            priority: input.priority,
            limit: input.limit,
            offset: input.offset
        )
        let total = try await taskRepository.count(
            userId: input.userId,
            status: input.status,
            priority: input.priority
        )
        return Output(tasks: tasks, total: total)
    }
}
