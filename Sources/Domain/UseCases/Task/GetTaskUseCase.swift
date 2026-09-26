import Foundation

public struct GetTaskUseCase: Sendable {
    public let taskRepository: TaskRepository
    
    public init(taskRepository: TaskRepository) {
        self.taskRepository = taskRepository
    }
    
    public struct Input: Sendable {
        public let taskId: UUID
        public let userId: UUID
    }
    
    public enum GetTaskError: Error, Equatable {
        case taskNotFound
        case permissionDenied
    }
    
    public func execute(input: Input) async throws -> Task {
        guard let task = try await taskRepository.findById(input.taskId) else {
            throw GetTaskError.taskNotFound
        }
        guard task.userId == input.userId else {
            throw GetTaskError.permissionDenied
        }
        return task
    }
}
