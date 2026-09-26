import Foundation

public enum AppError: Error, Equatable {
    case badRequest(String)
    case unauthorized(String)
    case forbidden(String)
    case notFound(String)
    case conflict(String)
    case internalError(String)
}

extension AppError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .badRequest(let m): return "Bad request: \(m)"
        case .unauthorized(let m): return "Unauthorized: \(m)"
        case .forbidden(let m): return "Forbidden: \(m)"
        case .notFound(let m): return "Not found: \(m)"
        case .conflict(let m): return "Conflict: \(m)"
        case .internalError(let m): return "Internal error: \(m)"
        }
    }
}
