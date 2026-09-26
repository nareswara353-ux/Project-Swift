import Vapor

extension Request {
    var clientIP: String {
        headers.first(name: .xForwardedFor)
            ?? remoteAddress?.hostname
            ?? "unknown"
    }
}
