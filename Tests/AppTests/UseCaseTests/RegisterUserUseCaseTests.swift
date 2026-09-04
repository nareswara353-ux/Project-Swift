import XCTest
import Domain
@testable import App

final class RegisterUserUseCaseTests: XCTestCase {
    func testRegisterSuccess() async throws {
        let repo = MockUserRepository()
        let useCase = RegisterUserUseCase(userRepository: repo)
        let input = RegisterUserUseCase.Input(email: "test@example.com", password: "Password123")
        let output = try await useCase.execute(input: input)
        XCTAssertNotNil(output.userId)
        XCTAssertEqual(output.email.value, "test@example.com")
    }
    
    func testRegisterInvalidEmail() async throws {
        let repo = MockUserRepository()
        let useCase = RegisterUserUseCase(userRepository: repo)
        let input = RegisterUserUseCase.Input(email: "invalid", password: "Password123")
        do {
            _ = try await useCase.execute(input: input)
            XCTFail("Expected invalidEmail error")
        } catch RegisterUserUseCase.RegistrationError.invalidEmail {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testRegisterWeakPassword() async throws {
        let repo = MockUserRepository()
        let useCase = RegisterUserUseCase(userRepository: repo)
        let input = RegisterUserUseCase.Input(email: "test@example.com", password: "weak")
        do {
            _ = try await useCase.execute(input: input)
            XCTFail("Expected weakPassword error")
        } catch RegisterUserUseCase.RegistrationError.weakPassword {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testRegisterDuplicateEmail() async throws {
        let repo = MockUserRepository()
        let useCase = RegisterUserUseCase(userRepository: repo)
        let email = "test@example.com"
        let input1 = RegisterUserUseCase.Input(email: email, password: "Password123")
        _ = try await useCase.execute(input: input1)
        let input2 = RegisterUserUseCase.Input(email: email, password: "Password456")
        do {
            _ = try await useCase.execute(input: input2)
            XCTFail("Expected emailAlreadyExists error")
        } catch RegisterUserUseCase.RegistrationError.emailAlreadyExists {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
