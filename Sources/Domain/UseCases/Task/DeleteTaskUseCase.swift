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
        public init(success: Bool) { self.success = success }
    }
    
    public enum DeleteTaskError: Error, Equatable {
        case taskNotFound
        case permissionDenied
    }
    
    public func execute(input: Input) async throws -> Output {
        guard let task = try await taskRepository.findById(input.taskId) else {
            throw DeleteTaskError.taskNotFound
        }
        guard task.userId == input.userId else {
            throw DeleteTaskError.permissionDenied
        }
        try await taskRepository.delete(id: input.taskId)
        return Output(success: true)
    }
}
