import XCTest
import Domain
@testable import App

final class CreateTaskUseCaseTests: XCTestCase {
    let userId = UUID()
    
    func testCreateTaskSuccess() async throws {
        let repo = MockTaskRepository()
        let useCase = CreateTaskUseCase(taskRepository: repo)
        let input = CreateTaskUseCase.Input(
            title: "Test Task",
            description: "Test Description",
            status: .todo,
            priority: .high,
            dueDate: Date().addingTimeInterval(3600),
            userId: userId
        )
        let output = try await useCase.execute(input: input)
        XCTAssertEqual(output.task.title, "Test Task")
        XCTAssertEqual(output.task.description, "Test Description")
        XCTAssertEqual(output.task.status, .todo)
        XCTAssertEqual(output.task.priority, .high)
        XCTAssertEqual(output.task.userId, userId)
    }
    
    func testCreateTaskEmptyTitle() async throws {
        let repo = MockTaskRepository()
        let useCase = CreateTaskUseCase(taskRepository: repo)
        let input = CreateTaskUseCase.Input(
            title: "   ",
            description: nil,
            status: nil,
            priority: nil,
            dueDate: nil,
            userId: userId
        )
        do {
            _ = try await useCase.execute(input: input)
            XCTFail("Expected emptyTitle error")
        } catch CreateTaskUseCase.CreateTaskError.emptyTitle {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testCreateTaskPastDueDate() async throws {
        let repo = MockTaskRepository()
        let useCase = CreateTaskUseCase(taskRepository: repo)
        let input = CreateTaskUseCase.Input(
            title: "Test Task",
            description: nil,
            status: nil,
            priority: nil,
            dueDate: Date().addingTimeInterval(-3600),
            userId: userId
        )
        do {
            _ = try await useCase.execute(input: input)
            XCTFail("Expected pastDueDate error")
        } catch CreateTaskUseCase.CreateTaskError.pastDueDate {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testCreateTaskWithDefaultValues() async throws {
        let repo = MockTaskRepository()
        let useCase = CreateTaskUseCase(taskRepository: repo)
        let input = CreateTaskUseCase.Input(
            title: "Default Task",
            description: nil,
            status: nil,
            priority: nil,
            dueDate: nil,
            userId: userId
        )
        let output = try await useCase.execute(input: input)
        XCTAssertEqual(output.task.status, .todo)
        XCTAssertEqual(output.task.priority, .medium)
        XCTAssertNil(output.task.dueDate)
    }
    
    func testCreateTaskRepositoryError() async throws {
        let repo = MockTaskRepository()
        await repo.setShouldThrowOnCreate(true)
        let useCase = CreateTaskUseCase(taskRepository: repo)
        let input = CreateTaskUseCase.Input(
            title: "Test Task",
            description: nil,
            status: nil,
            priority: nil,
            dueDate: nil,
            userId: userId
        )
        do {
            _ = try await useCase.execute(input: input)
            XCTFail("Expected repository error")
        } catch {
            XCTAssertTrue(error is RepositoryError)
        }
    }
}
