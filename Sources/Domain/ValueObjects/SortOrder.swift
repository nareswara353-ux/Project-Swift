import Foundation

public enum SortOrder: String, Sendable, Codable, CaseIterable {
    case ascending = "asc"
    case descending = "desc"
    
    public var isAscending: Bool { self == .ascending }
}
