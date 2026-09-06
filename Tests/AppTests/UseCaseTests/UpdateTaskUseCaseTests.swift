import XCTest
import Domain
@testable import App

final class UpdateTaskUseCaseTests: XCTestCase {
    let userId = UUID()
    let otherUserId = UUID()
    
    func testUpdateTaskSuccess() async throws {
        let repo = MockTaskRepository()
        let task = Task(
            title: "Original Title",
            description: "Original Description",
            status: .todo,
            priority: .medium,
            dueDate: Date().addingTimeInterval(86400),
            userId: userId
        )
        try await repo.create(task)
        
        let useCase = UpdateTaskUseCase(taskRepository: repo)
        let input = UpdateTaskUseCase.Input(
            taskId: task.id,
            userId: userId,
            title: "Updated Title",
            description: "Updated Description",
            status: .inProgress,
            priority: .high,
            dueDate: Date().addingTimeInterval(172800)
        )
        let output = try await useCase.execute(input: input)
        XCTAssertEqual(output.task.title, "Updated Title")
        XCTAssertEqual(output.task.description, "Updated Description")
        XCTAssertEqual(output.task.status, .inProgress)
        XCTAssertEqual(output.task.priority, .high)
        XCTAssertNotNil(output.task.dueDate)
    }
    
    func testUpdateTaskNotFound() async throws {
        let repo = MockTaskRepository()
        let useCase = UpdateTaskUseCase(taskRepository: repo)
        let input = UpdateTaskUseCase.Input(
            taskId: UUID(),
            userId: userId,
            title: "Updated Title",
            description: nil,
            status: nil,
            priority: nil,
            dueDate: nil
        )
        do {
            _ = try await useCase.execute(input: input)
            XCTFail("Expected taskNotFound error")
        } catch UpdateTaskUseCase.UpdateTaskError.taskNotFound {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testUpdateTaskPermissionDenied() async throws {
        let repo = MockTaskRepository()
        let task = Task(
            title: "Test Task",
            description: nil,
            status: .todo,
            priority: .medium,
            dueDate: nil,
            userId: userId
        )
        try await repo.create(task)
        
        let useCase = UpdateTaskUseCase(taskRepository: repo)
        let input = UpdateTaskUseCase.Input(
            taskId: task.id,
            userId: otherUserId,
            title: "Updated Title",
            description: nil,
            status: nil,
            priority: nil,
            dueDate: nil
        )
        do {
            _ = try await useCase.execute(input: input)
            XCTFail("Expected permissionDenied error")
        } catch UpdateTaskUseCase.UpdateTaskError.permissionDenied {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testUpdateTaskEmptyTitle() async throws {
        let repo = MockTaskRepository()
        let task = Task(
            title: "Original Title",
            description: nil,
            status: .todo,
            priority: .medium,
            dueDate: nil,
            userId: userId
        )
        try await repo.create(task)
        
        let useCase = UpdateTaskUseCase(taskRepository: repo)
        let input = UpdateTaskUseCase.Input(
            taskId: task.id,
            userId: userId,
            title: "   ",
            description: nil,
            status: nil,
            priority: nil,
            dueDate: nil
        )
        do {
            _ = try await useCase.execute(input: input)
            XCTFail("Expected emptyTitle error")
        } catch UpdateTaskUseCase.UpdateTaskError.emptyTitle {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testUpdateTaskPastDueDate() async throws {
        let repo = MockTaskRepository()
        let task = Task(
            title: "Original Title",
            description: nil,
            status: .todo,
            priority: .medium,
            dueDate: Date().addingTimeInterval(86400),
            userId: userId
        )
        try await repo.create(task)
        
        let useCase = UpdateTaskUseCase(taskRepository: repo)
        let input = UpdateTaskUseCase.Input(
            taskId: task.id,
            userId: userId,
            title: nil,
            description: nil,
            status: nil,
            priority: nil,
            dueDate: Date().addingTimeInterval(-3600)
        )
        do {
            _ = try await useCase.execute(input: input)
            XCTFail("Expected pastDueDate error")
        } catch UpdateTaskUseCase.UpdateTaskError.pastDueDate {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
