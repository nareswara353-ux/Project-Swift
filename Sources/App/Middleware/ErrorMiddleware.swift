import Vapor
import Core

struct APIErrorResponse: Content {
    let error: String
    let message: String
}

struct APIErrorMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        do {
            return try await next.respond(to: request)
        } catch let appError as AppError {
            let abort = appError.asAbort
            let body = APIErrorResponse(
                error: abort.status.reasonPhrase,
                message: abort.reason
            )
            return try await body.encodeResponse(status: abort.status, for: request)
        }
    }
}
