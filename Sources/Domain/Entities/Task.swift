import Foundation

public struct Task: Sendable, Equatable, Identifiable {
    public let id: UUID
    public var title: String
    public var description: String?
    public var status: Status
    public var priority: Priority
    public var dueDate: Date?
    public let createdAt: Date
    public var updatedAt: Date
    public let userId: UUID
    
    public enum Status: String, Sendable, Codable, CaseIterable {
        case todo
        case inProgress = "in_progress"
        case review
        case done
        case archived
        
        public var isActive: Bool {
            switch self {
            case .done, .archived: return false
            default: return true
            }
        }
    }
    
    public enum Priority: String, Sendable, Codable, CaseIterable {
        case low
        case medium
        case high
        case critical
        
        public var weight: Int {
            switch self {
            case .low: return 1
            case .medium: return 2
            case .high: return 3
            case .critical: return 4
            }
        }
    }
    
    public init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        status: Status = .todo,
        priority: Priority = .medium,
        dueDate: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        userId: UUID
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.status = status
        self.priority = priority
        self.dueDate = dueDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.userId = userId
    }
    
    public mutating func updateStatus(_ newStatus: Status) {
        self.status = newStatus
        self.updatedAt = Date()
    }
    
    public mutating func updatePriority(_ newPriority: Priority) {
        self.priority = newPriority
        self.updatedAt = Date()
    }
    
    public mutating func updateDueDate(_ newDueDate: Date?) {
        self.dueDate = newDueDate
        self.updatedAt = Date()
    }
}
