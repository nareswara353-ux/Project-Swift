import Logging
import Foundation

public struct AppLogger: Sendable {
    private let logger: Logger
    
    private init(label: String) {
        self.logger = Logger(label: label)
    }
    
    public static func create(label: String = "com.taskmanager.api") -> AppLogger {
        AppLogger(label: label)
    }
    
    public func trace(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.trace(message(), metadata: metadata(file: file, function: function, line: line))
    }
    
    public func debug(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.debug(message(), metadata: metadata(file: file, function: function, line: line))
    }
    
    public func info(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.info(message(), metadata: metadata(file: file, function: function, line: line))
    }
    
    public func notice(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.notice(message(), metadata: metadata(file: file, function: function, line: line))
    }
    
    public func warning(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.warning(message(), metadata: metadata(file: file, function: function, line: line))
    }
    
    public func error(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.error(message(), metadata: metadata(file: file, function: function, line: line))
    }
    
    public func critical(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line) {
        logger.critical(message(), metadata: metadata(file: file, function: function, line: line))
    }
    
    private func metadata(file: String, function: String, line: Int) -> Logger.Metadata {
        [
            "file": "\(file.split(separator: "/").last ?? "unknown")",
            "function": "\(function)",
            "line": "\(line)"
        ]
    }
}
