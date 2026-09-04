import Foundation

public struct DeleteTaskUseCase: Sendable {
    public let taskRepository: TaskRepository
    
    public init(taskRepository: TaskRepository) {
        self.taskRepository = taskRepository
    }
    
    public struct Input: Sendable {
        public let taskId: UUID
        public let userId: UUID
        
        public init(taskId: UUID, userId: UUID) {
            self.taskId = taskId
            self.userId = userId
        }
    }
    
    public struct Output: Sendable {
        public let success: Bool
        
        public init(success: Bool) {
            self.success = success
        }
    }
    
    public enum DeleteTaskError: Error, Equatable, CustomStringConvertible {
        case taskNotFound
        case permissionDenied
        
        public var description: String {
            switch self {
            case .taskNotFound:
                return "Task not found"
            case .permissionDenied:
                return "You don't have permission to delete this task"
            }
        }
    }
    
    public func execute(input: Input) async throws -> Output {
        guard let existingTask = try await taskRepository.findById(input.taskId) else {
            throw DeleteTaskError.taskNotFound
        }
        
        guard existingTask.userId == input.userId else {
            throw DeleteTaskError.permissionDenied
        }
        
        try await taskRepository.delete(id: input.taskId)
        return Output(success: true)
    }
}
