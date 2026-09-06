import XCTest
import Domain
@testable import App

final class DeleteTaskUseCaseTests: XCTestCase {
    let userId = UUID()
    let otherUserId = UUID()
    
    func testDeleteTaskSuccess() async throws {
        let repo = MockTaskRepository()
        let createUseCase = CreateTaskUseCase(taskRepository: repo)
        let createInput = CreateTaskUseCase.Input(
            title: "Task to Delete",
            description: nil,
            status: nil,
            priority: nil,
            dueDate: nil,
            userId: userId
        )
        let createOutput = try await createUseCase.execute(input: createInput)
        let taskId = createOutput.task.id
        
        let deleteUseCase = DeleteTaskUseCase(taskRepository: repo)
        let input = DeleteTaskUseCase.Input(taskId: taskId, userId: userId)
        let output = try await deleteUseCase.execute(input: input)
        XCTAssertTrue(output.success)
        
        let deleted = try await repo.findById(taskId)
        XCTAssertNil(deleted)
    }
    
    func testDeleteTaskNotFound() async throws {
        let repo = MockTaskRepository()
        let useCase = DeleteTaskUseCase(taskRepository: repo)
        let input = DeleteTaskUseCase.Input(taskId: UUID(), userId: userId)
        do {
            _ = try await useCase.execute(input: input)
            XCTFail("Expected taskNotFound error")
        } catch DeleteTaskUseCase.DeleteTaskError.taskNotFound {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testDeleteTaskPermissionDenied() async throws {
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
        
        let deleteUseCase = DeleteTaskUseCase(taskRepository: repo)
        let input = DeleteTaskUseCase.Input(taskId: taskId, userId: otherUserId)
        do {
            _ = try await deleteUseCase.execute(input: input)
            XCTFail("Expected permissionDenied error")
        } catch DeleteTaskUseCase.DeleteTaskError.permissionDenied {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
