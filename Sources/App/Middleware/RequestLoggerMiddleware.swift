import Vapor
import Core

public struct RequestLoggerMiddleware: AsyncMiddleware {
    private let logger: AppLogger
    
    public init(logger: AppLogger = .create(label: "request")) {
        self.logger = logger
    }
    
    public func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let start = Date()
        let method = request.method.rawValue
        let path = request.url.path
        
        do {
            let response = try await next.respond(to: request)
            let ms = Int(Date().timeIntervalSince(start) * 1000)
            logger.info("\(method) \(path) -> \(response.status.code) (\(ms)ms)")
            return response
        } catch {
            let ms = Int(Date().timeIntervalSince(start) * 1000)
            logger.error("\(method) \(path) -> ERROR \(error) (\(ms)ms)")
            throw error
        }
    }
}
