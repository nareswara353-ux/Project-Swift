import XCTest
import Domain
@testable import App

final class UpdateTaskUseCaseTests: XCTestCase {
    let userId = UUID()
    let otherUserId = UUID()
    
    func testUpdateTaskSuccess() async throws {
        let repo = MockTaskRepository()
        let createUseCase = CreateTaskUseCase(taskRepository: repo)
        let createInput = CreateTaskUseCase.Input(
            title: "Original Title",
            description: "Original Description",
            status: .todo,
            priority: .low,
            dueDate: Date().addingTimeInterval(3600),
            userId: userId
        )
        let createOutput = try await createUseCase.execute(input: createInput)
        let taskId = createOutput.task.id
        
        let updateUseCase = UpdateTaskUseCase(taskRepository: repo)
        let updateInput = UpdateTaskUseCase.Input(
            taskId: taskId,
            userId: userId,
            title: "Updated Title",
            description: "Updated Description",
            status: .inProgress,
            priority: .high,
            dueDate: Date().addingTimeInterval(7200)
        )
        let output = try await updateUseCase.execute(input: updateInput)
        XCTAssertEqual(output.task.title, "Updated Title")
        XCTAssertEqual(output.task.description, "Updated Description")
        XCTAssertEqual(output.task.status, .inProgress)
        XCTAssertEqual(output.task.priority, .high)
        XCTAssertEqual(output.task.userId, userId)
    }
    
    func testUpdateTaskNotFound() async throws {
        let repo = MockTaskRepository()
        let useCase = UpdateTaskUseCase(taskRepository: repo)
        let input = UpdateTaskUseCase.Input(
            taskId: UUID(),
            userId: userId,
            title: "New Title"
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
        let createUseCase = CreateTaskUseCase(taskRepository: repo)
        let createInput = CreateTaskUseCase.Input(
            title: "My Task",
            description: nil,
            status: nil,
            priority: nil,
            dueDate: nil,
            userId: userId
        )
        let createOutput = try await createUseCase.execute(input: createInput)
        let taskId = createOutput.task.id
        
        let updateUseCase = UpdateTaskUseCase(taskRepository: repo)
        let updateInput = UpdateTaskUseCase.Input(
            taskId: taskId,
            userId: otherUserId,
            title: "Hacked Title"
        )
        do {
            _ = try await updateUseCase.execute(input: updateInput)
            XCTFail("Expected permissionDenied error")
        } catch UpdateTaskUseCase.UpdateTaskError.permissionDenied {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testUpdateTaskEmptyTitle() async throws {
        let repo = MockTaskRepository()
        let createUseCase = CreateTaskUseCase(taskRepository: repo)
        let createInput = CreateTaskUseCase.Input(
            title: "Valid Title",
            description: nil,
            status: nil,
            priority: nil,
            dueDate: nil,
            userId: userId
        )
        let createOutput = try await createUseCase.execute(input: createInput)
        let taskId = createOutput.task.id
        
        let updateUseCase = UpdateTaskUseCase(taskRepository: repo)
        let updateInput = UpdateTaskUseCase.Input(
            taskId: taskId,
            userId: userId,
            title: "   "
        )
        do {
            _ = try await updateUseCase.execute(input: updateInput)
            XCTFail("Expected emptyTitle error")
        } catch UpdateTaskUseCase.UpdateTaskError.emptyTitle {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testUpdateTaskPastDueDate() async throws {
        let repo = MockTaskRepository()
        let createUseCase = CreateTaskUseCase(taskRepository: repo)
        let createInput = CreateTaskUseCase.Input(
            title: "Valid Title",
            description: nil,
            status: nil,
            priority: nil,
            dueDate: Date().addingTimeInterval(3600),
            userId: userId
        )
        let createOutput = try await createUseCase.execute(input: createInput)
        let taskId = createOutput.task.id
        
        let updateUseCase = UpdateTaskUseCase(taskRepository: repo)
        let updateInput = UpdateTaskUseCase.Input(
            taskId: taskId,
            userId: userId,
            dueDate: Date().addingTimeInterval(-3600)
        )
        do {
            _ = try await updateUseCase.execute(input: updateInput)
            XCTFail("Expected pastDueDate error")
        } catch UpdateTaskUseCase.UpdateTaskError.pastDueDate {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
