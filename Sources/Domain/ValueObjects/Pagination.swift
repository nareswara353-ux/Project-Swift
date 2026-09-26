import Foundation

public struct Pagination: Sendable, Equatable {
    public let limit: Int
    public let offset: Int
    
    public init?(limit: Int, offset: Int) {
        guard limit > 0, limit <= 100, offset >= 0 else { return nil }
        self.limit = limit
        self.offset = offset
    }
    
    public static let `default` = Pagination(limit: 20, offset: 0)!
}
