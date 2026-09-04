import Foundation

public struct AppConfiguration: Sendable {
    public let databaseURL: String
    public let jwtSecret: String
    public let hostname: String
    public let port: Int
    public let environment: Environment
    
    public enum Environment: String, Sendable {
        case development
        case staging
        case production
        
        public var isProduction: Bool { self == .production }
    }
    
    private init(
        databaseURL: String,
        jwtSecret: String,
        hostname: String,
        port: Int,
        environment: Environment
    ) {
        self.databaseURL = databaseURL
        self.jwtSecret = jwtSecret
        self.hostname = hostname
        self.port = port
        self.environment = environment
    }
    
    public static func load() throws -> AppConfiguration {
        // Required variables
        guard let databaseURL = Environment.get("DATABASE_URL") else {
            throw ConfigurationError.missing("DATABASE_URL")
        }
        guard let jwtSecret = Environment.get("JWT_SECRET") else {
            throw ConfigurationError.missing("JWT_SECRET")
        }
        
        // Optional with defaults
        let hostname = Environment.get("HOSTNAME") ?? "127.0.0.1"
        let portString = Environment.get("PORT") ?? "8080"
        guard let port = Int(portString) else {
            throw ConfigurationError.invalid("PORT", value: portString)
        }
        
        let envString = Environment.get("SWIFT_ENV") ?? "development"
        guard let environment = Environment(rawValue: envString) else {
            throw ConfigurationError.invalid("SWIFT_ENV", value: envString)
        }
        
        return AppConfiguration(
            databaseURL: databaseURL,
            jwtSecret: jwtSecret,
            hostname: hostname,
            port: port,
            environment: environment
        )
    }
}

public enum ConfigurationError: Error, CustomStringConvertible {
    case missing(String)
    case invalid(String, value: String)
    
    public var description: String {
        switch self {
        case .missing(let key):
            return "Configuration error: required environment variable '\(key)' is missing."
        case .invalid(let key, let value):
            return "Configuration error: environment variable '\(key)' has invalid value '\(value)'."
        }
    }
}
