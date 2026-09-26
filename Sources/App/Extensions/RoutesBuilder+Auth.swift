import Vapor

extension RoutesBuilder {
    func protected(using middleware: AuthMiddleware) -> RoutesBuilder {
        self.grouped(middleware)
    }
}
