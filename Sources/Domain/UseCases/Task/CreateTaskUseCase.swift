import Foundation

public struct CreateTaskUseCase: Sendable {
    public let taskRepository: TaskRepository
    
    public init(taskRepository: TaskRepository) {
        self.taskRepository = taskRepository
    }
    
    public struct Input: Sendable {
        public let title: String
        public let description: String?
        public let status: Task.Status?
        public let priority: Task.Priority?
        public let dueDate: Date?
        public let userId: UUID
        
        public init(title: String, description: String? = nil, status: Task.Status? = nil, priority: Task.Priority? = nil, dueDate: Date? = nil, userId: UUID) {
            self.title = title
            self.description = description
            self.status = status
            self.priority = priority
            self.dueDate = dueDate
            self.userId = userId
        }
    }
    
    public struct Output: Sendable {
        public let task: Task
        
        public init(task: Task) {
            self.task = task
        }
    }
    
    public enum CreateTaskError: Error, Equatable, CustomStringConvertible {
        case emptyTitle
        case pastDueDate
        case invalidStatus
        case invalidPriority
        
        public var description: String {
            switch self {
            case .emptyTitle:
                return "Task title cannot be empty"
            case .pastDueDate:
                return "Due date cannot be in the past"
            case .invalidStatus:
                return "Invalid status value"
            case .invalidPriority:
                return "Invalid priority value"
            }
        }
    }
    
    public func execute(input: Input) async throws -> Output {
        guard !input.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw CreateTaskError.emptyTitle
        }
        
        if let dueDate = input.dueDate, dueDate < Date() {
            throw CreateTaskError.pastDueDate
        }
        
        let status = input.status ?? .todo
        let priority = input.priority ?? .medium
        
        let task = Task(
            title: input.title,
            description: input.description,
            status: status,
            priority: priority,
            dueDate: input.dueDate,
            userId: input.userId
        )
        
        try await taskRepository.create(task)
        return Output(task: task)
    }
}
