import Vapor
import Domain
import Infrastructure

extension Request {
    var userRepository: UserRepository {
        FluentUserRepository(db: application.db)
    }
    
    var taskRepository: TaskRepository {
        FluentTaskRepository(db: application.db)
    }
}
