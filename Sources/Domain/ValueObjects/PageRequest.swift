import Foundation

public struct PageRequest: Sendable, Equatable {
    public let page: Int
    public let perPage: Int
    
    public init?(page: Int, perPage: Int) {
        guard page >= 1, perPage >= 1, perPage <= 100 else { return nil }
        self.page = page
        self.perPage = perPage
    }
    
    public var offset: Int { (page - 1) * perPage }
    public var limit: Int { perPage }
    
    public static let `default` = PageRequest(page: 1, perPage: 20)!
}
