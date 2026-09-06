import XCTest
import Domain
@testable import App

final class LoginUserUseCaseTests: XCTestCase {
    func testLoginSuccess() async throws {
        let repo = MockUserRepository()
        let registerUseCase = RegisterUserUseCase(userRepository: repo)
        let registerInput = RegisterUserUseCase.Input(email: "test@example.com", password: "Password123")
        _ = try await registerUseCase.execute(input: registerInput)
        let loginUseCase = LoginUserUseCase(userRepository: repo)
        let loginInput = LoginUserUseCase.Input(email: "test@example.com", password: "Password123")
        let output = try await loginUseCase.execute(input: loginInput)
        XCTAssertEqual(output.user.email.value, "test@example.com")
        XCTAssertFalse(output.token.isEmpty)
    }
    
    func testLoginUserNotFound() async throws {
        let repo = MockUserRepository()
        let loginUseCase = LoginUserUseCase(userRepository: repo)
        let input = LoginUserUseCase.Input(email: "test@example.com", password: "Password123")
        do {
            _ = try await loginUseCase.execute(input: input)
            XCTFail("Expected userNotFound error")
        } catch LoginUserUseCase.LoginError.userNotFound {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testLoginInvalidPassword() async throws {
        let repo = MockUserRepository()
        let registerUseCase = RegisterUserUseCase(userRepository: repo)
        let registerInput = RegisterUserUseCase.Input(email: "test@example.com", password: "Password123")
        _ = try await registerUseCase.execute(input: registerInput)
        let loginUseCase = LoginUserUseCase(userRepository: repo)
        let loginInput = LoginUserUseCase.Input(email: "test@example.com", password: "WrongPassword")
        do {
            _ = try await loginUseCase.execute(input: loginInput)
            XCTFail("Expected invalidCredentials error")
        } catch LoginUserUseCase.LoginError.invalidCredentials {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testLoginInvalidEmailFormat() async throws {
        let repo = MockUserRepository()
        let loginUseCase = LoginUserUseCase(userRepository: repo)
        let input = LoginUserUseCase.Input(email: "invalid", password: "Password123")
        do {
            _ = try await loginUseCase.execute(input: input)
            XCTFail("Expected invalidCredentials error")
        } catch LoginUserUseCase.LoginError.invalidCredentials {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
