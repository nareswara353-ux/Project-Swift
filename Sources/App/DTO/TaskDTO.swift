import Vapor
import Domain

struct CreateTaskRequestDTO: Content {
    let title: String
    let description: String?
    let status: String?
    let priority: String?
    let dueDate: Date?
}

struct UpdateTaskRequestDTO: Content {
    let title: String?
    let description: String?
    let status: String?
    let priority: String?
    let dueDate: Date?
}

struct TaskResponseDTO: Content {
    let id: UUID
    let title: String
    let description: String?
    let status: String
    let priority: String
    let dueDate: Date?
    let createdAt: Date
    let updatedAt: Date
    let userId: UUID
}

extension TaskResponseDTO {
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
