import Vapor
import Logging

@main
struct Entrypoint {
    static func main() async throws {
        // Detect environment (development, production, etc.)
        var env = try Environment.detect()
        
        // Bootstrap structured logging
        try LoggingSystem.bootstrap(from: &env)
        
        // Create Vapor application instance
        let app = try await Application.make(env)
        
        // Ensure graceful shutdown on exit
        defer { try? app.shutdown() }
        
        // Configure routes
        try configureRoutes(app)
        
        // Start the server
        try await app.run()
    }
    
    private static func configureRoutes(_ app: Application) throws {
        // Root endpoint - API status
        app.get { req in
            return "Task Manager API is running!"
        }
        
        // Health check endpoint for load balancers / k8s
        app.get("health") { req -> HTTPStatus in
            return .ok
        }
    }
}
