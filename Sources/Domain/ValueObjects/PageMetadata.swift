import Foundation

public struct PageMetadata: Sendable, Equatable {
    public let page: Int
    public let perPage: Int
    public let total: Int
    
    public init(page: Int, perPage: Int, total: Int) {
        self.page = page
        self.perPage = perPage
        self.total = total
    }
    
    public var totalPages: Int {
        guard perPage > 0 else { return 0 }
        return (total + perPage - 1) / perPage
    }
}
