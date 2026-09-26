import Vapor
import Core

extension AppError {
    var asAbort: Abort {
        switch self {
        case .badRequest(let m): return Abort(.badRequest, reason: m)
        case .unauthorized(let m): return Abort(.unauthorized, reason: m)
        case .forbidden(let m): return Abort(.forbidden, reason: m)
        case .notFound(let m): return Abort(.notFound, reason: m)
        case .conflict(let m): return Abort(.conflict, reason: m)
        case .internalError(let m): return Abort(.internalServerError, reason: m)
        }
    }
}
