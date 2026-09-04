import Foundation

public struct UpdateTaskUseCase: Sendable {
    public let taskRepository: TaskRepository
    
    public init(taskRepository: TaskRepository) {
        self.taskRepository = taskRepository
    }
    
    public struct Input: Sendable {
        public let taskId: UUID
        public let userId: UUID
        public let title: String?
        public let description: String?
        public let status: Task.Status?
        public let priority: Task.Priority?
        public let dueDate: Date?
        
        public init(taskId: UUID, userId: UUID, title: String? = nil, description: String? = nil, status: Task.Status? = nil, priority: Task.Priority? = nil, dueDate: Date? = nil) {
            self.taskId = taskId
            self.userId = userId
            self.title = title
            self.description = description
            self.status = status
            self.priority = priority
            self.dueDate = dueDate
        }
    }
    
    public struct Output: Sendable {
        public let task: Task
        
        public init(task: Task) {
            self.task = task
        }
    }
    
    public enum UpdateTaskError: Error, Equatable, CustomStringConvertible {
        case taskNotFound
        case permissionDenied
        case emptyTitle
        case pastDueDate
        
        public var description: String {
            switch self {
            case .taskNotFound:
                return "Task not found"
            case .permissionDenied:
                return "You don't have permission to update this task"
            case .emptyTitle:
                return "Task title cannot be empty"
            case .pastDueDate:
                return "Due date cannot be in the past"
            }
        }
    }
    
    public func execute(input: Input) async throws -> Output {
        guard let existingTask = try await taskRepository.findById(input.taskId) else {
            throw UpdateTaskError.taskNotFound
        }
        
        guard existingTask.userId == input.userId else {
            throw UpdateTaskError.permissionDenied
        }
        
        var updatedTask = existingTask
        
        if let title = input.title {
            guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw UpdateTaskError.emptyTitle
            }
            updatedTask.title = title
        }
        
        if let description = input.description {
            updatedTask.description = description
        }
        
        if let status = input.status {
            updatedTask.updateStatus(status)
        }
        
        if let priority = input.priority {
            updatedTask.updatePriority(priority)
        }
        
        if let dueDate = input.dueDate {
            guard dueDate >= Date() else {
                throw UpdateTaskError.pastDueDate
            }
            updatedTask.updateDueDate(dueDate)
        }
        
        try await taskRepository.update(updatedTask)
        return Output(task: updatedTask)
    }
}
