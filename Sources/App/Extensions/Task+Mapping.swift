import Foundation
import Domain

extension CreateTaskRequestDTO {
    func toInput(userId: UUID) -> CreateTaskUseCase.Input {
        CreateTaskUseCase.Input(
            title: title,
            description: description,
            status: status.flatMap { Task.Status(rawValue: $0) },
            priority: priority.flatMap { Task.Priority(rawValue: $0) },
            dueDate: dueDate,
            userId: userId
        )
    }
}

extension UpdateTaskRequestDTO {
    func toInput(taskId: UUID, userId: UUID) -> UpdateTaskUseCase.Input {
        UpdateTaskUseCase.Input(
            taskId: taskId,
            userId: userId,
            title: title,
            description: description,
            status: status.flatMap { Task.Status(rawValue: $0) },
            priority: priority.flatMap { Task.Priority(rawValue: $0) },
            dueDate: dueDate
        )
    }
}
