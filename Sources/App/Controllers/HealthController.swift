import Vapor

struct HealthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("health", use: health)
        routes.get("ready", use: ready)
    }
    
    @Sendable
    func health(req: Request) async throws -> HTTPStatus {
        .ok
    }
    
    @Sendable
    func ready(req: Request) async throws -> HTTPStatus {
        .ok
    }
}
