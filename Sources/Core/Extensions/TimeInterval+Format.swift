import Foundation

public extension TimeInterval {
    var milliseconds: Int { Int(self * 1000) }
    var seconds: Double { self }
}
