import Foundation

public struct Paginated<T: Sendable>: Sendable {
    public let items: [T]
    public let total: Int
    public let limit: Int
    public let offset: Int
    
    public init(items: [T], total: Int, limit: Int, offset: Int) {
        self.items = items
        self.total = total
        self.limit = limit
        self.offset = offset
    }
}
